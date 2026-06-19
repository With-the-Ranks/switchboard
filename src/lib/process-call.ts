import { PoolOrPoolClient } from '../db';
import { chooseAreaCodeForSendingLocation } from './process-message';

export const getCallingNumberWithCount = async (
  client: PoolOrPoolClient,
  sendingLocationId: string,
  dailyCallingLimit: number
): Promise<{ fromNumber: string | null; availableCount: number }> => {
  const {
    rows: [row],
  } = await client.query<{ phone_number: string | null; count: string }>(
    `with available as (
       select phone_number, priority, call_count
       from sms.get_available_calling_numbers($1, $2)
     ),
     ranked as (
       select
         first_value(phone_number) over (order by priority, call_count) as phone_number,
         count(*) over () as count
       from available
       limit 1
     )
     select phone_number, count from ranked`,
    [sendingLocationId, dailyCallingLimit]
  );
  return {
    fromNumber: row?.phone_number ?? null,
    availableCount: row?.count ? parseInt(row.count, 10) : 0,
  };
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
