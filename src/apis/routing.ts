import express from 'express';
import { z } from 'zod';

import config from '../config';
import { pgPool } from '../db';
import { auth, ClientAuthenticatedRequest } from '../lib/auth';
import {
  countAvailableCallingNumbers,
  getCallingNumberForSendingLocation,
  requestCallingNumber,
} from '../lib/process-call';
import { getFromNumberMapping } from '../lib/process-message';
import { chooseSendingLocationForContact, getRedis } from '../lib/redis';
import { errToObj, logger } from '../logger';

const { sendingLocationMinCallingNumbers } = config;

const app = express();

// tslint:disable-next-line variable-name
const GetNumberForContactQuery = z.object({
  to_number: z.string(),
  profile_id: z.string(),
  contact_zip_code: z.string().optional(),
});

app.get('/get-number-for-contact', auth.client, async (req, res) => {
  const authnReq = req as ClientAuthenticatedRequest;
  const parsed = GetNumberForContactQuery.safeParse(authnReq.query);

  if (!parsed.success) {
    return res.status(400).json({
      error: 'to_number and profile_id are required',
    });
  }

  const { to_number, profile_id, contact_zip_code } = parsed.data;
  const client = await pgPool.connect();

  try {
    const {
      rows: [profile],
    } = await client.query<{ daily_calling_limit: number | null }>(
      'select daily_calling_limit from sms.profiles where id = $1',
      [profile_id]
    );

    const { daily_calling_limit } = profile;

    if (!profile || daily_calling_limit === null) {
      return res.status(400).json({
        error:
          'Profile does not have calling configured (daily_calling_limit not set)',
      });
    }

    // Check for an existing sticky mapping for this contact
    const prevMapping = await getFromNumberMapping(client, {
      toNumber: to_number,
      profileId: profile_id,
    });

    if (prevMapping !== undefined) {
      const {
        rows: [{ count }],
      } = await client.query<{ count: string }>(
        `select count(*) from sms.outbound_calls
         where from_number = $1
           and created_at > date_trunc('day', now() at time zone 'America/Los_Angeles') at time zone 'UTC'`,
        [prevMapping.from_number]
      );
      const todayCallCount = parseInt(count, 10);

      if (todayCallCount < daily_calling_limit) {
        await client.query(
          `update sms.from_number_mappings
           set last_used_at = now()
           where profile_id = $1 and to_number = $2 and invalidated_at is null`,
          [profile_id, to_number]
        );
        await client.query(
          `insert into sms.outbound_calls (from_number, sending_location_id, profile_id)
           values ($1, $2, $3)`,
          [prevMapping.from_number, prevMapping.sending_location_id, profile_id]
        );
        return res.json({ from_number: prevMapping.from_number });
      }
      // Mapped number has hit its daily limit — fall through to fresh selection
    }

    let contactZipCode = contact_zip_code;
    if (!contactZipCode) {
      const zipResult = await client.query<{ zip: string }>(
        'select sms.map_area_code_to_zip_code(sms.extract_area_code($1)) as zip',
        [to_number]
      );
      contactZipCode = zipResult.rows[0].zip;
    }

    const env = { redis: getRedis(), pg: client };
    const sendingLocationId = await chooseSendingLocationForContact(
      env,
      profile_id,
      { contactZipCode }
    );

    if (sendingLocationId === undefined) {
      return res
        .status(404)
        .json({ error: 'No sending location found for contact' });
    }

    const fromNumber = await getCallingNumberForSendingLocation(
      client,
      sendingLocationId,
      daily_calling_limit
    );

    if (fromNumber === null) {
      await requestCallingNumber(client, sendingLocationId);
      return res.status(503).json({
        error: 'No calling numbers available, a purchase is being initiated',
      });
    }

    // Record the call (no from_number_mappings insert — calling numbers must not be
    // used as from-numbers for SMS)
    await client.query(
      `insert into sms.outbound_calls (from_number, sending_location_id, profile_id)
       values ($1, $2, $3)`,
      [fromNumber, sendingLocationId, profile_id]
    );

    const availableCount = await countAvailableCallingNumbers(
      client,
      sendingLocationId,
      daily_calling_limit
    );

    if (availableCount <= sendingLocationMinCallingNumbers) {
      await requestCallingNumber(client, sendingLocationId);
    }

    return res.json({ from_number: fromNumber });
  } catch (err) {
    logger.error('error in get-number-for-contact: ', errToObj(err));
    const errMessage = err instanceof Error ? err.message : 'unknown';
    return res.status(500).json({ error: errMessage });
  } finally {
    client.release();
  }
});

export default app;
