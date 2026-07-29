import isNil from 'lodash/isNil';
import type { PoolClient } from 'pg';

import {
  outbound_message_stages,
  outbound_messages_routing,
} from '../lib/db-types';
import {
  InvalidChannelError,
  SendingLocationNotFoundError,
} from '../lib/errors';
import { insert } from '../lib/inserter';
import {
  DecisionStage,
  getFromNumberMapping,
  getNumberForSendingLocation,
  hoursBetweenDates,
  ProcessMessagePayloadSchema,
} from '../lib/process-message';
import { chooseSendingLocationForContact, getRedis } from '../lib/redis';
import { TrafficChannel, WrappableTask } from '../lib/types';
import { logger, statsd } from '../logger';
import { profileConfigCache } from '../models/cache';

export const PROCESS_10DLC_MESSAGE_IDENTIFIER = 'process-10dlc-message';

export const process10DlcMessage: WrappableTask = async (
  client,
  rawPayload
) => {
  const payload = ProcessMessagePayloadSchema.parse(rawPayload);

  let result: outbound_messages_routing;
  const before = Date.now();

  const profileInfo = await profileConfigCache.getProfileConfig(
    client as unknown as PoolClient,
    payload.profile_id
  );

  if (profileInfo.channel !== TrafficChannel.TenDlc) {
    throw new InvalidChannelError(profileInfo.channel);
  }

  const prevMappingRecord = await getFromNumberMapping(client, {
    toNumber: payload.to_number,
    profileId: payload.profile_id,
  });

  if (prevMappingRecord !== undefined) {
    const firstFromToPairOfDay =
      isNil(prevMappingRecord.last_used_at) ||
      hoursBetweenDates(new Date(), prevMappingRecord.last_used_at) > 12;

    result = await insert(client, 'outbound_messages_routing', {
      id: payload.id,
      original_created_at: payload.created_at as unknown as Date,
      profile_id: payload.profile_id,
      to_number: payload.to_number,
      estimated_segments: payload.estimated_segments,
      decision_stage: DecisionStage.PrevMapping,
      stage: outbound_message_stages.Queued,
      from_number: prevMappingRecord.from_number,
      sending_location_id: prevMappingRecord.sending_location_id,
      send_after: payload.send_after as unknown as Date | null,
      first_from_to_pair_of_day: firstFromToPairOfDay,
    });
  } else {
    const { profile_id, contact_zip_code: contactZipCode } = payload;
    const env = { redis: getRedis(), pg: client };
    const sendingLocationId = await chooseSendingLocationForContact(
      env,
      profile_id,
      { contactZipCode }
    );

    if (sendingLocationId === undefined) {
      throw new SendingLocationNotFoundError();
    }

    // Do not use Redis-backed getExistingAvailableNumber -- it is unregistered traffic-specific
    const fromNumber = await getNumberForSendingLocation(
      client,
      sendingLocationId
    );

    result = await insert(client, 'outbound_messages_routing', {
      id: payload.id,
      original_created_at: payload.created_at as unknown as Date,
      profile_id: payload.profile_id,
      to_number: payload.to_number,
      estimated_segments: payload.estimated_segments,
      decision_stage: DecisionStage.ExistingPhoneNumber,
      stage: outbound_message_stages.Queued,
      from_number: fromNumber,
      sending_location_id: sendingLocationId,
      send_after: payload.send_after as unknown as Date | null,
      first_from_to_pair_of_day: true,
    });
  }

  const runtime = Date.now() - before;

  if (statsd !== undefined) {
    try {
      statsd.histogram('worker.process_10dlc_message.run_time', runtime, [
        `profile_id:${result.profile_id}`,
        `sending_location_id:${result.sending_location_id}`,
        `decision_stage:${result.decision_stage}`,
      ]);
    } catch (ex) {
      logger.error('Error posting process-10dlc-message-run', ex);
    }
  }
};
