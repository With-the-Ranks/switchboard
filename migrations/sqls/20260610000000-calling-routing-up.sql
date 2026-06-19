alter table sms.profiles add column daily_calling_limit integer;

alter table sms.phone_number_requests add column for_calling boolean not null default false;

-- Separate pool of numbers reserved for outbound calling only (not used for texting)
create table sms.calling_phone_numbers (
  phone_number phone_number primary key,
  sending_location_id uuid not null references sms.sending_locations(id),
  created_at timestamp not null default now(),
  cordoned_at timestamp,
  released_at timestamp
);

comment on table sms.calling_phone_numbers is E'@omit';

-- Tracks each call routed through the system for daily-limit accounting
create table sms.outbound_calls (
  id uuid not null default uuid_generate_v1mc(),
  from_number phone_number not null,
  sending_location_id uuid not null references sms.sending_locations(id),
  created_at timestamp not null default now()
);

select create_hypertable(
  'sms.outbound_calls',
  'created_at',
  chunk_time_interval => interval '1 day'
);

alter table sms.outbound_calls add primary key (created_at, id);

create index outbound_calls_sending_location_date_idx
  on sms.outbound_calls (sending_location_id, created_at desc);

comment on table sms.outbound_calls is E'@omit';

-- When a phone_number_request with for_calling=true is fulfilled, insert into
-- calling_phone_numbers instead of all_phone_numbers and skip SMS message resolution.
CREATE OR REPLACE FUNCTION sms.tg__phone_number_requests__fulfill() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
  v_throughput_interval interval;
  v_throughput_limit integer;
  v_sending_account_id uuid;
  v_capacity integer;
  v_purchasing_strategy sms.number_purchasing_strategy;
begin
  if NEW.for_calling then
    insert into sms.calling_phone_numbers (sending_location_id, phone_number)
    values (NEW.sending_location_id, NEW.phone_number);
  else
    insert into sms.phone_numbers (sending_location_id, phone_number)
    values (NEW.sending_location_id, NEW.phone_number);
  end if;

  select sending_account_id, throughput_interval, throughput_limit
  from sms.profiles profiles
  join sms.sending_locations locations on locations.profile_id = profiles.id
  where locations.id = NEW.sending_location_id
  into v_sending_account_id, v_throughput_interval, v_throughput_limit;

  -- Update area code capacities
  with update_result as (
    update sms.area_code_capacities
    set capacity = capacity - 1
    where
      area_code = NEW.area_code
      and sending_account_id = v_sending_account_id
    returning capacity
  )
  select capacity
  from update_result
  into v_capacity;

  if ((v_capacity is not null) and (mod(v_capacity, 5) = 0)) then
    select purchasing_strategy
    from sms.sending_locations
    where id = NEW.sending_location_id
    into v_purchasing_strategy;

    if v_purchasing_strategy = 'exact-area-codes' then
      perform sms.refresh_one_area_code_capacity(NEW.area_code, v_sending_account_id);
    elsif v_purchasing_strategy = 'same-state-by-distance' then
      perform sms.queue_find_suitable_area_codes_refresh(NEW.sending_location_id);
    else
      raise exception 'Unknown purchasing strategy: %', v_purchasing_strategy;
    end if;
  end if;

  if not NEW.for_calling then
  -- Process queued outbound messages
    perform graphile_worker.add_job(
      identifier => 'resolve-messages-awaiting-from-number'::text,
      payload => to_json(NEW),
      run_at => clock_timestamp()::timestamp + '10 second'::interval,
      max_attempts => 5
    );

    perform graphile_worker.add_job(
      identifier => 'resolve-messages-awaiting-from-number'::text,
      payload => to_json(NEW),
      run_at => clock_timestamp()::timestamp + '1 minute'::interval,
      max_attempts => 5
    );

    perform graphile_worker.add_job(
      identifier => 'resolve-messages-awaiting-from-number'::text,
      payload => to_json(NEW),
      run_at => clock_timestamp()::timestamp + '5 minute'::interval,
      max_attempts => 5
    );
  end if;

  return NEW;
end;
$$;

-- Shared helper: returns all numbers under the daily limit with their priority and call count.
-- Priority 1 = texting numbers, Priority 2 = calling-only numbers.
create or replace function sms.get_available_calling_numbers(
  v_sending_location_id uuid,
  v_daily_calling_limit integer
) returns table(phone_number phone_number, call_count bigint, priority integer) as $$
  with daily_counts as (
    select from_number, count(*) as call_count
    from sms.outbound_calls
    where sending_location_id = $1
      and created_at > date_trunc('day', now() at time zone 'America/Los_Angeles') at time zone 'UTC'
    group by from_number
  ),
  available_texting as (
    select pn.phone_number, coalesce(dc.call_count, 0) as call_count, 1 as priority
    from sms.phone_numbers pn
    left join daily_counts dc on pn.phone_number = dc.from_number
    where pn.sending_location_id = $1
      and pn.cordoned_at is null
      and coalesce(dc.call_count, 0) < $2
  ),
  available_calling as (
    select cpn.phone_number, coalesce(dc.call_count, 0) as call_count, 2 as priority
    from sms.calling_phone_numbers cpn
    left join daily_counts dc on cpn.phone_number = dc.from_number
    where cpn.sending_location_id = $1
      and cpn.released_at is null
      and cpn.cordoned_at is null
      and coalesce(dc.call_count, 0) < $2
  )
  select * from available_texting
  union all
  select * from available_calling
$$ language sql stable;

