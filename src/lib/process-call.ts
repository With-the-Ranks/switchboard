import { PoolOrPoolClient } from '../db';
import { chooseAreaCodeForSendingLocation } from './process-message';

export const getCallingNumberForSendingLocation = async (
  client: PoolOrPoolClient,
  sendingLocationId: string,
  dailyCallingLimit: number
): Promise<string | null> => {
  const {
    rows: [row],
  } = await client.query<{ phone_number: string | null }>(
    `select phone_number
     from sms.get_available_calling_numbers($1, $2)
     order by priority asc, call_count asc
     limit 1`,
    [sendingLocationId, dailyCallingLimit]
  );
  return row?.phone_number ?? null;
};

export const countAvailableCallingNumbers = async (
  client: PoolOrPoolClient,
  sendingLocationId: string,
  dailyCallingLimit: number
): Promise<number> => {
  const {
    rows: [{ count }],
  } = await client.query<{ count: string }>(
    'select count(*) from sms.get_available_calling_numbers($1, $2)',
    [sendingLocationId, dailyCallingLimit]
  );
  return parseInt(count, 10);
};

export const requestCallingNumber = async (
  client: PoolOrPoolClient,
  sendingLocationId: string
): Promise<void> => {
  const { rowCount: pendingCount } = await client.query(
    `select 1 from sms.phone_number_requests
     where sending_location_id = $1 and fulfilled_at is null and for_calling = true
     limit 1`,
    [sendingLocationId]
  );

  if ((pendingCount ?? 0) > 0) {
    return;
  }

  const areaCode = await chooseAreaCodeForSendingLocation(
    client,
    sendingLocationId
  );
  await client.query(
    `insert into sms.phone_number_requests (sending_location_id, area_code, for_calling)
     values ($1, $2, true)`,
    [sendingLocationId, areaCode]
  );
};
