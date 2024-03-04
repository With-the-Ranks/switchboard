import { z } from 'zod';

import { PoolOrPoolClient } from '../db';
import { active_previous_mapping_pairings } from './db-types';

// This is just text in the database, but might as well be an enum here
export enum DecisionStage {
  ExistingPendingRequest = 'existing_pending_request',
  ExistingPhoneNumber = 'existing_phone_number',
  NewPendingRequest = 'new_pending_request',
  PrevMapping = 'prev_mapping',
}

// tslint:disable-next-line variable-name
export const ProcessMessagePayloadSchema = z
  .object({
    id: z.string().uuid(),
    created_at: z.string(), // .datetime() https://github.com/colinhacks/zod/issues/2385
    to_number: z.string(),
    profile_id: z.string(),
    contact_zip_code: z.string().length(5),
    estimated_segments: z.number().int(),
  })
  .required();

export type ProcessMessagePayload = z.infer<typeof ProcessMessagePayloadSchema>;

export const getFromNumberMapping = async (
  client: PoolOrPoolClient,
  options: { toNumber: string; profileId: string }
): Promise<active_previous_mapping_pairings | undefined> => {
  const {
    rows: [existingMapping],
  } = await client.query<active_previous_mapping_pairings>(
    `
      select *
      from sms.active_from_number_mappings
      where to_number = $1
        and profile_id = $2
        and (
          cordoned_at is null
          or cordoned_at > now() - interval '3 days'
          or last_used_at > now() - interval '3 days'
        )
      limit 1
    `,
    [options.toNumber, options.profileId]
  );

  return existingMapping;
};

export const getNumberForSendingLocation = async (
  client: PoolOrPoolClient,
  sendingLocationId: string
) => {
  const {
    rows: [fromNumber],
    rowCount,
  } = await client.query<{ phone_number: string }>(
    `
      select pn.phone_number
      from sms.phone_numbers pn
      join sms.sending_locations sl on sl.id = pn.sending_location_id
      where sl.id = $1
      order by random()
      limit 1
    `,
    [sendingLocationId]
  );

  if (rowCount < 1) {
    // TODO: throw new Incorrect10DlcNumberCountError
    throw new Error(`Incorrect10DlcNumberCountError: Sending Location 
    ${sendingLocationId}`);
  }

  return fromNumber.phone_number;
};

export const chooseAreaCodeForSendingLocation = async (
  client: PoolOrPoolClient,
  sendingLocationId: string
): Promise<string> => {
  const {
    rows: [{ choose_area_code_for_sending_location: areaCode }],
  } = await client.query<{
    choose_area_code_for_sending_location: string;
  }>('select * from sms.choose_area_code_for_sending_location($1)', [
    sendingLocationId,
  ]);

  return areaCode;
};

const MILLISECONDS_IN_AN_HOUR = 60 * 60 * 1000;
export const hoursBetweenDates = (a: Date, b: Date) => {
  const diffInMilliseconds = Math.abs(a.getTime() - b.getTime());
  return diffInMilliseconds / MILLISECONDS_IN_AN_HOUR;
};
