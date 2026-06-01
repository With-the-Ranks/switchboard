import express from 'express';
import { z } from 'zod';

import { pgPool } from '../db';
import { auth, ClientAuthenticatedRequest } from '../lib/auth';
import {
  getFromNumberMapping,
  getNumberForSendingLocation,
} from '../lib/process-message';
import { chooseSendingLocationForContact, getRedis } from '../lib/redis';
import { errToObj, logger } from '../logger';

const app = express();

// tslint:disable-next-line variable-name
const GetNumberForContactQuery = z.object({
  to_number: z.string(),
  profile_id: z.string(),
  contact_zip_code: z.string(),
});

app.get('/get-number-for-contact', auth.client, async (req, res) => {
  const authnReq = req as ClientAuthenticatedRequest;
  const parsed = GetNumberForContactQuery.safeParse(authnReq.query);

  if (!parsed.success) {
    return res.status(400).json({
      error: 'to_number, profile_id, and contact_zip_code are required',
    });
  }

  const {
    to_number,
    profile_id,
    contact_zip_code: contactZipCode,
  } = parsed.data;
  const client = await pgPool.connect();

  try {
    const prevMapping = await getFromNumberMapping(client, {
      toNumber: to_number,
      profileId: profile_id,
    });

    if (prevMapping !== undefined) {
      return res.json({
        from_number: prevMapping.from_number,
      });
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

    const fromNumber = await getNumberForSendingLocation(
      client,
      sendingLocationId
    );

    return res.json({
      from_number: fromNumber,
    });
  } catch (err) {
    logger.error('error in get-number-for-contact: ', errToObj(err));
    const errMessage = err instanceof Error ? err.message : 'unknown';
    return res.status(500).json({ error: errMessage });
  } finally {
    client.release();
  }
});

export default app;
