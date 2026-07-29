drop function sms.send_message;

CREATE OR REPLACE FUNCTION sms.send_message(profile_id uuid, "to" public.phone_number, body text, media_urls public.url[], contact_zip_code public.zip_code DEFAULT NULL::text, send_before timestamp without time zone DEFAULT NULL::timestamp without time zone) RETURNS sms.outbound_messages
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  v_client_id uuid;
  v_profile_id uuid;
  v_profile_active boolean;
  v_contact_zip_code zip_code;
  v_estimated_segments integer;
  v_result sms.outbound_messages;
begin
  select billing.current_client_id() into v_client_id;

  if v_client_id is null then
    raise 'Not authorized';
  end if;

  select id, active
  from sms.profiles
  where client_id = v_client_id
    and id = send_message.profile_id
  into v_profile_id, v_profile_active;

  if v_profile_id is null then
    raise 'Profile % not found – it may not exist, or you may not have access', send_message.profile_id using errcode = 'no_data_found';
  end if;

  if v_profile_active is distinct from true then
    raise 'Profile % is inactive', send_message.profile_id;
  end if;

  if contact_zip_code is null or contact_zip_code = '' then
    select sms.map_area_code_to_zip_code(sms.extract_area_code(send_message.to)) into v_contact_zip_code;
  else
    select contact_zip_code into v_contact_zip_code;
  end if;

  select sms.estimate_segments(body) into v_estimated_segments;

  insert into sms.outbound_messages (profile_id, created_at, to_number, stage, body, media_urls, contact_zip_code, estimated_segments, send_before)
  values (send_message.profile_id, date_trunc('second', now()), send_message.to, 'processing', body, media_urls, v_contact_zip_code, v_estimated_segments, send_message.send_before)
  returning *
  into v_result;

  return v_result;
end;
$$;

ALTER FUNCTION sms.send_message(profile_id uuid, "to" public.phone_number, body text, media_urls public.url[], contact_zip_code public.zip_code, send_before timestamp without time zone) OWNER TO postgres;

GRANT ALL ON FUNCTION sms.send_message(profile_id uuid, "to" public.phone_number, body text, media_urls public.url[], contact_zip_code public.zip_code, send_before timestamp without time zone) TO client;

CREATE OR REPLACE FUNCTION sms.tg__trigger_process_message() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
  v_channel sms.traffic_channel;
  v_job json;
begin
  select coalesce(channel, 'grey-route'::sms.traffic_channel)
  from sms.profiles
  where id = NEW.profile_id
  into v_channel;

  select row_to_json(NEW) into v_job;

  if v_channel = 'grey-route'::sms.traffic_channel then
    perform graphile_worker.add_job(identifier => 'process-grey-route-message', payload => v_job, run_at => null, max_attempts => 5);
  elsif v_channel = 'toll-free'::sms.traffic_channel then
    perform graphile_worker.add_job(identifier => 'process-toll-free-message', payload => v_job, run_at => null, max_attempts => 5);
  elsif v_channel = '10dlc'::sms.traffic_channel then
    perform graphile_worker.add_job(identifier => 'process-10dlc-message', payload => v_job, run_at => null, max_attempts => 5);
  else
    raise 'Unsupported traffic channel %', v_channel;
  end if;

  return NEW;
end;
$$;

alter table sms.outbound_messages drop column send_after;
