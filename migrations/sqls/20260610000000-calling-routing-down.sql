-- Restore the previous version of the fulfill trigger (without for_calling branching)
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
  -- Create the phone number record
  insert into sms.phone_numbers (
    sending_location_id,
    phone_number
  )
  values (
    NEW.sending_location_id,
    NEW.phone_number
  );

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

  with
    deleted_afn as (
      delete from sms.outbound_messages_awaiting_from_number
      where pending_number_request_id = NEW.id
      returning *
    ),
    interval_waits as (
      select
        id,
        to_number,
        original_created_at,
        sum(estimated_segments) over (partition by 1 order by original_created_at) as nth_segment
      from (
        select id, to_number, estimated_segments, original_created_at
        from deleted_afn
      ) all_messages
    )
    insert into sms.outbound_messages_routing
      (
        id,
        to_number,
        estimated_segments,
        decision_stage,
        sending_location_id,
        pending_number_request_id,
        processed_at,
        original_created_at,
        from_number,
        stage,
        first_from_to_pair_of_day,
        send_after,
        profile_id
      )
    select
        afn.id,
        afn.to_number,
        estimated_segments,
        decision_stage,
        sending_location_id,
        pending_number_request_id,
        processed_at,
        afn.original_created_at,
        NEW.phone_number as from_number,
        'queued' as stage,
        true as first_from_to_pair_of_day,
        now() + ((interval_waits.nth_segment / v_throughput_limit) * v_throughput_interval) as send_after,
        profile_id
    from deleted_afn afn
    join interval_waits on interval_waits.id = afn.id;

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

  return NEW;
end;
$$;

drop table sms.outbound_calls;
drop table sms.calling_phone_numbers;
alter table sms.phone_number_requests drop column for_calling;
alter table sms.profiles drop column daily_calling_limit;
