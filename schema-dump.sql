--
-- PostgreSQL database dump
--

-- Dumped from database version 14.4 (Ubuntu 14.4-1.pgdg18.04+1)
-- Dumped by pg_dump version 14.4 (Ubuntu 14.4-1.pgdg18.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: billing; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA billing;


ALTER SCHEMA billing OWNER TO postgres;

--
-- Name: geo; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA geo;


ALTER SCHEMA geo OWNER TO postgres;

--
-- Name: lookup; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA lookup;


ALTER SCHEMA lookup OWNER TO postgres;

--
-- Name: sms; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA sms;


ALTER SCHEMA sms OWNER TO postgres;

--
-- Name: worker; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA worker;


ALTER SCHEMA worker OWNER TO postgres;

--
-- Name: pricing_version; Type: TYPE; Schema: billing; Owner: postgres
--

CREATE TYPE billing.pricing_version AS ENUM (
    'v1',
    'v2',
    'byot',
    'other',
    'peoples-action'
);


ALTER TYPE billing.pricing_version OWNER TO postgres;

--
-- Name: usage_type; Type: TYPE; Schema: billing; Owner: postgres
--

CREATE TYPE billing.usage_type AS ENUM (
    'lrn',
    'phone_number',
    'sms_outbound',
    'sms_inbound',
    'mms_outbound',
    'mms_inbound'
);


ALTER TYPE billing.usage_type OWNER TO postgres;

--
-- Name: access_fulfillment_state; Type: TYPE; Schema: lookup; Owner: postgres
--

CREATE TYPE lookup.access_fulfillment_state AS ENUM (
    'done',
    'waiting',
    'fetching'
);


ALTER TYPE lookup.access_fulfillment_state OWNER TO postgres;

--
-- Name: billing_status_enum; Type: TYPE; Schema: lookup; Owner: postgres
--

CREATE TYPE lookup.billing_status_enum AS ENUM (
    'billed',
    'cached'
);


ALTER TYPE lookup.billing_status_enum OWNER TO postgres;

--
-- Name: phone_type_enum; Type: TYPE; Schema: lookup; Owner: postgres
--

CREATE TYPE lookup.phone_type_enum AS ENUM (
    'landline',
    'mobile',
    'voip',
    'unknown',
    'invalid'
);


ALTER TYPE lookup.phone_type_enum OWNER TO postgres;

--
-- Name: request_progress_result; Type: TYPE; Schema: lookup; Owner: postgres
--

CREATE TYPE lookup.request_progress_result AS (
	completed_at timestamp without time zone,
	progress numeric
);


ALTER TYPE lookup.request_progress_result OWNER TO postgres;

--
-- Name: service_option; Type: TYPE; Schema: lookup; Owner: postgres
--

CREATE TYPE lookup.service_option AS ENUM (
    'telnyx'
);


ALTER TYPE lookup.service_option OWNER TO postgres;

--
-- Name: area_code; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.area_code AS text
	CONSTRAINT area_code_check CHECK ((VALUE ~* '[0-9]{3}'::text));


ALTER DOMAIN public.area_code OWNER TO postgres;

--
-- Name: phone_number; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.phone_number AS text
	CONSTRAINT e164 CHECK ((VALUE ~* '\+1[0-9]{10}'::text));


ALTER DOMAIN public.phone_number OWNER TO postgres;

--
-- Name: slug; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.slug AS text
	CONSTRAINT slug_check CHECK ((VALUE ~* '[a-z0-9\-]+'::text));


ALTER DOMAIN public.slug OWNER TO postgres;

--
-- Name: url; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.url AS text
	CONSTRAINT url_check CHECK ((VALUE ~* '(https?:\/\/)?([\w\-])+\.{1}([a-zA-Z]{2,63})([\/\w-]*)*\/?\??([^#\n\r]*)?#?([^\n\r]*)'::text));


ALTER DOMAIN public.url OWNER TO postgres;

--
-- Name: us_state; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.us_state AS text
	CONSTRAINT us_state_check CHECK ((VALUE ~* '[A-Z]{2}'::text));


ALTER DOMAIN public.us_state OWNER TO postgres;

--
-- Name: zip_code; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.zip_code AS text
	CONSTRAINT zip_code_check CHECK ((VALUE ~* '[0-9]{5}'::text));


ALTER DOMAIN public.zip_code OWNER TO postgres;

--
-- Name: bandwidth_credentials; Type: TYPE; Schema: sms; Owner: postgres
--

CREATE TYPE sms.bandwidth_credentials AS (
	account_id text,
	username text,
	encrypted_password text,
	site_id text,
	location_id text,
	application_id text,
	callback_username text,
	callback_encrypted_password text
);


ALTER TYPE sms.bandwidth_credentials OWNER TO postgres;

--
-- Name: delivery_report_event; Type: TYPE; Schema: sms; Owner: postgres
--

CREATE TYPE sms.delivery_report_event AS ENUM (
    'queued',
    'sending',
    'sent',
    'delivered',
    'sending_failed',
    'delivery_failed',
    'delivery_unconfirmed'
);


ALTER TYPE sms.delivery_report_event OWNER TO postgres;

--
-- Name: number_purchasing_strategy; Type: TYPE; Schema: sms; Owner: postgres
--

CREATE TYPE sms.number_purchasing_strategy AS ENUM (
    'exact-area-codes',
    'same-state-by-distance'
);


ALTER TYPE sms.number_purchasing_strategy OWNER TO postgres;

--
-- Name: outbound_message_stages; Type: TYPE; Schema: sms; Owner: postgres
--

CREATE TYPE sms.outbound_message_stages AS ENUM (
    'processing',
    'awaiting-number',
    'queued',
    'sent',
    'failed'
);


ALTER TYPE sms.outbound_message_stages OWNER TO postgres;

--
-- Name: profile_service_option; Type: TYPE; Schema: sms; Owner: postgres
--

CREATE TYPE sms.profile_service_option AS ENUM (
    'twilio',
    'telnyx',
    'bandwidth',
    'tcr',
    'bandwidth-dry-run'
);


ALTER TYPE sms.profile_service_option OWNER TO postgres;

--
-- Name: tcr_credentials; Type: TYPE; Schema: sms; Owner: postgres
--

CREATE TYPE sms.tcr_credentials AS (
	api_key_label text,
	api_key text,
	encrypted_secret text
);


ALTER TYPE sms.tcr_credentials OWNER TO postgres;

--
-- Name: telco_status; Type: TYPE; Schema: sms; Owner: postgres
--

CREATE TYPE sms.telco_status AS ENUM (
    'sent',
    'delivered',
    'failed'
);


ALTER TYPE sms.telco_status OWNER TO postgres;

--
-- Name: telnyx_credentials; Type: TYPE; Schema: sms; Owner: postgres
--

CREATE TYPE sms.telnyx_credentials AS (
	public_key text,
	encrypted_api_key text
);


ALTER TYPE sms.telnyx_credentials OWNER TO postgres;

--
-- Name: traffic_channel; Type: TYPE; Schema: sms; Owner: postgres
--

CREATE TYPE sms.traffic_channel AS ENUM (
    'grey-route',
    'toll-free',
    '10dlc'
);


ALTER TYPE sms.traffic_channel OWNER TO postgres;

--
-- Name: twilio_credentials; Type: TYPE; Schema: sms; Owner: postgres
--

CREATE TYPE sms.twilio_credentials AS (
	account_sid text,
	encrypted_auth_token text
);


ALTER TYPE sms.twilio_credentials OWNER TO postgres;

--
-- Name: backfill_telco_sent_at_around(timestamp without time zone); Type: FUNCTION; Schema: billing; Owner: postgres
--

CREATE FUNCTION billing.backfill_telco_sent_at_around(fire_date timestamp without time zone) RETURNS bigint
    LANGUAGE sql
    AS $$ 
  with update_result as (
    update sms.outbound_messages_telco mt
    set sent_at = mr.processed_at
    from sms.outbound_messages_routing mr
    where mr.id = mt.id
      and mr.processed_at >= date_trunc('hour', fire_date - '1 hour'::interval)
      and mr.processed_at < date_trunc('hour', fire_date)
      and mr.stage <> 'awaiting-number'
    returning 1
  )
  select count(*)
  from update_result
$$;


ALTER FUNCTION billing.backfill_telco_sent_at_around(fire_date timestamp without time zone) OWNER TO postgres;

--
-- Name: current_client_id(); Type: FUNCTION; Schema: billing; Owner: postgres
--

CREATE FUNCTION billing.current_client_id() RETURNS uuid
    LANGUAGE sql STABLE
    SET search_path TO '$user', 'public'
    AS $$
  select current_setting('client.id')::uuid
$$;


ALTER FUNCTION billing.current_client_id() OWNER TO postgres;

--
-- Name: generate_usage_rollups(timestamp without time zone); Type: FUNCTION; Schema: billing; Owner: postgres
--

CREATE FUNCTION billing.generate_usage_rollups(fire_date timestamp without time zone) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
  v_period_end timestamp;
  v_period_start timestamp;
begin
  select
    date_trunc('hour', fire_date) - '1 hour'::interval,
    date_trunc('hour', fire_date)
  into v_period_start, v_period_end;

  -- LRN
  insert into billing.lrn_usage_rollups (client_id, period_start, period_end, lrn)
  select
    lrn_usage.client_id,
    v_period_start,
    v_period_end,
    count(distinct lrn_usage.phone_number)
  from lookup.accesses lrn_usage
  where
    lrn_usage.accessed_at >= v_period_start
    and lrn_usage.accessed_at < v_period_end
    and not exists (
      select 1 from lookup.accesses previous_usage
      where
        previous_usage.accessed_at < v_period_start
        and previous_usage.phone_number = lrn_usage.phone_number
    )
  group by lrn_usage.client_id
  on conflict (client_id, period_start, period_end)
  do nothing;

  -- Messaging
  insert into billing.messaging_usage_rollups (
    profile_id,
    period_start,
    period_end,
    outbound_sms_messages,
    outbound_sms_segments,
    outbound_mms_messages,
    outbound_mms_segments,
    inbound_sms_messages,
    inbound_sms_segments,
    inbound_mms_messages,
    inbound_mms_segments
  )
  select
    coalesce(outbound.profile_id, inbound.profile_id),
    v_period_start,
    v_period_end,
    coalesce(outbound.sms_messages, 0),
    coalesce(outbound.sms_segments, 0),
    coalesce(outbound.mms_messages, 0),
    coalesce(outbound.mms_segments, 0),
    coalesce(inbound.sms_messages, 0),
    coalesce(inbound.sms_segments, 0),
    coalesce(inbound.mms_messages, 0),
    coalesce(inbound.mms_segments, 0)
  from (
    -- gather usage post-split
    select
      ob.profile_id,
      count(*) filter (where mt.num_media = 0) as sms_messages,
      sum(mt.num_segments) filter (where mt.num_media = 0) as sms_segments,
      count(*) filter (where mt.num_media > 0) as mms_messages,
      sum(mt.num_segments) filter (where mt.num_media > 0) as mms_segments
    from sms.outbound_messages ob
    join sms.outbound_messages_telco as mt on mt.id = ob.id
    where true
      and mt.sent_at >= v_period_start
      and mt.sent_at < v_period_end
      and mt.original_created_at >= v_period_start - '1 day'::interval
      and mt.original_created_at < v_period_end + '1 day'::interval
      and ob.created_at >= v_period_start - '1 day'::interval
      and ob.created_at < v_period_end + '1 day'::interval
    group by 1
  ) outbound
  full outer join (
    select
      sl.profile_id,
      count(*) filter (where num_media = 0) as sms_messages,
      sum(num_segments) filter (where num_media = 0) as sms_segments,
      count(*) filter (where num_media > 0) as mms_messages,
      sum(num_segments) filter (where num_media > 0) as mms_segments
    from sms.inbound_messages im
    join sms.sending_locations sl
      on sl.id = im.sending_location_id
    where true
      and received_at >= v_period_start
      and received_at < v_period_end
    group by 1
  ) inbound
    on outbound.profile_id = inbound.profile_id
  on conflict (profile_id, period_start, period_end)
  do nothing;
end;
$$;


ALTER FUNCTION billing.generate_usage_rollups(fire_date timestamp without time zone) OWNER TO postgres;

--
-- Name: inbound_message_usage(uuid, timestamp with time zone); Type: FUNCTION; Schema: billing; Owner: postgres
--

CREATE FUNCTION billing.inbound_message_usage(client uuid, month timestamp with time zone) RETURNS TABLE(client_id uuid, period_start timestamp with time zone, period_end timestamp with time zone, service sms.profile_service_option, sms_segments bigint, mms_segments bigint)
    LANGUAGE plpgsql
    AS $$
declare
  v_month_start timestamptz;
  v_month_end timestamptz;
begin
  select date_trunc('month', month) into v_month_start;
  select date_trunc('month', month + '1 month'::interval) into v_month_end;

  return query
  select
    sms.profiles.client_id,
    v_month_start as period_start,
    v_month_end as period_end,
    sms.sending_accounts.service,
    sum(num_segments) filter (where num_media = 0) as sms_segments,
    sum(num_segments) filter (where num_media > 0) as mms_segments
  from sms.inbound_messages
  join sms.sending_locations
    on sms.sending_locations.id = sms.inbound_messages.sending_location_id
  join sms.profiles
    on sms.profiles.id = sms.sending_locations.profile_id
  join sms.sending_accounts
    on sms.sending_accounts.id = sms.profiles.sending_account_id
  where true
    and sms.profiles.client_id = client
    and sms.inbound_messages.received_at >= v_month_start
    and sms.inbound_messages.received_at < v_month_end
  group by 1, 4
  order by
    sms_segments desc;
end;
$$;


ALTER FUNCTION billing.inbound_message_usage(client uuid, month timestamp with time zone) OWNER TO postgres;

--
-- Name: incremental_rollup_backfill_from(timestamp without time zone, timestamp without time zone); Type: PROCEDURE; Schema: billing; Owner: postgres
--

CREATE PROCEDURE billing.incremental_rollup_backfill_from(IN start_date timestamp without time zone, IN end_date timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
declare
  v_fire_date timestamp;
  v_count_sent bigint;
begin
  v_fire_date := start_date;

  while v_fire_date <= end_date loop 
    raise notice 'Backfilling around %', v_fire_date;

    select billing.backfill_telco_sent_at_around(v_fire_date)
    into v_count_sent;

    perform billing.generate_usage_rollups(v_fire_date);

    raise notice 'Backfilled billing info for % outbound messages', v_count_sent;

    commit;

    v_fire_date := v_fire_date + '1 hour'::interval;
  end loop;
end
$$;


ALTER PROCEDURE billing.incremental_rollup_backfill_from(IN start_date timestamp without time zone, IN end_date timestamp without time zone) OWNER TO postgres;

--
-- Name: lrn_usage(uuid, timestamp with time zone); Type: FUNCTION; Schema: billing; Owner: postgres
--

CREATE FUNCTION billing.lrn_usage(client uuid, month timestamp with time zone) RETURNS TABLE(client_id uuid, period_start timestamp with time zone, period_end timestamp with time zone, lookup_count bigint)
    LANGUAGE plpgsql
    AS $$
declare
  v_month_start timestamptz;
  v_month_end timestamptz;
begin
  select date_trunc('month', month) into v_month_start;
  select date_trunc('month', month + '1 month'::interval) into v_month_end;

  return query
  select
    lookup.accesses.client_id,
    v_month_start as period_start,
    v_month_end as period_end,
    count(distinct lookup.accesses.phone_number) as lookup_count
  from lookup.accesses
  where true
    and lookup.accesses.client_id = lrn_usage.client
    and lookup.accesses.accessed_at >= v_month_start
    and lookup.accesses.accessed_at < v_month_end
    and not exists (
      select 1
      from lookup.accesses as previous_accesses
      where true
        and previous_accesses.client_id = lrn_usage.client
        and previous_accesses.phone_number = lookup.accesses.phone_number
        and previous_accesses.accessed_at < lookup.accesses.accessed_at
    )
  group by 1;
end;
$$;


ALTER FUNCTION billing.lrn_usage(client uuid, month timestamp with time zone) OWNER TO postgres;

--
-- Name: phone_number_usage(uuid, timestamp with time zone); Type: FUNCTION; Schema: billing; Owner: postgres
--

CREATE FUNCTION billing.phone_number_usage(client uuid, month timestamp with time zone) RETURNS TABLE(client_id uuid, period_start timestamp with time zone, period_end timestamp with time zone, service sms.profile_service_option, number_months double precision)
    LANGUAGE plpgsql
    AS $$
declare
  v_month_start timestamptz;
  v_month_end timestamptz;
  v_days_in_month int;
begin
  select date_trunc('month', month) into v_month_start;
  select date_trunc('month', month + '1 month'::interval) into v_month_end;
	select extract(days from v_month_start + '1 month - 1 day'::interval) into v_days_in_month;

  return query
  select
    sms.profiles.client_id,
    v_month_start as period_start,
    v_month_end as period_end,
    sms.sending_accounts.service,
    sum(
      extract(day from least(v_month_end, released_at) - greatest(v_month_start, created_at)) / v_days_in_month::float
    ) as number_months  
  from sms.all_phone_numbers
  join sms.sending_locations
    on sms.sending_locations.id = sms.all_phone_numbers.sending_location_id
  join sms.profiles
    on sms.profiles.id = sms.sending_locations.profile_id
  join sms.sending_accounts
    on sms.sending_accounts.id = sms.profiles.sending_account_id
  where true
    and sms.profiles.client_id = phone_number_usage.client
    and sms.all_phone_numbers.created_at < v_month_end
    and (
      sms.all_phone_numbers.released_at is null
      or sms.all_phone_numbers.released_at >= v_month_start
    )
  group by 1, 4
  order by
    number_months desc;
end;
$$;


ALTER FUNCTION billing.phone_number_usage(client uuid, month timestamp with time zone) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: requests; Type: TABLE; Schema: lookup; Owner: postgres
--

CREATE TABLE lookup.requests (
    id uuid DEFAULT public.uuid_generate_v1mc() NOT NULL,
    client_id uuid DEFAULT billing.current_client_id() NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    closed_at timestamp without time zone,
    completed_at timestamp without time zone
);


ALTER TABLE lookup.requests OWNER TO postgres;

--
-- Name: TABLE requests; Type: COMMENT; Schema: lookup; Owner: postgres
--

COMMENT ON TABLE lookup.requests IS '
@omit update
';


--
-- Name: close_request(uuid); Type: FUNCTION; Schema: lookup; Owner: postgres
--

CREATE FUNCTION lookup.close_request(request_id uuid) RETURNS lookup.requests
    LANGUAGE plpgsql STRICT
    SET search_path TO '$user', 'public'
    AS $$
declare
  v_request_completed boolean;
  v_result lookup.requests;
  v_request_id uuid;
begin
  select request_id into v_request_id;

  select (
    select count(*)
    from lookup.accesses
    where lookup.accesses.request_id = v_request_id
      and state <> 'done'
  ) = 0
  into v_request_completed;

  if v_request_completed then
    update lookup.requests
    set completed_at = now()
    where lookup.requests.id = v_request_id;
  end if;

  update lookup.requests
  set closed_at = now()
  where id = v_request_id;

  select * from lookup.requests
  where id = v_request_id
  into v_result;

  return v_result;
end;
$$;


ALTER FUNCTION lookup.close_request(request_id uuid) OWNER TO postgres;

--
-- Name: request_progress(uuid); Type: FUNCTION; Schema: lookup; Owner: postgres
--

CREATE FUNCTION lookup.request_progress(request_id uuid) RETURNS lookup.request_progress_result
    LANGUAGE plpgsql
    SET search_path TO '$user', 'public'
    AS $$
declare
  v_total_accesses int;
  v_accesses_done int;
  v_completed_at timestamp;
  v_progress numeric;
  v_requests_found int;
begin
  select count(*) from lookup.requests
  where lookup.requests.id = request_progress.request_id
  into v_requests_found;

  if v_requests_found = 0 then
    raise 'No request found' using errcode = 'no_data_found';
  end if;

  select count(*)
  from lookup.accesses
  where lookup.accesses.request_id = request_progress.request_id
  into v_total_accesses;

  select count(*)
  from lookup.accesses
  where state = 'done'
    and lookup.accesses.request_id = request_progress.request_id
  into v_accesses_done;

  select null into v_completed_at;

  if v_total_accesses - v_accesses_done = 0 then
    select now() into v_completed_at;

    update lookup.requests
    set completed_at = v_completed_at
    where lookup.requests.closed_at is not null 
      and lookup.requests.id = request_progress.request_id;
  end if;

  select (
    case when v_total_accesses = 0 then 0
    else v_accesses_done::numeric / v_total_accesses::numeric end
  ) into v_progress;
  return cast(row(v_completed_at, v_progress) as lookup.request_progress_result);
end;
$$;


ALTER FUNCTION lookup.request_progress(request_id uuid) OWNER TO postgres;

--
-- Name: tg__access__fulfill(); Type: FUNCTION; Schema: lookup; Owner: postgres
--

CREATE FUNCTION lookup.tg__access__fulfill() RETURNS trigger
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path TO '$user', 'public'
    AS $$
declare
  v_fresh_record_exists boolean;
  v_already_fetching boolean;
  v_job_json json;
begin
  select exists(
    select 1
    from lookup.fresh_phone_data
    where 
      lookup.fresh_phone_data.phone_number = NEW.phone_number
  ) into v_fresh_record_exists;

  select exists(
    select 1
    from lookup.accesses
    where phone_number = NEW.phone_number
      and state <> 'done'
  ) into v_already_fetching;

  if not (v_fresh_record_exists or v_already_fetching) then
    select json_build_object(
      'access_id', NEW.id,
      'phone_number', NEW.phone_number
    ) into v_job_json;

    perform graphile_worker.add_job(identifier => 'lookup', payload => v_job_json);
  else
    NEW.state = 'done';
  end if;

  return NEW;
end;
$$;


ALTER FUNCTION lookup.tg__access__fulfill() OWNER TO postgres;

--
-- Name: tg__lookup__mark_access_done(); Type: FUNCTION; Schema: lookup; Owner: postgres
--

CREATE FUNCTION lookup.tg__lookup__mark_access_done() RETURNS trigger
    LANGUAGE plpgsql STRICT
    SET search_path TO '$user', 'public'
    AS $$
begin
  update lookup.accesses
  set state = 'done'::lookup.access_fulfillment_state
  where phone_number = NEW.phone_number;

  return NEW;
end;
$$;


ALTER FUNCTION lookup.tg__lookup__mark_access_done() OWNER TO postgres;

--
-- Name: tg__lookup__update_phone_data(); Type: FUNCTION; Schema: lookup; Owner: postgres
--

CREATE FUNCTION lookup.tg__lookup__update_phone_data() RETURNS trigger
    LANGUAGE plpgsql STRICT
    SET search_path TO '$user', 'public'
    AS $$
begin
  insert into lookup.phone_data (phone_number, carrier_name, phone_type)
  values (NEW.phone_number, NEW.carrier_name, NEW.phone_type)
  on conflict (phone_number) do 
    update
    set carrier_name = NEW.carrier_name,
        phone_type = NEW.phone_type,
        last_updated_at = now();
  
  return NEW;
end;
$$;


ALTER FUNCTION lookup.tg__lookup__update_phone_data() OWNER TO postgres;

--
-- Name: add_job_with_sending_account_and_profile_info(text, json, uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_job_with_sending_account_and_profile_info(job_name text, core_payload json, param_sending_location_id uuid DEFAULT NULL::uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO '$user', 'public'
    AS $$
declare
	v_job json;
  v_sending_location_id uuid;
  v_sending_account_json json;
begin
  select coalesce(param_sending_location_id, (core_payload->>'sending_location_id')::uuid)
  into v_sending_location_id;

  select row_to_json(relevant_sending_account_fields)
  from (
    select
      sending_account.id as sending_account_id,
      sending_account.service,
      sending_account.twilio_credentials,
      sending_account.telnyx_credentials,
      sms.profiles.id as profile_id,
      sms.profiles.voice_callback_url as voice_callback_url
    from sms.sending_locations
    join sms.profiles on sms.sending_locations.profile_id = sms.profiles.id
    join sms.sending_accounts_as_json as sending_account
      on sending_account.id = sms.profiles.sending_account_id
    where sms.sending_locations.id = v_sending_location_id
  ) relevant_sending_account_fields
  into v_sending_account_json;

  select core_payload::jsonb || v_sending_account_json::jsonb into v_job;

  perform graphile_worker.add_job(identifier => job_name, payload => v_job);
end;
$$;


ALTER FUNCTION public.add_job_with_sending_account_and_profile_info(job_name text, core_payload json, param_sending_location_id uuid) OWNER TO postgres;

--
-- Name: attach_10dlc_campaign_to_profile(uuid, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.attach_10dlc_campaign_to_profile(profile_id uuid, campaign_identifier text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  v_tendlc_campaign_id uuid;
  v_sending_account_json jsonb;
  v_overallocated_count bigint;
  v_overallocated_sending_location_id uuid;
begin
  with payload as (
    select
      sending_account_id as registrar_account_id,
      attach_10dlc_campaign_to_profile.campaign_identifier as registrar_campaign_id
    from sms.profiles
    where id = attach_10dlc_campaign_to_profile.profile_id
  )
  insert into sms.tendlc_campaigns (registrar_account_id, registrar_campaign_id)
  select registrar_account_id, registrar_campaign_id
  from payload
  returning id
  into v_tendlc_campaign_id;

  update sms.profiles
  set
    tendlc_campaign_id = v_tendlc_campaign_id,
    throughput_limit = 4500, -- from 75 per second
    daily_contact_limit = 3000000 -- 75 per second
  where id = attach_10dlc_campaign_to_profile.profile_id;

  -- cordon all except 1 number per sending location
  update sms.all_phone_numbers
  set cordoned_at = now()
  where sms.all_phone_numbers.id <> (
      select id
      from sms.all_phone_numbers do_not_cordon
      where do_not_cordon.sending_location_id = sms.all_phone_numbers.sending_location_id
      order by phone_number asc
      limit 1
    )
    and sending_location_id in (
      select id
      from sms.sending_locations
      where sms.sending_locations.profile_id = attach_10dlc_campaign_to_profile.profile_id
    );

  with jobs_added as (
    select
      sending_location_id,
      graphile_worker.add_job(identifier => 'associate-service-10dlc-campaign', payload => row_to_json(job_payloads))
    from (
      select
        sa.id as sending_account_id,
        sa.service as service,
        p.id as profile_id,
        p.tendlc_campaign_id,
        p.voice_callback_url,
        sa.twilio_credentials,
        sa.telnyx_credentials,
        pnr.sending_location_id,
        pnr.area_code,
        pnr.created_at,
        pnr.phone_number,
        pnr.commitment_count,
        pnr.service_order_id
      from sms.all_phone_numbers pn
      join sms.phone_number_requests pnr on pn.phone_number = pnr.phone_number
        and pnr.sending_location_id = pn.sending_location_id
      join sms.sending_locations sl on sl.id = pn.sending_location_id
      join sms.profiles p on sl.profile_id = p.id
      join sms.sending_accounts sa on p.sending_account_id = sa.id
      where pn.cordoned_at is null
        and p.id = attach_10dlc_campaign_to_profile.profile_id
    ) job_payloads
  )
  select count(*), sending_location_id
  from jobs_added
  group by 2
  having count(*) > 1
  into v_overallocated_count, v_overallocated_sending_location_id;

  -- if it's 0, that's ok, we'll associate the number when we buy it
  -- if it's more than 1, something went wrong with the above query
  if v_overallocated_count is not null and v_overallocated_sending_location_id is not null then
    raise 'error: too many numbers allocated to 10DLC campaign - % on %',
      v_overallocated_count, v_overallocated_sending_location_id;
  end if;

  return true;
end;
$$;


ALTER FUNCTION public.attach_10dlc_campaign_to_profile(profile_id uuid, campaign_identifier text) OWNER TO postgres;

--
-- Name: sending_account_info(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sending_account_info(sending_location_id uuid) RETURNS TABLE(sending_account_id uuid, service sms.profile_service_option, twilio_credentials sms.twilio_credentials, telnyx_credentials sms.telnyx_credentials)
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path TO '$user', 'public'
    AS $$
begin
  return query
    select
      sending_accounts.id as sending_account_id,
      sending_accounts.service,
      sending_accounts.twilio_credentials,
      sending_accounts.telnyx_credentials
    from sms.sending_locations
    join sms.profiles profiles on sms.sending_locations.profile_id = profiles.id
    join sms.sending_accounts as sending_accounts
      on sending_accounts.id = profiles.sending_account_id
    where sms.sending_locations.id = sending_account_info.sending_location_id;
end;
$$;


ALTER FUNCTION public.sending_account_info(sending_location_id uuid) OWNER TO postgres;

--
-- Name: trigger_forward_delivery_report_with_profile_info(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trigger_forward_delivery_report_with_profile_info() RETURNS trigger
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path TO '$user', 'public'
    AS $$
declare
  v_job json;
  v_profile_id uuid;
  v_profile_json json;
begin
  select row_to_json(NEW) into v_job;

  select profile_id
  from sms.outbound_messages
  where sms.outbound_messages.id = NEW.message_id
    and sms.outbound_messages.created_at > 'now'::timestamp - interval '1 day'
  into v_profile_id;

  select row_to_json(relevant_profile_fields)
  from (
    select
      profiles.id as profile_id,
      clients.access_token as encrypted_client_access_token,
      profiles.message_status_webhook_url,
      profiles.reply_webhook_url
    from sms.profiles 
    join billing.clients as clients on clients.id = profiles.client_id
    where sms.profiles.id = v_profile_id
  ) relevant_profile_fields
  into v_profile_json;

  select v_job::jsonb || v_profile_json::jsonb into v_job;
  perform graphile_worker.add_job('forward-delivery-report', v_job);
  return NEW;
end;
$$;


ALTER FUNCTION public.trigger_forward_delivery_report_with_profile_info() OWNER TO postgres;

--
-- Name: trigger_forward_delivery_report_without_profile_info(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trigger_forward_delivery_report_without_profile_info() RETURNS trigger
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path TO '$user', 'public'
    AS $$
declare
  v_job json;
begin
  select row_to_json(NEW) into v_job;

  perform graphile_worker.add_job(
    'forward-delivery-report',
    v_job,
    max_attempts => 5
  );

  return NEW;
end;
$$;


ALTER FUNCTION public.trigger_forward_delivery_report_without_profile_info() OWNER TO postgres;

--
-- Name: trigger_job(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trigger_job() RETURNS trigger
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path TO '$user', 'public'
    AS $$
declare
  v_job json;
begin
  select row_to_json(NEW) into v_job;
  perform graphile_worker.add_job(identifier => TG_ARGV[0], payload => v_job, run_at => null, max_attempts => 5);
  return NEW;
end;
$$;


ALTER FUNCTION public.trigger_job() OWNER TO postgres;

--
-- Name: trigger_job_with_profile_info(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trigger_job_with_profile_info() RETURNS trigger
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path TO '$user', 'public'
    AS $$
declare
  v_job json;
  v_sending_location_id uuid;
  v_profile_json json;
begin
  select row_to_json(NEW) into v_job;

  select row_to_json(relevant_profile_fields)
  from (
    select
      profiles.id as profile_id,
      clients.access_token as encrypted_client_access_token,
      sms.sending_locations.id as sending_location_id,
      profiles.message_status_webhook_url,
      profiles.reply_webhook_url
    from sms.sending_locations
    join sms.profiles as profiles on profiles.id = sms.sending_locations.profile_id
    join billing.clients as clients on clients.id = profiles.client_id
    where sms.sending_locations.id = NEW.sending_location_id
  ) relevant_profile_fields
  into v_profile_json;

  select v_job::jsonb || v_profile_json::jsonb into v_job;
  perform graphile_worker.add_job(identifier => TG_ARGV[0], payload => v_job, run_at => null, max_attempts => 8);
  return NEW;
end;
$$;


ALTER FUNCTION public.trigger_job_with_profile_info() OWNER TO postgres;

--
-- Name: trigger_job_with_sending_account_and_profile_info(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trigger_job_with_sending_account_and_profile_info() RETURNS trigger
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path TO '$user', 'public'
    AS $$
declare
  v_job json;
  v_sending_location_id uuid;
  v_sending_account_json json;
begin
  select row_to_json(NEW) into v_job;

  if TG_TABLE_NAME = 'sending_locations' then
    v_sending_location_id := NEW.id;
  else
    v_sending_location_id := NEW.sending_location_id;
  end if;

	perform add_job_with_sending_account_and_profile_info(TG_ARGV[0], v_job, v_sending_location_id);
  return NEW;
end;
$$;


ALTER FUNCTION public.trigger_job_with_sending_account_and_profile_info() OWNER TO postgres;

--
-- Name: trigger_job_with_sending_account_info(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trigger_job_with_sending_account_info() RETURNS trigger
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path TO '$user', 'public'
    AS $$
declare
  v_job json;
  v_sending_account_json json;
begin
  select row_to_json(NEW) into v_job;

  if TG_TABLE_NAME = 'sending_locations' then
    v_sending_account_json := to_json(sending_account_info(NEW.id));
  else
    v_sending_account_json := to_json(sending_account_info(NEW.sending_location_id));
  end if;

  select v_job::jsonb || v_sending_account_json::jsonb into v_job;
  perform graphile_worker.add_job(identifier => TG_ARGV[0], payload => v_job, run_at => null, max_attempts => 5);
  return NEW;
end;
$$;


ALTER FUNCTION public.trigger_job_with_sending_account_info() OWNER TO postgres;

--
-- Name: trigger_sell_number(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trigger_sell_number() RETURNS trigger
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path TO '$user', 'public'
    AS $$
declare
  v_job json;
  v_sending_account_json json;
begin
  -- This check prevents this trigger from running as the result of 
  -- decomissioning a sending location
  -- Instead, this trigger is only for directly releasing specific phone number(s)
  if pg_trigger_depth() > 1 then
    return NEW;
  end if;

  select row_to_json(NEW) into v_job;

  select row_to_json(relevant_sending_account_fields)
  from (
    select sending_account.id as sending_account_id, sending_account.service, sending_account.twilio_credentials, sending_account.telnyx_credentials
      from sms.sending_locations
      join sms.profiles on sms.sending_locations.profile_id = sms.profiles.id
      join sms.sending_accounts_as_json as sending_account
        on sending_account.id = sms.profiles.sending_account_id
    where sms.sending_locations.id = NEW.sending_location_id
  ) relevant_sending_account_fields
  into v_sending_account_json;

  delete from sms.fresh_phone_commitments
  where
    phone_number = NEW.phone_number
    and sending_location_id = NEW.sending_location_id;

  select v_job::jsonb || v_sending_account_json::jsonb into v_job;
  perform graphile_worker.add_job('sell-number', v_job, max_attempts => 5);
  return NEW;
end;
$$;


ALTER FUNCTION public.trigger_sell_number() OWNER TO postgres;

--
-- Name: universal_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.universal_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  NEW.updated_at = CURRENT_TIMESTAMP;
  return NEW;
end;
$$;


ALTER FUNCTION public.universal_updated_at() OWNER TO postgres;

--
-- Name: backfill_commitment_buckets(); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.backfill_commitment_buckets() RETURNS void
    LANGUAGE sql
    AS $$
  with values_to_write as (
    select
      from_number,
      count(distinct to_number) as commitment,
      sending_location_id
    from sms.outbound_messages
    where processed_at > date_trunc('day', current_timestamp at time zone 'Pacific/Honolulu')
          -- can safely limit created_at since only those are relevant buckets
      and processed_at is not null
      and from_number is not null
      and stage <> 'awaiting-number'
    group by 1, 3
  )
  insert into sms.fresh_phone_commitments (
    phone_number,
    commitment,
    sending_location_id
  )
  select
    values_to_write.from_number as phone_number,
    values_to_write.commitment,
    values_to_write.sending_location_id
  from values_to_write
  join sms.phone_numbers phone_numbers on phone_numbers.phone_number = values_to_write.from_number
    and phone_numbers.sending_location_id = values_to_write.sending_location_id
  on conflict (phone_number)
  do update
  set commitment = excluded.commitment
$$;


ALTER FUNCTION sms.backfill_commitment_buckets() OWNER TO postgres;

--
-- Name: FUNCTION backfill_commitment_buckets(); Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON FUNCTION sms.backfill_commitment_buckets() IS '@omit';


--
-- Name: backfill_telco_profile_id(timestamp without time zone); Type: PROCEDURE; Schema: sms; Owner: postgres
--

CREATE PROCEDURE sms.backfill_telco_profile_id(IN starting_day timestamp without time zone DEFAULT NULL::timestamp without time zone)
    LANGUAGE plpgsql
    AS $$ 
declare
  v_day timestamp;
  v_updated_count bigint;
begin
  if starting_day is null then
    select date_trunc('day', min(created_at))
    from sms.outbound_messages
    into v_day;
  else
    select starting_day
    into v_day;
  end if;

  while v_day < 'now' loop
    with update_result as (
      update sms.outbound_messages_telco telco
      set profile_id = main.profile_id
      from sms.outbound_messages main
      where main.id = telco.id
        and main.created_at = telco.original_created_at
        and main.created_at >= date_trunc('day', v_day)
        and main.created_at < date_trunc('day', v_day) + '1 day'::interval
        and main.original_created_at >= date_trunc('day', v_day)
        and main.original_created_at < date_trunc('day', v_day) + '1 day'::interval
      returning 1
    )
    select count(*)
    from update_result
    into v_updated_count;

    raise notice 'Updated %s messages on %s', v_updated_count, v_day;

    select v_day + '1 day'::interval
    into v_day;
  end loop;
end; $$;


ALTER PROCEDURE sms.backfill_telco_profile_id(IN starting_day timestamp without time zone) OWNER TO postgres;

--
-- Name: PROCEDURE backfill_telco_profile_id(IN starting_day timestamp without time zone); Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON PROCEDURE sms.backfill_telco_profile_id(IN starting_day timestamp without time zone) IS '@omit';


--
-- Name: cascade_sending_location_decomission(); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.cascade_sending_location_decomission() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
  v_sending_account_json json;
begin
  select row_to_json(relevant_sending_account_fields)
  from (
    select sending_account.id as sending_account_id, sending_account.service, sending_account.twilio_credentials, sending_account.telnyx_credentials
      from sms.sending_locations
      join sms.profiles on sms.sending_locations.profile_id = sms.profiles.id
      join sms.sending_accounts_as_json as sending_account
        on sending_account.id = sms.profiles.sending_account_id
    where sms.sending_locations.id = NEW.id
  ) relevant_sending_account_fields
  into v_sending_account_json;

  perform graphile_worker.add_job(
    'sell-number', 
    payload := (job::jsonb || v_sending_account_json::jsonb)::json, 
    max_attempts := 5, 
    run_at := now() + n * '1 second'::interval
  )
  from (
    select row_to_json(pn) as job, row_number() over (partition by 1) as n
    from sms.all_phone_numbers pn
    where pn.sending_location_id = NEW.id
      and released_at is null
  ) numbers;

  update sms.all_phone_numbers
  set released_at = NEW.decomissioned_at
  where sms.all_phone_numbers.sending_location_id = NEW.id
    and released_at is null;

  delete from sms.fresh_phone_commitments
  where sending_location_id = NEW.id;

  return NEW;
end;
$$;


ALTER FUNCTION sms.cascade_sending_location_decomission() OWNER TO postgres;

--
-- Name: choose_area_code_for_sending_location(uuid); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.choose_area_code_for_sending_location(sending_location_id uuid) RETURNS public.area_code
    LANGUAGE sql
    AS $$
  select area_code from (
    select area_code_options.area_code, capacity
    from (
      select unnest(area_codes) as area_code
      from sms.sending_locations
      where sms.sending_locations.id = sending_location_id
    ) area_code_options
    left join sms.area_code_capacities
      on sms.area_code_capacities.area_code = area_code_options.area_code
    order by capacity desc, area_code_options.area_code desc
    limit 1
  ) area_code_with_most_capacity
$$;


ALTER FUNCTION sms.choose_area_code_for_sending_location(sending_location_id uuid) OWNER TO postgres;

--
-- Name: FUNCTION choose_area_code_for_sending_location(sending_location_id uuid); Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON FUNCTION sms.choose_area_code_for_sending_location(sending_location_id uuid) IS '@omit';


--
-- Name: choose_existing_available_number(uuid[], integer, integer); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.choose_existing_available_number(sending_location_id_options uuid[], profile_daily_contact_limit integer DEFAULT 200, profile_throughput_limit integer DEFAULT 6) RETURNS public.phone_number
    LANGUAGE plpgsql
    AS $$
declare
  v_phone_number phone_number;
begin
  -- First, check for numbers not texted today
  select phone_number
  from sms.phone_numbers
  where sending_location_id = ANY(sending_location_id_options)
    and cordoned_at is null
    and not exists (
      select 1
      from sms.fresh_phone_commitments
      where sms.fresh_phone_commitments.phone_number = sms.phone_numbers.phone_number
    )
  into v_phone_number;

  if v_phone_number is not null then
    return v_phone_number;
  end if;

  -- Next, find the one least texted not currently overloaded and not cordoned
  with recent_segment_counts as (
    select sum(estimated_segments) as estimated_segments, from_number
    from sms.outbound_messages_routing
    where processed_at > 'now'::timestamp - '1 minute'::interval
      and stage <> 'awaiting-number'
      and original_created_at > date_trunc('day', 'now'::timestamp)
    group by sms.outbound_messages_routing.from_number
  )
  select phone_number
  from sms.fresh_phone_commitments
  where sending_location_id = ANY(sending_location_id_options)
    and commitment <= profile_daily_contact_limit
    and phone_number not in (
      select from_number
      from recent_segment_counts
      where estimated_segments >= profile_throughput_limit
    )
    -- Check that this phone number isn't cordoned
    and not exists (
      select 1
      from sms.phone_numbers
      where sms.phone_numbers.phone_number = sms.fresh_phone_commitments.phone_number
        and not (cordoned_at is null)
    )
  order by commitment
  for update skip locked
  limit 1
  into v_phone_number;

  if v_phone_number is not null then
    return v_phone_number;
  end if;

  return null;
end;
$$;


ALTER FUNCTION sms.choose_existing_available_number(sending_location_id_options uuid[], profile_daily_contact_limit integer, profile_throughput_limit integer) OWNER TO postgres;

--
-- Name: FUNCTION choose_existing_available_number(sending_location_id_options uuid[], profile_daily_contact_limit integer, profile_throughput_limit integer); Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON FUNCTION sms.choose_existing_available_number(sending_location_id_options uuid[], profile_daily_contact_limit integer, profile_throughput_limit integer) IS '@omit';


--
-- Name: choose_sending_location_for_contact(public.zip_code, uuid); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.choose_sending_location_for_contact(contact_zip_code public.zip_code, profile_id uuid) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
declare
  v_sending_location_id uuid;
  v_from_number phone_number;
  v_contact_state text;
  v_contact_location point;
begin
  select state
  from geo.zip_locations
  where zip = contact_zip_code
  into v_contact_state;

  select location
  from geo.zip_locations
  where zip = contact_zip_code
  into v_contact_location;

  if v_contact_location is not null then
  -- Find the closest one in the same state
    select id
    from sms.sending_locations
    where state = v_contact_state
      and sms.sending_locations.profile_id = choose_sending_location_for_contact.profile_id
      and decomissioned_at is null
    order by location <-> v_contact_location asc
    limit 1
    into v_sending_location_id;

    if v_sending_location_id is not null then
      return v_sending_location_id;
    end if;

    -- Find the next closest one
    select id
    from sms.sending_locations
    where sms.sending_locations.profile_id = choose_sending_location_for_contact.profile_id
      and decomissioned_at is null
    order by location <-> v_contact_location asc
    limit 1
    into v_sending_location_id;

    if v_sending_location_id is not null then
      return v_sending_location_id;
    end if;
  end if;

  -- Pick one with available phone numbers
  select sms.choose_existing_available_number(array_agg(id))
  from sms.sending_locations
  where sms.sending_locations.profile_id = choose_sending_location_for_contact.profile_id
    and sms.sending_locations.decomissioned_at is null
  into v_from_number;

  if v_from_number is not null then
    select sending_location_id
    from sms.phone_numbers
    where sms.phone_numbers.phone_number = v_from_number
    into v_sending_location_id;

    return v_sending_location_id;
  end if;

  -- Pick a random one
  select id
  from sms.sending_locations
  where sms.sending_locations.profile_id = choose_sending_location_for_contact.profile_id
    and sms.sending_locations.decomissioned_at is null
  order by random()
  limit 1
  into v_sending_location_id;

  return v_sending_location_id;
end;
$$;


ALTER FUNCTION sms.choose_sending_location_for_contact(contact_zip_code public.zip_code, profile_id uuid) OWNER TO postgres;

--
-- Name: FUNCTION choose_sending_location_for_contact(contact_zip_code public.zip_code, profile_id uuid); Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON FUNCTION sms.choose_sending_location_for_contact(contact_zip_code public.zip_code, profile_id uuid) IS '@omit';


--
-- Name: compute_sending_location_capacity(uuid); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.compute_sending_location_capacity(sending_location_id uuid) RETURNS integer
    LANGUAGE sql
    AS $$
  with sending_location_info as (
    select sms.profiles.sending_account_id, sms.sending_locations.area_codes
    from sms.sending_locations
    join sms.profiles on sms.sending_locations.profile_id = sms.profiles.id
    where sms.sending_locations.id = compute_sending_location_capacity.sending_location_id
    limit 1
  )
  select sum(capacity)::integer
  from sms.area_code_capacities
  where sms.area_code_capacities.sending_account_id = (
      select sending_account_id
      from sending_location_info
    )
    and area_code in ( 
      select unnest(area_codes)
      from sending_location_info
    )
$$;


ALTER FUNCTION sms.compute_sending_location_capacity(sending_location_id uuid) OWNER TO postgres;

--
-- Name: FUNCTION compute_sending_location_capacity(sending_location_id uuid); Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON FUNCTION sms.compute_sending_location_capacity(sending_location_id uuid) IS '@omit';


--
-- Name: cordon_from_number_mappings(); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.cordon_from_number_mappings() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  update sms.from_number_mappings 
  set cordoned_at = NEW.cordoned_at
  where from_number = NEW.phone_number
    and invalidated_at is null;

  return NEW;
end;
$$;


ALTER FUNCTION sms.cordon_from_number_mappings() OWNER TO postgres;

--
-- Name: estimate_segments(text); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.estimate_segments(body text) RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$
  select char_length(body) / 153 + 1
$$;


ALTER FUNCTION sms.estimate_segments(body text) OWNER TO postgres;

--
-- Name: FUNCTION estimate_segments(body text); Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON FUNCTION sms.estimate_segments(body text) IS '@omit';


--
-- Name: extract_area_code(public.phone_number); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.extract_area_code(phone_number public.phone_number) RETURNS public.area_code
    LANGUAGE sql
    AS $$
  select substring(phone_number from 3 for 3)::area_code
$$;


ALTER FUNCTION sms.extract_area_code(phone_number public.phone_number) OWNER TO postgres;

--
-- Name: FUNCTION extract_area_code(phone_number public.phone_number); Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON FUNCTION sms.extract_area_code(phone_number public.phone_number) IS '@omit';


--
-- Name: increment_commitment_bucket_if_unique(); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.increment_commitment_bucket_if_unique() RETURNS trigger
    LANGUAGE plpgsql STRICT
    AS $$
declare
  v_commitment_phone phone_number;
begin
  update sms.fresh_phone_commitments
  set commitment = commitment + 1
  where phone_number = NEW.from_number
  returning phone_number
  into v_commitment_phone;

  if v_commitment_phone is null then
    insert into sms.fresh_phone_commitments (
      phone_number,
      commitment,
      sending_location_id
    )
    select
      NEW.from_number,
      1,
      NEW.sending_location_id
    from sms.profiles
    where
      id = (
        select profile_id from sms.sending_locations where id = NEW.sending_location_id
      )
    on conflict (phone_number) do update
      set commitment = sms.fresh_phone_commitments.commitment + 1;
  end if;

  return NEW;
end;
$$;


ALTER FUNCTION sms.increment_commitment_bucket_if_unique() OWNER TO postgres;

--
-- Name: invalidate_from_number_mappings(); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.invalidate_from_number_mappings() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  update sms.from_number_mappings 
  set invalidated_at = NEW.released_at
  where from_number = NEW.phone_number
    and invalidated_at is null;

  return NEW;
end;
$$;


ALTER FUNCTION sms.invalidate_from_number_mappings() OWNER TO postgres;

--
-- Name: map_area_code_to_zip_code(public.area_code); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.map_area_code_to_zip_code(area_code public.area_code) RETURNS public.zip_code
    LANGUAGE sql
    AS $$
  select zip
  from geo.zip_area_codes
  where geo.zip_area_codes.area_code = map_area_code_to_zip_code.area_code
  limit 1
$$;


ALTER FUNCTION sms.map_area_code_to_zip_code(area_code public.area_code) OWNER TO postgres;

--
-- Name: FUNCTION map_area_code_to_zip_code(area_code public.area_code); Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON FUNCTION sms.map_area_code_to_zip_code(area_code public.area_code) IS '@omit';


--
-- Name: outbound_messages; Type: TABLE; Schema: sms; Owner: postgres
--

CREATE TABLE sms.outbound_messages (
    id uuid DEFAULT public.uuid_generate_v1mc() NOT NULL,
    created_at timestamp without time zone DEFAULT date_trunc('second'::text, now()) NOT NULL,
    contact_zip_code public.zip_code NOT NULL,
    stage sms.outbound_message_stages NOT NULL,
    to_number public.phone_number NOT NULL,
    body text NOT NULL,
    media_urls public.url[],
    estimated_segments integer DEFAULT 1,
    profile_id uuid,
    send_before timestamp without time zone
)
WITH (autovacuum_vacuum_threshold='50000', autovacuum_vacuum_scale_factor='0', autovacuum_vacuum_cost_limit='1000', autovacuum_vacuum_cost_delay='0');


ALTER TABLE sms.outbound_messages OWNER TO postgres;

--
-- Name: TABLE outbound_messages; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON TABLE sms.outbound_messages IS '@omit';


--
-- Name: process_10dlc_message(sms.outbound_messages, interval); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.process_10dlc_message(message sms.outbound_messages, prev_mapping_validity_interval interval DEFAULT '14 days'::interval) RETURNS json
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  v_channel sms.traffic_channel;
  v_sending_location_id uuid;
  v_prev_mapping_from_number phone_number;
  v_prev_mapping_created_at timestamp;
  v_prev_mapping_first_send_of_day boolean;
  v_from_number phone_number;
  v_result record;
begin
  select channel
  from sms.profiles
  where id = message.profile_id
  limit 1
  into
      v_channel
    , v_from_number;

  if v_channel <> '10dlc' then
    raise exception 'Profile is not 10dlc channel: %', message.profile_id;
  end if;


  -- Check for majority case of a repeat message, getting v_sending_location_id and from_number, insert and return
  select from_number, last_used_at, sending_location_id
  from sms.active_from_number_mappings
  where to_number = message.to_number
    and profile_id = message.profile_id
    and (
      cordoned_at is null
      or cordoned_at > now() - interval '3 days'
      or last_used_at > now() - interval '3 days'
    )
  limit 1
  into v_prev_mapping_from_number, v_prev_mapping_created_at, v_sending_location_id;

  if v_prev_mapping_from_number is not null then
    select
      v_prev_mapping_created_at <
      date_trunc('day', current_timestamp at time zone 'Pacific/Honolulu')
    into v_prev_mapping_first_send_of_day;

    insert into sms.outbound_messages_routing (
      id,
      original_created_at,
      from_number,
      to_number,
      stage,
      sending_location_id,
      decision_stage,
      processed_at,
      first_from_to_pair_of_day,
      profile_id
    )
    values (
      message.id,
      message.created_at,
      v_prev_mapping_from_number,
      message.to_number,
      'queued',
      v_sending_location_id,
      'prev_mapping',
      now(),
      v_prev_mapping_first_send_of_day,
      message.profile_id
    )
    returning *
    into v_result;

    return row_to_json(v_result);
  end if;

  -- If we're here, it's a number we haven't seen before
  select sms.choose_sending_location_for_contact(message.contact_zip_code, message.profile_id)
  into v_sending_location_id;

  if v_sending_location_id is null then
    raise 'Must create a sending location before sending messages';
  end if;

  -- We expect exactly one phone number per sending location
  select pn.phone_number
  from sms.phone_numbers pn
  join sms.sending_locations sl on sl.id = pn.sending_location_id
  where sl.id = v_sending_location_id
  limit 1
  into v_from_number;

  if v_from_number is null then
    raise exception 'No 10dlc number for profile: %, sending location %', message.profile_id, v_sending_location_id;
  end if;

  insert into sms.outbound_messages_routing (
      id
    , original_created_at
    , from_number
    , to_number
    , stage
    , sending_location_id
    , decision_stage
    , processed_at
    , profile_id
  )
  values (
      message.id
    , message.created_at
    , v_from_number
    , message.to_number
    , 'queued'
    , v_sending_location_id
    , 'prev_mapping'
    , now()
    , message.profile_id
  )
  returning *
  into v_result;

  return row_to_json(v_result);
end;
$$;


ALTER FUNCTION sms.process_10dlc_message(message sms.outbound_messages, prev_mapping_validity_interval interval) OWNER TO postgres;

--
-- Name: FUNCTION process_10dlc_message(message sms.outbound_messages, prev_mapping_validity_interval interval); Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON FUNCTION sms.process_10dlc_message(message sms.outbound_messages, prev_mapping_validity_interval interval) IS '@omit';


--
-- Name: process_toll_free_message(sms.outbound_messages, interval); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.process_toll_free_message(message sms.outbound_messages, prev_mapping_validity_interval interval DEFAULT '14 days'::interval) RETURNS json
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  v_channel sms.traffic_channel;
  v_sending_location_id uuid;
  v_from_number phone_number;
  v_result record;
begin
  select
      p.channel
    , sl.id
    , pn.phone_number
  from sms.phone_numbers pn
  join sms.sending_locations sl on sl.id = pn.sending_location_id
  join sms.profiles p on p.id = sl.profile_id
  where sl.profile_id = message.profile_id
  into
      v_channel
    , v_sending_location_id
    , v_from_number;

  if v_channel <> 'toll-free' then
    raise exception 'Profile is not toll-free channel: %', message.profile_id;
  end if;

  if v_sending_location_id is null or v_from_number is null then
    raise exception 'No toll-free number for profile: %', message.profile_id;
  end if;

  insert into sms.outbound_messages_routing (
      id
    , original_created_at
    , from_number
    , to_number
    , stage
    , sending_location_id
    , decision_stage
    , processed_at
    , profile_id
  )
  values (
      message.id
    , message.created_at
    , v_from_number
    , message.to_number
    , 'queued'
    , v_sending_location_id
    , 'toll_free'
    , now()
    , message.profile_id
  )
  returning *
  into v_result;

  return row_to_json(v_result);
end;
$$;


ALTER FUNCTION sms.process_toll_free_message(message sms.outbound_messages, prev_mapping_validity_interval interval) OWNER TO postgres;

--
-- Name: FUNCTION process_toll_free_message(message sms.outbound_messages, prev_mapping_validity_interval interval); Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON FUNCTION sms.process_toll_free_message(message sms.outbound_messages, prev_mapping_validity_interval interval) IS '@omit';


--
-- Name: queue_find_suitable_area_codes_refresh(uuid); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.queue_find_suitable_area_codes_refresh(sending_location_id uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
  perform graphile_worker.add_job(identifier => 'find-suitable-area-codes', payload => row_to_json(all_area_code_capacity_job_info))
  from (
    select
      sms.sending_locations.*,
      sms.sending_accounts.id as sending_account_id,
      sms.sending_accounts.service,
      sms.sending_accounts.twilio_credentials,
      sms.sending_accounts.telnyx_credentials
    from sms.sending_locations
    join sms.profiles
      on sms.sending_locations.profile_id = sms.profiles.id
    join sms.sending_accounts
      on sms.sending_accounts.id = sms.profiles.sending_account_id
    where sms.sending_locations.id = sending_location_id
    limit 1
  ) as all_area_code_capacity_job_info;
end;
$$;


ALTER FUNCTION sms.queue_find_suitable_area_codes_refresh(sending_location_id uuid) OWNER TO postgres;

--
-- Name: FUNCTION queue_find_suitable_area_codes_refresh(sending_location_id uuid); Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON FUNCTION sms.queue_find_suitable_area_codes_refresh(sending_location_id uuid) IS '@omit';


--
-- Name: refresh_area_code_capacity_estimates(); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.refresh_area_code_capacity_estimates() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
  perform graphile_worker.add_job(identifier => 'estimate-area-code-capacity', payload => row_to_json(all_area_code_capacity_job_info))
  from (
    select
      sms.area_code_capacities.sending_account_id,
      ARRAY[sms.area_code_capacities.area_code] as area_codes,
      sms.sending_accounts.service,
      sms.sending_accounts.twilio_credentials,
      sms.sending_accounts.telnyx_credentials
    from sms.area_code_capacities
    join sms.sending_accounts
      on sms.sending_accounts.id = sms.area_code_capacities.sending_account_id
  ) as all_area_code_capacity_job_info;
end;
$$;


ALTER FUNCTION sms.refresh_area_code_capacity_estimates() OWNER TO postgres;

--
-- Name: FUNCTION refresh_area_code_capacity_estimates(); Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON FUNCTION sms.refresh_area_code_capacity_estimates() IS '@omit';


--
-- Name: refresh_one_area_code_capacity(public.area_code, uuid); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.refresh_one_area_code_capacity(area_code public.area_code, sending_account_id uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
  perform graphile_worker.add_job(identifier => 'estimate-area-code-capacity', payload => row_to_json(all_area_code_capacity_job_info))
  from (
    select
      sms.area_code_capacities.sending_account_id,
      ARRAY[sms.area_code_capacities.area_code] as area_codes,
      sms.sending_accounts.service,
      sms.sending_accounts.twilio_credentials,
      sms.sending_accounts.telnyx_credentials
    from sms.area_code_capacities
    join sms.sending_accounts
      on sms.sending_accounts.id = sms.area_code_capacities.sending_account_id
    where sms.sending_accounts.id = refresh_one_area_code_capacity.sending_account_id
      and sms.area_code_capacities.area_code = refresh_one_area_code_capacity.area_code
  ) as all_area_code_capacity_job_info;
end;
$$;


ALTER FUNCTION sms.refresh_one_area_code_capacity(area_code public.area_code, sending_account_id uuid) OWNER TO postgres;

--
-- Name: FUNCTION refresh_one_area_code_capacity(area_code public.area_code, sending_account_id uuid); Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON FUNCTION sms.refresh_one_area_code_capacity(area_code public.area_code, sending_account_id uuid) IS '@omit';


--
-- Name: reset_sending_location_state_and_locations(); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.reset_sending_location_state_and_locations() RETURNS void
    LANGUAGE sql
    AS $$
  update sms.sending_locations
  set
    state = geo.zip_locations.state,
    location = geo.zip_locations.location
  from geo.zip_locations
  where sms.sending_locations.center = geo.zip_locations.zip;
$$;


ALTER FUNCTION sms.reset_sending_location_state_and_locations() OWNER TO postgres;

--
-- Name: FUNCTION reset_sending_location_state_and_locations(); Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON FUNCTION sms.reset_sending_location_state_and_locations() IS '@omit';


--
-- Name: resolve_delivery_reports(interval, interval, timestamp without time zone, interval); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.resolve_delivery_reports(as_far_back_as interval, as_recent_as interval, fire_date timestamp without time zone DEFAULT now(), send_delay_window interval DEFAULT '1 day'::interval) RETURNS bigint
    LANGUAGE plpgsql STRICT
    AS $$
declare
  v_result bigint;
begin
  with
    matched as (
      select
        dr.*,
        telco.id as message_id,
        telco.original_created_at as original_created_at,
        telco.profile_id as profile_id,
        (
          coalesce(dr.extra, '{}'::json)::jsonb || json_build_object(
            'num_segments', telco.num_segments,
            'num_media', telco.num_media
          )::jsonb
        )::json as combined_extra
      from sms.unmatched_delivery_reports dr
      join sms.outbound_messages_telco telco on telco.service_id = dr.message_service_id
      where telco.original_created_at > fire_date - send_delay_window
    ),
    do_delete as (
      delete from sms.unmatched_delivery_reports
      where message_service_id in ( select message_service_id from matched )
      returning 1
    ),
    do_insert as (
      insert into sms.delivery_reports (
        message_id, message_service_id, event_type, generated_at,
        created_at, service, validated, error_codes, extra
      )
      select
        message_id, message_service_id, event_type, generated_at,
        created_at, service, validated, error_codes, extra
      from matched
      returning 1
    ),
    payloads as (
      select
        matched.message_service_id,
        matched.message_id,
        matched.event_type,
        matched.generated_at,
        matched.created_at,
        matched.service,
        matched.validated,
        matched.error_codes,
        matched.original_created_at,
        matched.profile_id as profile_id,
        clients.access_token as encrypted_client_access_token,
        profiles.message_status_webhook_url,
        profiles.reply_webhook_url,
        matched.combined_extra as extra
      from matched
      join sms.profiles as profiles on profiles.id = matched.profile_id
      join billing.clients as clients on clients.id = profiles.client_id
    ),
    job_insert_result as (
      select graphile_worker.add_job(
        'forward-delivery-report',
        payload => row_to_json(payloads),
        queue_name => null,
        priority => 100,
        max_attempts => 6,
        run_at => now() + random() * '1 minute'::interval
      )
      from payloads
    )
  -- there is no meaning or importance to doing least here. these two counts will be the same
  -- we just need to select from both CTEs to guarantee they get executed
  select least(
    ( select count(*) from do_delete ),
    ( select count(*) from do_insert ),
    ( select count(*) from job_insert_result )
  )
  into v_result;

  return v_result;
end;
$$;


ALTER FUNCTION sms.resolve_delivery_reports(as_far_back_as interval, as_recent_as interval, fire_date timestamp without time zone, send_delay_window interval) OWNER TO postgres;

--
-- Name: FUNCTION resolve_delivery_reports(as_far_back_as interval, as_recent_as interval, fire_date timestamp without time zone, send_delay_window interval); Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON FUNCTION sms.resolve_delivery_reports(as_far_back_as interval, as_recent_as interval, fire_date timestamp without time zone, send_delay_window interval) IS '@omit';


--
-- Name: sell_cordoned_numbers(integer); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.sell_cordoned_numbers(n_days integer) RETURNS bigint
    LANGUAGE sql STRICT
    AS $$
  with sell_result as (
    update sms.all_phone_numbers
    set sold_at = now()
    where sold_at is null
      and cordoned_at > now() - (interval '1 days' * n_days)
    returning 1
  )
  select count(*)
  from sell_result
$$;


ALTER FUNCTION sms.sell_cordoned_numbers(n_days integer) OWNER TO postgres;

--
-- Name: FUNCTION sell_cordoned_numbers(n_days integer); Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON FUNCTION sms.sell_cordoned_numbers(n_days integer) IS '@omit';


--
-- Name: send_message(uuid, public.phone_number, text, public.url[], public.zip_code, timestamp without time zone); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.send_message(profile_id uuid, "to" public.phone_number, body text, media_urls public.url[], contact_zip_code public.zip_code DEFAULT NULL::text, send_before timestamp without time zone DEFAULT NULL::timestamp without time zone) RETURNS sms.outbound_messages
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

--
-- Name: sending_locations; Type: TABLE; Schema: sms; Owner: postgres
--

CREATE TABLE sms.sending_locations (
    id uuid DEFAULT public.uuid_generate_v1mc() NOT NULL,
    profile_id uuid NOT NULL,
    reference_name text NOT NULL,
    area_codes public.area_code[],
    center public.zip_code NOT NULL,
    decomissioned_at timestamp without time zone,
    purchasing_strategy sms.number_purchasing_strategy NOT NULL,
    state text,
    location point
);


ALTER TABLE sms.sending_locations OWNER TO postgres;

--
-- Name: sending_locations_active_phone_number_count(sms.sending_locations); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.sending_locations_active_phone_number_count(sl sms.sending_locations) RETURNS bigint
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$ 
  select count(*)
  from sms.phone_numbers
  where sending_location_id = sl.id
$$;


ALTER FUNCTION sms.sending_locations_active_phone_number_count(sl sms.sending_locations) OWNER TO postgres;

--
-- Name: FUNCTION sending_locations_active_phone_number_count(sl sms.sending_locations); Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON FUNCTION sms.sending_locations_active_phone_number_count(sl sms.sending_locations) IS '@omit';


--
-- Name: tg__complete_number_purchase(); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.tg__complete_number_purchase() RETURNS trigger
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
begin
  NEW.fulfilled_at := CURRENT_TIMESTAMP;
  return NEW;
end;
$$;


ALTER FUNCTION sms.tg__complete_number_purchase() OWNER TO postgres;

--
-- Name: tg__inbound_messages__attach_to_sending_location(); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.tg__inbound_messages__attach_to_sending_location() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
  v_sending_location_id uuid;
begin
  select sending_location_id
  from sms.phone_numbers
  where phone_number = NEW.to_number
  into v_sending_location_id;

  if v_sending_location_id is null then
    raise exception 'Could not match % to a known sending location', NEW.to_number using ERRCODE = 'SI000';
  end if;

  NEW.sending_location_id = v_sending_location_id;
  return NEW;
end;
$$;


ALTER FUNCTION sms.tg__inbound_messages__attach_to_sending_location() OWNER TO postgres;

--
-- Name: tg__outbound_messages__increment_pending_request_commitment(); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.tg__outbound_messages__increment_pending_request_commitment() RETURNS trigger
    LANGUAGE plpgsql STRICT
    AS $$
begin
  update sms.phone_number_requests
  set commitment_count = commitment_count + 1
  where id = NEW.pending_number_request_id;

  return NEW;
end;
$$;


ALTER FUNCTION sms.tg__outbound_messages__increment_pending_request_commitment() OWNER TO postgres;

--
-- Name: tg__outbound_messages__update_delivery_reports_with_message_id(); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.tg__outbound_messages__update_delivery_reports_with_message_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  update sms.delivery_reports
  set message_id = NEW.id
  where message_service_id = NEW.service_id
    and message_id is null;
  
  return NEW;
end;
$$;


ALTER FUNCTION sms.tg__outbound_messages__update_delivery_reports_with_message_id() OWNER TO postgres;

--
-- Name: tg__phone_number_requests__fulfill(); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.tg__phone_number_requests__fulfill() RETURNS trigger
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

  return NEW;
end;
$$;


ALTER FUNCTION sms.tg__phone_number_requests__fulfill() OWNER TO postgres;

--
-- Name: tg__prevent_update_sending_location_profile(); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.tg__prevent_update_sending_location_profile() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  raise exception 'updates to a sending location''s profile are not allowed';
end;
$$;


ALTER FUNCTION sms.tg__prevent_update_sending_location_profile() OWNER TO postgres;

--
-- Name: tg__sending_locations__set_state_and_location(); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.tg__sending_locations__set_state_and_location() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  v_state text;
  v_location point;
begin
  select state, location
  into v_state, v_location
  from geo.zip_locations
  where zip = NEW.center;

  if v_state is null or v_location is null then
    raise 'Could not find location record for zip code %. Please try another zip code.', NEW.center;
  end if;

  NEW.state := v_state;
  NEW.location := v_location;
  return NEW;
end;
$$;


ALTER FUNCTION sms.tg__sending_locations__set_state_and_location() OWNER TO postgres;

--
-- Name: tg__sending_locations__strategy_inherit(); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.tg__sending_locations__strategy_inherit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
  v_profile_purchasing_strategy sms.number_purchasing_strategy;
begin
  select default_purchasing_strategy
  from sms.profiles
  where id = NEW.profile_id
  into v_profile_purchasing_strategy;

  NEW.purchasing_strategy := v_profile_purchasing_strategy;
  return NEW;
end;
$$;


ALTER FUNCTION sms.tg__sending_locations__strategy_inherit() OWNER TO postgres;

--
-- Name: tg__sending_locations_area_code__prefill(); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.tg__sending_locations_area_code__prefill() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  v_area_codes text[];
begin
  select array_agg(distinct area_code)
  into v_area_codes
  from geo.zip_area_codes
  where geo.zip_area_codes.zip = NEW.center;

  -- Try the next closest zip code
  if coalesce(array_length(v_area_codes, 1), 0) = 0 then
    select array_agg(distinct geo.zip_area_codes.area_code)
    into v_area_codes
    from geo.zip_area_codes
    where zip = (
      select zip
      from geo.zip_locations
      where exists (
        select area_code
        from geo.zip_area_codes
        where geo.zip_area_codes.zip = geo.zip_locations.zip
      )
      order by location <-> NEW.location asc
      limit 1
    );
  end if;

  if coalesce(array_length(v_area_codes, 1), 0) = 0 then
    raise 'Could not find area codes for sending location with zip %', NEW.center;
  end if;

  NEW.area_codes = v_area_codes;

  return NEW;
end;
$$;


ALTER FUNCTION sms.tg__sending_locations_area_code__prefill() OWNER TO postgres;

--
-- Name: tg__set_phone_request_type(); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.tg__set_phone_request_type() RETURNS trigger
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
declare
  v_service sms.profile_service_option;
  v_tendlc_campaign_id uuid;
begin
  select
    sending_accounts.service,
    tendlc_campaigns.id
  from sms.sending_accounts sending_accounts
  join sms.profiles profiles on profiles.sending_account_id = sending_accounts.id
  join sms.sending_locations sending_locations on sending_locations.profile_id = profiles.id
  left join sms.tendlc_campaigns on tendlc_campaigns.id = profiles.tendlc_campaign_id
  where sending_locations.id = NEW.sending_location_id
  into v_service, v_tendlc_campaign_id;

  NEW.service := v_service;
  NEW.tendlc_campaign_id := v_tendlc_campaign_id;

  return NEW;
end;
$$;


ALTER FUNCTION sms.tg__set_phone_request_type() OWNER TO postgres;

--
-- Name: tg__sync_profile_provisioned(); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.tg__sync_profile_provisioned() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  v_profile_ids uuid[];
begin
  update sms.profiles
  set
    provisioned = exists (
      select 1
      from sms.sending_locations
      where
        profile_id = profiles.id
        and decomissioned_at is null
    )
  where
    id = ANY(array[OLD.profile_id, NEW.profile_id])
    and channel in ('grey-route', '10dlc');

  return NEW;
end;
$$;


ALTER FUNCTION sms.tg__sync_profile_provisioned() OWNER TO postgres;

--
-- Name: tg__sync_toll_free_profile_provisioned(); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.tg__sync_toll_free_profile_provisioned() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  update sms.profiles
  set provisioned = NEW.phone_number_id is not null
  from sms.toll_free_use_cases
  where true
    and toll_free_use_case_id = NEW.id
    and channel = 'toll-free';

  return NEW;
end;
$$;


ALTER FUNCTION sms.tg__sync_toll_free_profile_provisioned() OWNER TO postgres;

--
-- Name: tg__trigger_process_message(); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.tg__trigger_process_message() RETURNS trigger
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


ALTER FUNCTION sms.tg__trigger_process_message() OWNER TO postgres;

--
-- Name: trigger_send_message(); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.trigger_send_message() RETURNS trigger
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path TO '$user', 'public'
    AS $$
declare
  v_message_body record;
  v_job json;
  v_sending_location_id uuid;
  v_sending_account_json json;
begin
  select body, media_urls, send_before
  from sms.outbound_messages
  where id = NEW.id
    and created_at = NEW.original_created_at
  into v_message_body;

  select row_to_json(NEW) into v_job;

  if TG_TABLE_NAME = 'sending_locations' then
    v_sending_location_id := NEW.id;
  else
    v_sending_location_id := NEW.sending_location_id;
  end if;

  select row_to_json(relevant_sending_account_fields)
  from (
    select
      sending_account.id as sending_account_id,
      sms.profiles.id as profile_id,
      sending_account.service,
      sending_account.twilio_credentials,
      sending_account.telnyx_credentials
    from sms.sending_locations
    join sms.profiles on sms.sending_locations.profile_id = sms.profiles.id
    join sms.sending_accounts_as_json as sending_account
      on sending_account.id = sms.profiles.sending_account_id
    where sms.sending_locations.id = v_sending_location_id
  ) relevant_sending_account_fields
  into v_sending_account_json;

  select row_to_json(v_message_body)::jsonb || v_job::jsonb || v_sending_account_json::jsonb into v_job;

  if (cardinality(v_message_body.media_urls) is null 
        -- or cardinality(v_message_body.media_urls) = 0
        -- Telnyx can send MMS without attachment
  ) then
    perform graphile_worker.add_job(
      identifier => 'send-message',
      payload => v_job,
      run_at => NEW.send_after,
      max_attempts => 5
    );
  else
    perform graphile_worker.add_job(
      identifier => 'send-message',
      payload => v_job,
      run_at => NEW.send_after,
      max_attempts => 5,
      flags => ARRAY['send-message-mms:global']
    );
  end if;

  return NEW;
end;
$$;


ALTER FUNCTION sms.trigger_send_message() OWNER TO postgres;

--
-- Name: update_from_number_mappings_after_inbound_received(); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.update_from_number_mappings_after_inbound_received() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  -- This is different from the routing handler since we don't want this to do an insert, just update
  -- last_used_at
  -- If there's an inbound message to an invalidated prev mapping, we don't want that to re-validate
  -- the mapping
  update sms.from_number_mappings
  set last_used_at = greatest(last_used_at, NEW.received_at)
  where invalidated_at is null
    and to_number = NEW.from_number 
    and from_number = NEW.to_number
    and profile_id = (
      select profile_id
      from sms.sending_locations
      where sms.sending_locations.id = NEW.sending_location_id
    );

  return NEW;
end;
$$;


ALTER FUNCTION sms.update_from_number_mappings_after_inbound_received() OWNER TO postgres;

--
-- Name: update_from_number_mappings_after_routing(); Type: FUNCTION; Schema: sms; Owner: postgres
--

CREATE FUNCTION sms.update_from_number_mappings_after_routing() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  if NEW.profile_id is null then
    raise 'Message inserted into routing without a profile_id - not allowed';
  end if;
  
  insert into sms.from_number_mappings (profile_id, to_number, from_number, last_used_at, sending_location_id)
  values (NEW.profile_id, NEW.to_number, NEW.from_number, NEW.original_created_at, NEW.sending_location_id)
  on conflict (to_number, profile_id) where invalidated_at is null
  do update
  set last_used_at = NEW.original_created_at;

  return NEW;
end;
$$;


ALTER FUNCTION sms.update_from_number_mappings_after_routing() OWNER TO postgres;

--
-- Name: clients; Type: TABLE; Schema: billing; Owner: postgres
--

CREATE TABLE billing.clients (
    id uuid DEFAULT public.uuid_generate_v1mc() NOT NULL,
    name text NOT NULL,
    access_token text DEFAULT md5((random())::text),
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    taxable boolean DEFAULT false NOT NULL
);


ALTER TABLE billing.clients OWNER TO postgres;

--
-- Name: lrn_usage_rollups; Type: TABLE; Schema: billing; Owner: postgres
--

CREATE TABLE billing.lrn_usage_rollups (
    id uuid DEFAULT public.uuid_generate_v1mc() NOT NULL,
    client_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    period_start timestamp without time zone NOT NULL,
    period_end timestamp without time zone NOT NULL,
    stripe_usage_record_id text,
    lrn integer NOT NULL
);


ALTER TABLE billing.lrn_usage_rollups OWNER TO postgres;

--
-- Name: messaging_usage_rollups; Type: TABLE; Schema: billing; Owner: postgres
--

CREATE TABLE billing.messaging_usage_rollups (
    id uuid DEFAULT public.uuid_generate_v1mc() NOT NULL,
    profile_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    period_start timestamp without time zone NOT NULL,
    period_end timestamp without time zone NOT NULL,
    stripe_usage_record_id text,
    outbound_sms_messages integer NOT NULL,
    outbound_sms_segments integer NOT NULL,
    outbound_mms_messages integer NOT NULL,
    outbound_mms_segments integer NOT NULL,
    inbound_sms_messages integer NOT NULL,
    inbound_sms_segments integer NOT NULL,
    inbound_mms_messages integer NOT NULL,
    inbound_mms_segments integer NOT NULL
);


ALTER TABLE billing.messaging_usage_rollups OWNER TO postgres;

--
-- Name: inbound_messages; Type: TABLE; Schema: sms; Owner: postgres
--

CREATE TABLE sms.inbound_messages (
    id uuid DEFAULT public.uuid_generate_v1mc() NOT NULL,
    sending_location_id uuid NOT NULL,
    from_number public.phone_number NOT NULL,
    to_number public.phone_number NOT NULL,
    body text NOT NULL,
    received_at timestamp without time zone NOT NULL,
    service sms.profile_service_option NOT NULL,
    service_id text NOT NULL,
    num_segments integer NOT NULL,
    num_media integer NOT NULL,
    validated boolean NOT NULL,
    media_urls public.url[],
    extra json
);


ALTER TABLE sms.inbound_messages OWNER TO postgres;

--
-- Name: TABLE inbound_messages; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON TABLE sms.inbound_messages IS '@omit';


--
-- Name: profiles; Type: TABLE; Schema: sms; Owner: postgres
--

CREATE TABLE sms.profiles (
    id uuid DEFAULT public.uuid_generate_v1mc() NOT NULL,
    client_id uuid DEFAULT billing.current_client_id() NOT NULL,
    sending_account_id uuid NOT NULL,
    display_name text,
    reply_webhook_url public.url NOT NULL,
    message_status_webhook_url public.url NOT NULL,
    default_purchasing_strategy sms.number_purchasing_strategy DEFAULT 'same-state-by-distance'::sms.number_purchasing_strategy NOT NULL,
    voice_callback_url text,
    daily_contact_limit integer DEFAULT 200 NOT NULL,
    throughput_interval interval DEFAULT '00:01:00'::interval NOT NULL,
    throughput_limit integer DEFAULT 6 NOT NULL,
    channel sms.traffic_channel NOT NULL,
    provisioned boolean DEFAULT false NOT NULL,
    disabled boolean DEFAULT false NOT NULL,
    active boolean GENERATED ALWAYS AS ((provisioned AND (NOT disabled))) STORED,
    toll_free_use_case_id uuid,
    profile_service_configuration_id uuid,
    tendlc_campaign_id uuid,
    CONSTRAINT valid_10dlc_channel CHECK (((channel <> '10dlc'::sms.traffic_channel) OR (tendlc_campaign_id IS NOT NULL))),
    CONSTRAINT valid_toll_free_channel CHECK (((channel <> 'toll-free'::sms.traffic_channel) OR (toll_free_use_case_id IS NOT NULL)))
);


ALTER TABLE sms.profiles OWNER TO postgres;

--
-- Name: TABLE profiles; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON TABLE sms.profiles IS '@omit';


--
-- Name: COLUMN profiles.provisioned; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON COLUMN sms.profiles.provisioned IS '@omit create,update
This is true when all subresources necessary to send using the profile have also been fully provisioned.';


--
-- Name: sending_accounts; Type: TABLE; Schema: sms; Owner: postgres
--

CREATE TABLE sms.sending_accounts (
    id uuid DEFAULT public.uuid_generate_v1mc() NOT NULL,
    display_name text,
    service sms.profile_service_option NOT NULL,
    twilio_credentials sms.twilio_credentials,
    telnyx_credentials sms.telnyx_credentials,
    run_cost_backfills boolean DEFAULT false,
    bandwidth_credentials sms.bandwidth_credentials,
    tcr_credentials sms.tcr_credentials,
    CONSTRAINT ensure_single_credential CHECK ((num_nonnulls(twilio_credentials, telnyx_credentials, bandwidth_credentials, tcr_credentials) <= 1))
);


ALTER TABLE sms.sending_accounts OWNER TO postgres;

--
-- Name: TABLE sending_accounts; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON TABLE sms.sending_accounts IS '@omit';


--
-- Name: past_month_inbound_sms; Type: VIEW; Schema: billing; Owner: postgres
--

CREATE VIEW billing.past_month_inbound_sms AS
 SELECT clients.id AS client_id,
    clients.name AS client_name,
    sending_accounts.service,
    sum(inbound_messages.num_segments) FILTER (WHERE (inbound_messages.num_media = 0)) AS sms_segments,
    sum(inbound_messages.num_segments) FILTER (WHERE (inbound_messages.num_media > 0)) AS mms_segments
   FROM ((((sms.inbound_messages
     JOIN sms.sending_locations ON ((sending_locations.id = inbound_messages.sending_location_id)))
     JOIN sms.profiles ON ((profiles.id = sending_locations.profile_id)))
     JOIN sms.sending_accounts ON ((sending_accounts.id = profiles.sending_account_id)))
     JOIN billing.clients ON ((clients.id = profiles.client_id)))
  WHERE ((inbound_messages.received_at >= (date_trunc('month'::text, now()) - '1 mon'::interval)) AND (inbound_messages.received_at < date_trunc('month'::text, now())))
  GROUP BY clients.id, clients.name, sending_accounts.service
  ORDER BY clients.name, sending_accounts.service;


ALTER TABLE billing.past_month_inbound_sms OWNER TO postgres;

--
-- Name: accesses; Type: TABLE; Schema: lookup; Owner: postgres
--

CREATE TABLE lookup.accesses (
    id uuid DEFAULT public.uuid_generate_v1mc() NOT NULL,
    client_id uuid DEFAULT billing.current_client_id() NOT NULL,
    request_id uuid,
    phone_number public.phone_number NOT NULL,
    accessed_at timestamp without time zone DEFAULT now() NOT NULL,
    state lookup.access_fulfillment_state DEFAULT 'waiting'::lookup.access_fulfillment_state NOT NULL,
    billing_status lookup.billing_status_enum
);


ALTER TABLE lookup.accesses OWNER TO postgres;

--
-- Name: past_month_lrn_usage; Type: VIEW; Schema: billing; Owner: postgres
--

CREATE VIEW billing.past_month_lrn_usage AS
 WITH client_counts AS (
         SELECT count(DISTINCT past_month_accesses.phone_number) AS lookup_count,
            past_month_accesses.client_id
           FROM lookup.accesses past_month_accesses
          WHERE ((date_trunc('month'::text, past_month_accesses.accessed_at) = date_trunc('month'::text, (now() - '1 mon'::interval))) AND (NOT (EXISTS ( SELECT 1
                   FROM lookup.accesses previous_accesses
                  WHERE ((date_trunc('month'::text, previous_accesses.accessed_at) < date_trunc('month'::text, (now() - '1 mon'::interval))) AND ((previous_accesses.phone_number)::text = (past_month_accesses.phone_number)::text))))))
          GROUP BY past_month_accesses.client_id
        )
 SELECT clients.id AS client_id,
    clients.name AS client_name,
    client_counts.lookup_count
   FROM (client_counts
     JOIN billing.clients ON ((clients.id = client_counts.client_id)));


ALTER TABLE billing.past_month_lrn_usage OWNER TO postgres;

--
-- Name: all_phone_numbers; Type: TABLE; Schema: sms; Owner: postgres
--

CREATE TABLE sms.all_phone_numbers (
    phone_number public.phone_number NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    released_at timestamp without time zone,
    sending_location_id uuid NOT NULL,
    id uuid DEFAULT public.uuid_generate_v1mc() NOT NULL,
    sold_at timestamp without time zone,
    cordoned_at timestamp without time zone
);


ALTER TABLE sms.all_phone_numbers OWNER TO postgres;

--
-- Name: TABLE all_phone_numbers; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON TABLE sms.all_phone_numbers IS '@omit';


--
-- Name: past_month_number_count; Type: VIEW; Schema: billing; Owner: postgres
--

CREATE VIEW billing.past_month_number_count AS
 SELECT clients.id AS client_id,
    clients.name AS client_name,
    sending_accounts.service,
    sum(
        CASE
            WHEN (all_phone_numbers.created_at < (date_trunc('month'::text, now()) - '1 mon'::interval)) THEN (1)::double precision
            ELSE (date_part('day'::text, (date_trunc('month'::text, now()) - (all_phone_numbers.created_at)::timestamp with time zone)) / date_part('day'::text, (date_trunc('month'::text, now()) - (date_trunc('month'::text, now()) - '1 mon'::interval))))
        END) AS number_months
   FROM ((((sms.all_phone_numbers
     JOIN sms.sending_locations ON ((sending_locations.id = all_phone_numbers.sending_location_id)))
     JOIN sms.profiles ON ((profiles.id = sending_locations.profile_id)))
     JOIN sms.sending_accounts ON ((sending_accounts.id = profiles.sending_account_id)))
     JOIN billing.clients ON ((clients.id = profiles.client_id)))
  WHERE ((all_phone_numbers.created_at < date_trunc('month'::text, now())) AND (all_phone_numbers.sold_at IS NULL))
  GROUP BY clients.id, clients.name, sending_accounts.service
  ORDER BY clients.name, (sum(
        CASE
            WHEN (all_phone_numbers.created_at < (date_trunc('month'::text, now()) - '1 mon'::interval)) THEN (1)::double precision
            ELSE (date_part('day'::text, (date_trunc('month'::text, now()) - (all_phone_numbers.created_at)::timestamp with time zone)) / date_part('day'::text, (date_trunc('month'::text, now()) - (date_trunc('month'::text, now()) - '1 mon'::interval))))
        END)) DESC;


ALTER TABLE billing.past_month_number_count OWNER TO postgres;

--
-- Name: stripe_customer_subscriptions; Type: TABLE; Schema: billing; Owner: postgres
--

CREATE TABLE billing.stripe_customer_subscriptions (
    id uuid DEFAULT public.uuid_generate_v1mc() NOT NULL,
    customer_id uuid NOT NULL,
    subscription_id text NOT NULL,
    service_type sms.profile_service_option NOT NULL,
    usage_type billing.usage_type NOT NULL
);


ALTER TABLE billing.stripe_customer_subscriptions OWNER TO postgres;

--
-- Name: TABLE stripe_customer_subscriptions; Type: COMMENT; Schema: billing; Owner: postgres
--

COMMENT ON TABLE billing.stripe_customer_subscriptions IS '@omit';


--
-- Name: stripe_customers; Type: TABLE; Schema: billing; Owner: postgres
--

CREATE TABLE billing.stripe_customers (
    id uuid DEFAULT public.uuid_generate_v1mc() NOT NULL,
    client_id uuid NOT NULL,
    stripe_customer_id text,
    email text,
    address_billing_line1 text,
    address_billing_line2 text,
    address_billing_city text,
    address_billing_state text,
    address_billing_zip text,
    pricing_version billing.pricing_version DEFAULT 'v2'::billing.pricing_version
);


ALTER TABLE billing.stripe_customers OWNER TO postgres;

--
-- Name: TABLE stripe_customers; Type: COMMENT; Schema: billing; Owner: postgres
--

COMMENT ON TABLE billing.stripe_customers IS '@omit';


--
-- Name: zip_area_codes; Type: TABLE; Schema: geo; Owner: postgres
--

CREATE TABLE geo.zip_area_codes (
    zip public.zip_code NOT NULL,
    area_code public.area_code NOT NULL
);


ALTER TABLE geo.zip_area_codes OWNER TO postgres;

--
-- Name: TABLE zip_area_codes; Type: COMMENT; Schema: geo; Owner: postgres
--

COMMENT ON TABLE geo.zip_area_codes IS '@omit';


--
-- Name: zip_locations; Type: TABLE; Schema: geo; Owner: postgres
--

CREATE TABLE geo.zip_locations (
    zip text NOT NULL,
    state text NOT NULL,
    location point NOT NULL
);


ALTER TABLE geo.zip_locations OWNER TO postgres;

--
-- Name: phone_data; Type: TABLE; Schema: lookup; Owner: postgres
--

CREATE TABLE lookup.phone_data (
    phone_number public.phone_number NOT NULL,
    carrier_name text,
    phone_type lookup.phone_type_enum NOT NULL,
    last_updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE lookup.phone_data OWNER TO postgres;

--
-- Name: TABLE phone_data; Type: COMMENT; Schema: lookup; Owner: postgres
--

COMMENT ON TABLE lookup.phone_data IS '@omit';


--
-- Name: fresh_phone_data; Type: VIEW; Schema: lookup; Owner: postgres
--

CREATE VIEW lookup.fresh_phone_data AS
 SELECT phone_data.phone_number,
    phone_data.carrier_name,
    phone_data.phone_type,
    phone_data.last_updated_at AS updated_at
   FROM lookup.phone_data
  WHERE ((phone_data.last_updated_at > (now() - '1 year'::interval)) AND ((CURRENT_USER = 'lookup'::name) OR (CURRENT_USER = 'postgres'::name) OR (EXISTS ( SELECT 1
           FROM lookup.accesses
          WHERE (((accesses.phone_number)::text = (phone_data.phone_number)::text) AND (accesses.accessed_at > (now() - '1 year'::interval)))))));


ALTER TABLE lookup.fresh_phone_data OWNER TO postgres;

--
-- Name: VIEW fresh_phone_data; Type: COMMENT; Schema: lookup; Owner: postgres
--

COMMENT ON VIEW lookup.fresh_phone_data IS '@omit';


--
-- Name: lookups; Type: TABLE; Schema: lookup; Owner: postgres
--

CREATE TABLE lookup.lookups (
    phone_number public.phone_number,
    performed_at timestamp without time zone DEFAULT now() NOT NULL,
    via_service lookup.service_option DEFAULT 'telnyx'::lookup.service_option NOT NULL,
    carrier_name text,
    phone_type lookup.phone_type_enum NOT NULL,
    raw_result json
);


ALTER TABLE lookup.lookups OWNER TO postgres;

--
-- Name: request_results; Type: VIEW; Schema: lookup; Owner: postgres
--

CREATE VIEW lookup.request_results AS
 SELECT accesses.request_id,
    accesses.phone_number,
    fresh_phone_data.phone_type,
    fresh_phone_data.carrier_name,
    fresh_phone_data.updated_at AS lrn_updated_at
   FROM (lookup.accesses
     JOIN lookup.fresh_phone_data ON (((fresh_phone_data.phone_number)::text = (accesses.phone_number)::text)))
  WHERE (accesses.client_id = billing.current_client_id());


ALTER TABLE lookup.request_results OWNER TO postgres;

--
-- Name: VIEW request_results; Type: COMMENT; Schema: lookup; Owner: postgres
--

COMMENT ON VIEW lookup.request_results IS '
@foreignKey (request_id) references lookup.requests (id)
@primaryKey phone_number
';


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    run_on timestamp without time zone NOT NULL
);


ALTER TABLE public.migrations OWNER TO postgres;

--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.migrations_id_seq OWNER TO postgres;

--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: from_number_mappings; Type: TABLE; Schema: sms; Owner: postgres
--

CREATE TABLE sms.from_number_mappings (
    profile_id uuid,
    to_number text,
    from_number text,
    last_used_at timestamp with time zone NOT NULL,
    sending_location_id uuid NOT NULL,
    cordoned_at timestamp with time zone,
    invalidated_at timestamp with time zone
);


ALTER TABLE sms.from_number_mappings OWNER TO postgres;

--
-- Name: active_from_number_mappings; Type: VIEW; Schema: sms; Owner: postgres
--

CREATE VIEW sms.active_from_number_mappings AS
 SELECT from_number_mappings.profile_id,
    from_number_mappings.to_number,
    from_number_mappings.from_number,
    from_number_mappings.last_used_at,
    from_number_mappings.sending_location_id,
    from_number_mappings.cordoned_at,
    from_number_mappings.invalidated_at
   FROM sms.from_number_mappings
  WHERE (from_number_mappings.invalidated_at IS NULL);


ALTER TABLE sms.active_from_number_mappings OWNER TO postgres;

--
-- Name: area_code_capacities; Type: TABLE; Schema: sms; Owner: postgres
--

CREATE TABLE sms.area_code_capacities (
    area_code public.area_code NOT NULL,
    sending_account_id uuid NOT NULL,
    capacity integer,
    last_fetched_at timestamp without time zone DEFAULT now()
);


ALTER TABLE sms.area_code_capacities OWNER TO postgres;

--
-- Name: TABLE area_code_capacities; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON TABLE sms.area_code_capacities IS '@omit';


--
-- Name: delivery_report_forward_attempts; Type: TABLE; Schema: sms; Owner: postgres
--

CREATE TABLE sms.delivery_report_forward_attempts (
    message_id uuid NOT NULL,
    event_type sms.delivery_report_event NOT NULL,
    sent_at timestamp without time zone DEFAULT now() NOT NULL,
    sent_headers json NOT NULL,
    sent_body json NOT NULL,
    response_status_code integer NOT NULL,
    response_headers json NOT NULL,
    response_body text
);


ALTER TABLE sms.delivery_report_forward_attempts OWNER TO postgres;

--
-- Name: TABLE delivery_report_forward_attempts; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON TABLE sms.delivery_report_forward_attempts IS '@omit';


--
-- Name: delivery_reports; Type: TABLE; Schema: sms; Owner: postgres
--

CREATE TABLE sms.delivery_reports (
    message_service_id text,
    message_id uuid,
    event_type sms.delivery_report_event NOT NULL,
    generated_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    service text NOT NULL,
    validated boolean NOT NULL,
    error_codes text[],
    extra json,
    is_from_service boolean DEFAULT true,
    CONSTRAINT message_id_required_after_dedicated_unmatched_table CHECK (((message_id IS NOT NULL) OR (is_from_service IS NULL)))
)
WITH (autovacuum_vacuum_threshold='50000', autovacuum_vacuum_scale_factor='0', autovacuum_vacuum_cost_limit='1000', autovacuum_vacuum_cost_delay='0');


ALTER TABLE sms.delivery_reports OWNER TO postgres;

--
-- Name: TABLE delivery_reports; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON TABLE sms.delivery_reports IS '@omit';


--
-- Name: fresh_phone_commitments; Type: TABLE; Schema: sms; Owner: postgres
--

CREATE TABLE sms.fresh_phone_commitments (
    phone_number public.phone_number NOT NULL,
    commitment integer DEFAULT 0,
    sending_location_id uuid NOT NULL
)
WITH (autovacuum_vacuum_threshold='50000', autovacuum_vacuum_scale_factor='0', autovacuum_vacuum_cost_limit='1000', autovacuum_vacuum_cost_delay='0');


ALTER TABLE sms.fresh_phone_commitments OWNER TO postgres;

--
-- Name: TABLE fresh_phone_commitments; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON TABLE sms.fresh_phone_commitments IS '@omit';


--
-- Name: inbound_message_forward_attempts; Type: TABLE; Schema: sms; Owner: postgres
--

CREATE TABLE sms.inbound_message_forward_attempts (
    message_id uuid,
    sent_at timestamp without time zone DEFAULT now() NOT NULL,
    sent_headers json NOT NULL,
    sent_body json NOT NULL,
    response_status_code integer NOT NULL,
    response_headers json NOT NULL,
    response_body text
);


ALTER TABLE sms.inbound_message_forward_attempts OWNER TO postgres;

--
-- Name: TABLE inbound_message_forward_attempts; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON TABLE sms.inbound_message_forward_attempts IS '@omit';


--
-- Name: outbound_messages_awaiting_from_number; Type: TABLE; Schema: sms; Owner: postgres
--

CREATE TABLE sms.outbound_messages_awaiting_from_number (
    id uuid NOT NULL,
    original_created_at timestamp without time zone NOT NULL,
    to_number public.phone_number NOT NULL,
    estimated_segments integer,
    sending_location_id uuid NOT NULL,
    pending_number_request_id uuid NOT NULL,
    send_after timestamp without time zone,
    processed_at timestamp without time zone,
    decision_stage text,
    profile_id uuid
);


ALTER TABLE sms.outbound_messages_awaiting_from_number OWNER TO postgres;

--
-- Name: TABLE outbound_messages_awaiting_from_number; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON TABLE sms.outbound_messages_awaiting_from_number IS '@omit';


--
-- Name: outbound_messages_routing; Type: TABLE; Schema: sms; Owner: postgres
--

CREATE TABLE sms.outbound_messages_routing (
    id uuid NOT NULL,
    to_number public.phone_number NOT NULL,
    from_number public.phone_number,
    estimated_segments integer DEFAULT 1,
    stage sms.outbound_message_stages NOT NULL,
    decision_stage text,
    first_from_to_pair_of_day boolean DEFAULT true,
    sending_location_id uuid,
    pending_number_request_id uuid,
    send_after timestamp without time zone,
    processed_at timestamp without time zone DEFAULT now(),
    original_created_at timestamp without time zone NOT NULL,
    profile_id uuid
);


ALTER TABLE sms.outbound_messages_routing OWNER TO postgres;

--
-- Name: TABLE outbound_messages_routing; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON TABLE sms.outbound_messages_routing IS '@omit';


--
-- Name: outbound_messages_telco; Type: TABLE; Schema: sms; Owner: postgres
--

CREATE TABLE sms.outbound_messages_telco (
    id uuid NOT NULL,
    service_id text,
    telco_status sms.telco_status DEFAULT 'sent'::sms.telco_status NOT NULL,
    num_segments integer,
    num_media integer,
    cost_in_cents numeric(6,2),
    extra json,
    original_created_at timestamp without time zone NOT NULL,
    sent_at timestamp without time zone DEFAULT now(),
    profile_id uuid NOT NULL
);


ALTER TABLE sms.outbound_messages_telco OWNER TO postgres;

--
-- Name: TABLE outbound_messages_telco; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON TABLE sms.outbound_messages_telco IS '@omit';


--
-- Name: phone_number_requests; Type: TABLE; Schema: sms; Owner: postgres
--

CREATE TABLE sms.phone_number_requests (
    id uuid DEFAULT public.uuid_generate_v1mc() NOT NULL,
    sending_location_id uuid NOT NULL,
    area_code public.area_code NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    phone_number public.phone_number,
    fulfilled_at timestamp without time zone,
    commitment_count bigint DEFAULT 0,
    service_order_id text,
    service sms.profile_service_option,
    service_order_completed_at timestamp with time zone,
    service_profile_associated_at timestamp with time zone,
    service_10dlc_campaign_associated_at timestamp with time zone,
    tendlc_campaign_id uuid
);


ALTER TABLE sms.phone_number_requests OWNER TO postgres;

--
-- Name: TABLE phone_number_requests; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON TABLE sms.phone_number_requests IS '@omit';


--
-- Name: pending_number_request_capacity; Type: VIEW; Schema: sms; Owner: postgres
--

CREATE VIEW sms.pending_number_request_capacity AS
 SELECT outbound_messages_awaiting_from_number.pending_number_request_id,
    count(*) AS commitment_count
   FROM sms.outbound_messages_awaiting_from_number
  GROUP BY outbound_messages_awaiting_from_number.pending_number_request_id
UNION
 SELECT phone_number_requests.id AS pending_number_request_id,
    0 AS commitment_count
   FROM (sms.phone_number_requests
     LEFT JOIN sms.outbound_messages_awaiting_from_number ON ((phone_number_requests.id = outbound_messages_awaiting_from_number.pending_number_request_id)))
  WHERE (true AND (outbound_messages_awaiting_from_number.pending_number_request_id IS NULL) AND (phone_number_requests.fulfilled_at IS NULL));


ALTER TABLE sms.pending_number_request_capacity OWNER TO postgres;

--
-- Name: VIEW pending_number_request_capacity; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON VIEW sms.pending_number_request_capacity IS '@omit';


--
-- Name: phone_numbers; Type: VIEW; Schema: sms; Owner: postgres
--

CREATE VIEW sms.phone_numbers AS
 SELECT all_phone_numbers.phone_number,
    all_phone_numbers.created_at,
    all_phone_numbers.sending_location_id,
    all_phone_numbers.cordoned_at
   FROM sms.all_phone_numbers
  WHERE (all_phone_numbers.released_at IS NULL);


ALTER TABLE sms.phone_numbers OWNER TO postgres;

--
-- Name: VIEW phone_numbers; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON VIEW sms.phone_numbers IS '@omit';


--
-- Name: profile_service_configurations; Type: TABLE; Schema: sms; Owner: postgres
--

CREATE TABLE sms.profile_service_configurations (
    id uuid DEFAULT public.uuid_generate_v1mc() NOT NULL,
    twilio_configuration_id uuid,
    telnyx_configuration_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ensure_single_service_profile CHECK ((num_nonnulls(twilio_configuration_id, telnyx_configuration_id) <= 1))
);


ALTER TABLE sms.profile_service_configurations OWNER TO postgres;

--
-- Name: TABLE profile_service_configurations; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON TABLE sms.profile_service_configurations IS '@omit';


--
-- Name: COLUMN profile_service_configurations.created_at; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON COLUMN sms.profile_service_configurations.created_at IS '@omit create,update,delete';


--
-- Name: COLUMN profile_service_configurations.updated_at; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON COLUMN sms.profile_service_configurations.updated_at IS '@omit create,update,delete';


--
-- Name: sending_accounts_as_json; Type: VIEW; Schema: sms; Owner: postgres
--

CREATE VIEW sms.sending_accounts_as_json AS
 SELECT sending_accounts.id,
    sending_accounts.display_name,
    sending_accounts.service,
    to_json(sending_accounts.twilio_credentials) AS twilio_credentials,
    to_json(sending_accounts.telnyx_credentials) AS telnyx_credentials,
    to_json(sending_accounts.bandwidth_credentials) AS bandwidth_credentials,
    to_json(sending_accounts.tcr_credentials) AS tcr_credentials
   FROM sms.sending_accounts;


ALTER TABLE sms.sending_accounts_as_json OWNER TO postgres;

--
-- Name: VIEW sending_accounts_as_json; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON VIEW sms.sending_accounts_as_json IS '@omit';


--
-- Name: sending_location_capacities; Type: VIEW; Schema: sms; Owner: postgres
--

CREATE VIEW sms.sending_location_capacities AS
 SELECT sending_location_area_codes.id,
    sending_location_area_codes.profile_id,
    sending_location_area_codes.reference_name,
    sending_location_area_codes.center,
    sending_location_area_codes.sending_account_id,
    sending_location_area_codes.sending_account_name,
    sending_location_area_codes.area_code,
    area_code_capacities.capacity
   FROM (( SELECT sending_locations.id,
            sending_locations.profile_id,
            sending_locations.reference_name,
            sending_locations.center,
            profiles.sending_account_id,
            sending_accounts.display_name AS sending_account_name,
            unnest(sending_locations.area_codes) AS area_code
           FROM ((sms.sending_locations
             JOIN sms.profiles ON ((profiles.id = sending_locations.profile_id)))
             JOIN sms.sending_accounts ON ((sending_accounts.id = profiles.sending_account_id)))) sending_location_area_codes
     JOIN sms.area_code_capacities ON ((((area_code_capacities.area_code)::text = (sending_location_area_codes.area_code)::text) AND (area_code_capacities.sending_account_id = sending_location_area_codes.sending_account_id))));


ALTER TABLE sms.sending_location_capacities OWNER TO postgres;

--
-- Name: telnyx_profile_service_configurations; Type: TABLE; Schema: sms; Owner: postgres
--

CREATE TABLE sms.telnyx_profile_service_configurations (
    id uuid DEFAULT public.uuid_generate_v1mc() NOT NULL,
    messaging_profile_id text,
    billing_group_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE sms.telnyx_profile_service_configurations OWNER TO postgres;

--
-- Name: TABLE telnyx_profile_service_configurations; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON TABLE sms.telnyx_profile_service_configurations IS '@omit';


--
-- Name: COLUMN telnyx_profile_service_configurations.created_at; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON COLUMN sms.telnyx_profile_service_configurations.created_at IS '@omit create,update,delete';


--
-- Name: COLUMN telnyx_profile_service_configurations.updated_at; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON COLUMN sms.telnyx_profile_service_configurations.updated_at IS '@omit create,update,delete';


--
-- Name: tendlc_campaign_mno_metadata; Type: TABLE; Schema: sms; Owner: postgres
--

CREATE TABLE sms.tendlc_campaign_mno_metadata (
    id uuid DEFAULT public.uuid_generate_v1mc() NOT NULL,
    campaign_id uuid NOT NULL,
    mno_id text,
    mno text,
    qualify boolean,
    tpm integer,
    brand_tier text,
    msg_class text,
    mno_review boolean,
    mno_support boolean,
    min_msg_samples integer,
    req_subscriber_help boolean,
    req_subscriber_optin boolean,
    req_subscriber_optout boolean,
    no_embedded_phone boolean,
    no_embedded_link boolean,
    extra json,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE sms.tendlc_campaign_mno_metadata OWNER TO postgres;

--
-- Name: TABLE tendlc_campaign_mno_metadata; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON TABLE sms.tendlc_campaign_mno_metadata IS '@omit';


--
-- Name: tendlc_campaigns; Type: TABLE; Schema: sms; Owner: postgres
--

CREATE TABLE sms.tendlc_campaigns (
    id uuid DEFAULT public.uuid_generate_v1mc() NOT NULL,
    tcr_account_id uuid,
    tcr_campaign_id text,
    registrar_account_id uuid,
    registrar_campaign_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT account_id_required CHECK (((tcr_account_id IS NOT NULL) OR (registrar_account_id IS NOT NULL))),
    CONSTRAINT campaign_id_required CHECK (((tcr_campaign_id IS NOT NULL) OR (registrar_campaign_id IS NOT NULL)))
);


ALTER TABLE sms.tendlc_campaigns OWNER TO postgres;

--
-- Name: TABLE tendlc_campaigns; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON TABLE sms.tendlc_campaigns IS '@omit';


--
-- Name: toll_free_use_cases; Type: TABLE; Schema: sms; Owner: postgres
--

CREATE TABLE sms.toll_free_use_cases (
    id uuid DEFAULT public.uuid_generate_v1mc() NOT NULL,
    client_id uuid NOT NULL,
    sending_account_id uuid NOT NULL,
    area_code text,
    phone_number_request_id uuid,
    phone_number_id uuid,
    stakeholders text NOT NULL,
    submitted_at timestamp with time zone,
    approved_at timestamp with time zone,
    throughput_interval interval,
    throughput_limit interval,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT valid_toll_free_area_code CHECK (((area_code IS NULL) OR (area_code ~* '^8[0-9]{2}$'::text)))
);


ALTER TABLE sms.toll_free_use_cases OWNER TO postgres;

--
-- Name: TABLE toll_free_use_cases; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON TABLE sms.toll_free_use_cases IS '@omit';


--
-- Name: COLUMN toll_free_use_cases.id; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON COLUMN sms.toll_free_use_cases.id IS '@omit create,update,delete';


--
-- Name: COLUMN toll_free_use_cases.client_id; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON COLUMN sms.toll_free_use_cases.client_id IS '@omit update,delete';


--
-- Name: COLUMN toll_free_use_cases.sending_account_id; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON COLUMN sms.toll_free_use_cases.sending_account_id IS '@omit update,delete';


--
-- Name: COLUMN toll_free_use_cases.area_code; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON COLUMN sms.toll_free_use_cases.area_code IS '@omit update,delete
Optional preference for specific toll-free area code.';


--
-- Name: COLUMN toll_free_use_cases.stakeholders; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON COLUMN sms.toll_free_use_cases.stakeholders IS 'Comma-separated list of stakeholders involved in toll-free use case approval. Ideally names and email addresses, but left as freeform text for flexibility in this new domain.';


--
-- Name: COLUMN toll_free_use_cases.submitted_at; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON COLUMN sms.toll_free_use_cases.submitted_at IS 'When the use case was submitted to the aggregator for approval.';


--
-- Name: COLUMN toll_free_use_cases.approved_at; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON COLUMN sms.toll_free_use_cases.approved_at IS 'When the use case application was approved by the aggregator.';


--
-- Name: COLUMN toll_free_use_cases.created_at; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON COLUMN sms.toll_free_use_cases.created_at IS '@omit create,update,delete';


--
-- Name: COLUMN toll_free_use_cases.updated_at; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON COLUMN sms.toll_free_use_cases.updated_at IS '@omit create,update,delete';


--
-- Name: twilio_profile_service_configurations; Type: TABLE; Schema: sms; Owner: postgres
--

CREATE TABLE sms.twilio_profile_service_configurations (
    id uuid DEFAULT public.uuid_generate_v1mc() NOT NULL,
    messaging_service_sid text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE sms.twilio_profile_service_configurations OWNER TO postgres;

--
-- Name: TABLE twilio_profile_service_configurations; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON TABLE sms.twilio_profile_service_configurations IS '@omit';


--
-- Name: COLUMN twilio_profile_service_configurations.created_at; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON COLUMN sms.twilio_profile_service_configurations.created_at IS '@omit create,update,delete';


--
-- Name: COLUMN twilio_profile_service_configurations.updated_at; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON COLUMN sms.twilio_profile_service_configurations.updated_at IS '@omit create,update,delete';


--
-- Name: unmatched_delivery_reports; Type: TABLE; Schema: sms; Owner: postgres
--

CREATE TABLE sms.unmatched_delivery_reports (
    message_service_id text NOT NULL,
    event_type sms.delivery_report_event NOT NULL,
    generated_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    service text NOT NULL,
    validated boolean NOT NULL,
    error_codes text[],
    extra json
);


ALTER TABLE sms.unmatched_delivery_reports OWNER TO postgres;

--
-- Name: TABLE unmatched_delivery_reports; Type: COMMENT; Schema: sms; Owner: postgres
--

COMMENT ON TABLE sms.unmatched_delivery_reports IS '@omit';


--
-- Name: failed_jobs; Type: TABLE; Schema: worker; Owner: postgres
--

CREATE TABLE worker.failed_jobs (
    id bigint,
    job_queue_id integer,
    task_id integer NOT NULL,
    payload json NOT NULL,
    priority smallint NOT NULL,
    max_attempts smallint NOT NULL,
    last_error text,
    created_at timestamp with time zone NOT NULL,
    failed_at timestamp with time zone DEFAULT now() NOT NULL,
    key text,
    revision integer NOT NULL,
    flags jsonb
);


ALTER TABLE worker.failed_jobs OWNER TO postgres;

--
-- Name: COLUMN failed_jobs.failed_at; Type: COMMENT; Schema: worker; Owner: postgres
--

COMMENT ON COLUMN worker.failed_jobs.failed_at IS 'This is a proxy for run_at';


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: clients clients_access_token_key; Type: CONSTRAINT; Schema: billing; Owner: postgres
--

ALTER TABLE ONLY billing.clients
    ADD CONSTRAINT clients_access_token_key UNIQUE (access_token);


--
-- Name: clients clients_name_key; Type: CONSTRAINT; Schema: billing; Owner: postgres
--

ALTER TABLE ONLY billing.clients
    ADD CONSTRAINT clients_name_key UNIQUE (name);


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: billing; Owner: postgres
--

ALTER TABLE ONLY billing.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- Name: lrn_usage_rollups lrn_usage_rollups_pkey; Type: CONSTRAINT; Schema: billing; Owner: postgres
--

ALTER TABLE ONLY billing.lrn_usage_rollups
    ADD CONSTRAINT lrn_usage_rollups_pkey PRIMARY KEY (id);


--
-- Name: messaging_usage_rollups messaging_usage_rollups_pkey; Type: CONSTRAINT; Schema: billing; Owner: postgres
--

ALTER TABLE ONLY billing.messaging_usage_rollups
    ADD CONSTRAINT messaging_usage_rollups_pkey PRIMARY KEY (id);


--
-- Name: stripe_customer_subscriptions stripe_customer_subscriptions_pkey; Type: CONSTRAINT; Schema: billing; Owner: postgres
--

ALTER TABLE ONLY billing.stripe_customer_subscriptions
    ADD CONSTRAINT stripe_customer_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: stripe_customers stripe_customers_pkey; Type: CONSTRAINT; Schema: billing; Owner: postgres
--

ALTER TABLE ONLY billing.stripe_customers
    ADD CONSTRAINT stripe_customers_pkey PRIMARY KEY (id);


--
-- Name: zip_locations zip_locations_pkey; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.zip_locations
    ADD CONSTRAINT zip_locations_pkey PRIMARY KEY (zip);


--
-- Name: accesses accesses_pkey; Type: CONSTRAINT; Schema: lookup; Owner: postgres
--

ALTER TABLE ONLY lookup.accesses
    ADD CONSTRAINT accesses_pkey PRIMARY KEY (id);


--
-- Name: phone_data phone_data_pkey; Type: CONSTRAINT; Schema: lookup; Owner: postgres
--

ALTER TABLE ONLY lookup.phone_data
    ADD CONSTRAINT phone_data_pkey PRIMARY KEY (phone_number);


--
-- Name: requests requests_pkey; Type: CONSTRAINT; Schema: lookup; Owner: postgres
--

ALTER TABLE ONLY lookup.requests
    ADD CONSTRAINT requests_pkey PRIMARY KEY (id);


--
-- Name: accesses unique_phone_number_request; Type: CONSTRAINT; Schema: lookup; Owner: postgres
--

ALTER TABLE ONLY lookup.accesses
    ADD CONSTRAINT unique_phone_number_request UNIQUE (phone_number, request_id);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: tendlc_campaign_mno_metadata campaign_mno_metadata_unique_campaign_mno; Type: CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.tendlc_campaign_mno_metadata
    ADD CONSTRAINT campaign_mno_metadata_unique_campaign_mno UNIQUE (campaign_id, mno_id);


--
-- Name: fresh_phone_commitments fresh_phone_commitments_pkey; Type: CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.fresh_phone_commitments
    ADD CONSTRAINT fresh_phone_commitments_pkey PRIMARY KEY (phone_number);


--
-- Name: inbound_messages inbound_messages_pkey; Type: CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.inbound_messages
    ADD CONSTRAINT inbound_messages_pkey PRIMARY KEY (received_at, id);


--
-- Name: outbound_messages_awaiting_from_number outbound_messages_awaiting_from_number_pkey; Type: CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.outbound_messages_awaiting_from_number
    ADD CONSTRAINT outbound_messages_awaiting_from_number_pkey PRIMARY KEY (id);


--
-- Name: outbound_messages outbound_messages_pkey; Type: CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.outbound_messages
    ADD CONSTRAINT outbound_messages_pkey PRIMARY KEY (created_at, id);


--
-- Name: outbound_messages_routing outbound_messages_routing_pkey; Type: CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.outbound_messages_routing
    ADD CONSTRAINT outbound_messages_routing_pkey PRIMARY KEY (original_created_at, id);


--
-- Name: outbound_messages_telco outbound_messages_telco_pkey; Type: CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.outbound_messages_telco
    ADD CONSTRAINT outbound_messages_telco_pkey PRIMARY KEY (original_created_at, id);


--
-- Name: phone_number_requests phone_number_requests_pkey; Type: CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.phone_number_requests
    ADD CONSTRAINT phone_number_requests_pkey PRIMARY KEY (id);


--
-- Name: all_phone_numbers phone_numbers_pkey; Type: CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.all_phone_numbers
    ADD CONSTRAINT phone_numbers_pkey PRIMARY KEY (id);


--
-- Name: profile_service_configurations profile_service_configurations_pkey; Type: CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.profile_service_configurations
    ADD CONSTRAINT profile_service_configurations_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: sending_accounts sending_accounts_pkey; Type: CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.sending_accounts
    ADD CONSTRAINT sending_accounts_pkey PRIMARY KEY (id);


--
-- Name: sending_locations sending_locations_pkey; Type: CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.sending_locations
    ADD CONSTRAINT sending_locations_pkey PRIMARY KEY (id);


--
-- Name: telnyx_profile_service_configurations telnyx_profile_service_configurations_pkey; Type: CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.telnyx_profile_service_configurations
    ADD CONSTRAINT telnyx_profile_service_configurations_pkey PRIMARY KEY (id);


--
-- Name: tendlc_campaign_mno_metadata tendlc_campaign_mno_metadata_pkey; Type: CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.tendlc_campaign_mno_metadata
    ADD CONSTRAINT tendlc_campaign_mno_metadata_pkey PRIMARY KEY (id);


--
-- Name: tendlc_campaigns tendlc_campaigns_pkey; Type: CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.tendlc_campaigns
    ADD CONSTRAINT tendlc_campaigns_pkey PRIMARY KEY (id);


--
-- Name: toll_free_use_cases toll_free_use_cases_pkey; Type: CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.toll_free_use_cases
    ADD CONSTRAINT toll_free_use_cases_pkey PRIMARY KEY (id);


--
-- Name: twilio_profile_service_configurations twilio_profile_service_configurations_pkey; Type: CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.twilio_profile_service_configurations
    ADD CONSTRAINT twilio_profile_service_configurations_pkey PRIMARY KEY (id);


--
-- Name: client_access_token_idx; Type: INDEX; Schema: billing; Owner: postgres
--

CREATE INDEX client_access_token_idx ON billing.clients USING btree (access_token);


--
-- Name: lrn_usage_rollups_lookup; Type: INDEX; Schema: billing; Owner: postgres
--

CREATE UNIQUE INDEX lrn_usage_rollups_lookup ON billing.lrn_usage_rollups USING btree (client_id, period_start, period_end);


--
-- Name: messaging_usage_rollups_lookup; Type: INDEX; Schema: billing; Owner: postgres
--

CREATE UNIQUE INDEX messaging_usage_rollups_lookup ON billing.messaging_usage_rollups USING btree (profile_id, period_start, period_end);


--
-- Name: zip_area_codes_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX zip_area_codes_idx ON geo.zip_area_codes USING btree (zip, area_code);


--
-- Name: accessess_access_at_idx; Type: INDEX; Schema: lookup; Owner: postgres
--

CREATE INDEX accessess_access_at_idx ON lookup.accesses USING btree (accessed_at);


--
-- Name: accessess_client_id_idx; Type: INDEX; Schema: lookup; Owner: postgres
--

CREATE INDEX accessess_client_id_idx ON lookup.accesses USING btree (client_id);


--
-- Name: accessess_phone_number_idx; Type: INDEX; Schema: lookup; Owner: postgres
--

CREATE INDEX accessess_phone_number_idx ON lookup.accesses USING btree (phone_number);


--
-- Name: accessess_request_id_idx; Type: INDEX; Schema: lookup; Owner: postgres
--

CREATE INDEX accessess_request_id_idx ON lookup.accesses USING btree (request_id);


--
-- Name: phone_data_updated_at_idx; Type: INDEX; Schema: lookup; Owner: postgres
--

CREATE INDEX phone_data_updated_at_idx ON lookup.phone_data USING btree (last_updated_at);


--
-- Name: request_client_id_idx; Type: INDEX; Schema: lookup; Owner: postgres
--

CREATE INDEX request_client_id_idx ON lookup.requests USING btree (client_id);


--
-- Name: active_phone_number_sending_location_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX active_phone_number_sending_location_idx ON sms.all_phone_numbers USING btree (sending_location_id, phone_number) WHERE (released_at IS NULL);


--
-- Name: active_sending_locations_profile_id_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX active_sending_locations_profile_id_idx ON sms.sending_locations USING btree (profile_id, state) WHERE (decomissioned_at IS NULL);


--
-- Name: area_code_sending_accounts_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE UNIQUE INDEX area_code_sending_accounts_idx ON sms.area_code_capacities USING btree (area_code, sending_account_id);


--
-- Name: choose_existing_phone_number_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX choose_existing_phone_number_idx ON sms.fresh_phone_commitments USING btree (sending_location_id, commitment DESC);


--
-- Name: delivery_report_forward_attempts_sent_at_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX delivery_report_forward_attempts_sent_at_idx ON sms.delivery_report_forward_attempts USING btree (sent_at DESC);


--
-- Name: delivery_report_message_id_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX delivery_report_message_id_idx ON sms.delivery_reports USING btree (message_id);


--
-- Name: delivery_reports_created_at_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX delivery_reports_created_at_idx ON sms.delivery_reports USING btree (created_at DESC, event_type);


--
-- Name: from_number_mappings_from_number_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX from_number_mappings_from_number_idx ON sms.from_number_mappings USING btree (from_number) WHERE (invalidated_at IS NULL);


--
-- Name: inbound_message_forward_attempts_message_id_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX inbound_message_forward_attempts_message_id_idx ON sms.inbound_message_forward_attempts USING btree (message_id);


--
-- Name: inbound_message_forward_attempts_sent_at_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX inbound_message_forward_attempts_sent_at_idx ON sms.inbound_message_forward_attempts USING btree (sent_at DESC);


--
-- Name: inbound_messages_received_at; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX inbound_messages_received_at ON sms.inbound_messages USING btree (received_at);


--
-- Name: inbound_messages_received_at_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX inbound_messages_received_at_idx ON sms.inbound_messages USING btree (received_at DESC);


--
-- Name: inbound_messages_sending_location_id_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX inbound_messages_sending_location_id_idx ON sms.inbound_messages USING btree (sending_location_id);


--
-- Name: outbound_message_routing_from_number_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX outbound_message_routing_from_number_idx ON sms.outbound_messages_routing USING btree (from_number);


--
-- Name: outbound_messages_awaiting_from_n_pending_number_request_id_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX outbound_messages_awaiting_from_n_pending_number_request_id_idx ON sms.outbound_messages_awaiting_from_number USING btree (pending_number_request_id);


--
-- Name: outbound_messages_created_at_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX outbound_messages_created_at_idx ON sms.outbound_messages USING btree (created_at DESC);


--
-- Name: outbound_messages_routing_original_created_at_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX outbound_messages_routing_original_created_at_idx ON sms.outbound_messages_routing USING btree (original_created_at DESC);


--
-- Name: outbound_messages_routing_phone_number_overloaded_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX outbound_messages_routing_phone_number_overloaded_idx ON sms.outbound_messages_routing USING btree (processed_at DESC, from_number) INCLUDE (estimated_segments) WHERE (stage <> 'awaiting-number'::sms.outbound_message_stages);


--
-- Name: outbound_messages_routing_request_fulfillment_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX outbound_messages_routing_request_fulfillment_idx ON sms.outbound_messages_routing USING btree (pending_number_request_id) WHERE (stage = 'awaiting-number'::sms.outbound_message_stages);


--
-- Name: outbound_messages_routing_to_number_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX outbound_messages_routing_to_number_idx ON sms.outbound_messages_routing USING btree (to_number);


--
-- Name: outbound_messages_telco_original_created_at_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX outbound_messages_telco_original_created_at_idx ON sms.outbound_messages_telco USING btree (original_created_at DESC);


--
-- Name: outbound_messages_telco_sent_at; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX outbound_messages_telco_sent_at ON sms.outbound_messages_telco USING btree (sent_at) WHERE (sent_at IS NOT NULL);


--
-- Name: outbound_messages_telco_service_id; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX outbound_messages_telco_service_id ON sms.outbound_messages_telco USING btree (service_id);


--
-- Name: phone_number_is_cordoned_partial_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX phone_number_is_cordoned_partial_idx ON sms.all_phone_numbers USING btree (cordoned_at) WHERE (released_at IS NULL);


--
-- Name: phone_number_requests_id_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX phone_number_requests_id_idx ON sms.phone_number_requests USING btree (id) WHERE (fulfilled_at IS NULL);


--
-- Name: phone_number_requests_sending_location_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX phone_number_requests_sending_location_idx ON sms.phone_number_requests USING btree (sending_location_id) WHERE (fulfilled_at IS NULL);


--
-- Name: phone_numbers_phone_number_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX phone_numbers_phone_number_idx ON sms.all_phone_numbers USING btree (phone_number);


--
-- Name: prev_mapping_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE UNIQUE INDEX prev_mapping_idx ON sms.from_number_mappings USING btree (to_number, profile_id) WHERE (invalidated_at IS NULL);


--
-- Name: profile_client_id_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX profile_client_id_idx ON sms.profiles USING btree (client_id);


--
-- Name: sending_location_distance_search_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX sending_location_distance_search_idx ON sms.sending_locations USING spgist (location);


--
-- Name: unmatched_delivery_reports_message_service_id_idx; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE INDEX unmatched_delivery_reports_message_service_id_idx ON sms.unmatched_delivery_reports USING btree (message_service_id);


--
-- Name: unqiue_number_for_unfulfilled_fulfilled_at; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE UNIQUE INDEX unqiue_number_for_unfulfilled_fulfilled_at ON sms.phone_number_requests USING btree (phone_number) WHERE (fulfilled_at IS NULL);


--
-- Name: unqiue_number_for_unfulfilled_service_order_id; Type: INDEX; Schema: sms; Owner: postgres
--

CREATE UNIQUE INDEX unqiue_number_for_unfulfilled_service_order_id ON sms.phone_number_requests USING btree (phone_number) WHERE (service_order_id IS NULL);


--
-- Name: accesses _500_fulfill_access; Type: TRIGGER; Schema: lookup; Owner: postgres
--

CREATE TRIGGER _500_fulfill_access BEFORE INSERT ON lookup.accesses FOR EACH ROW EXECUTE FUNCTION lookup.tg__access__fulfill();


--
-- Name: lookups _500_update_phone_data; Type: TRIGGER; Schema: lookup; Owner: postgres
--

CREATE TRIGGER _500_update_phone_data AFTER INSERT ON lookup.lookups FOR EACH ROW EXECUTE FUNCTION lookup.tg__lookup__update_phone_data();


--
-- Name: lookups _500_update_related_accesses; Type: TRIGGER; Schema: lookup; Owner: postgres
--

CREATE TRIGGER _500_update_related_accesses AFTER INSERT ON lookup.lookups FOR EACH ROW EXECUTE FUNCTION lookup.tg__lookup__mark_access_done();


--
-- Name: sending_locations _200_prevent_update_profile; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _200_prevent_update_profile AFTER UPDATE ON sms.sending_locations FOR EACH ROW WHEN ((old.profile_id <> new.profile_id)) EXECUTE FUNCTION sms.tg__prevent_update_sending_location_profile();


--
-- Name: sending_locations _200_set_state_and_location_before_insert; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _200_set_state_and_location_before_insert BEFORE INSERT ON sms.sending_locations FOR EACH ROW EXECUTE FUNCTION sms.tg__sending_locations__set_state_and_location();


--
-- Name: sending_locations _200_set_state_and_location_before_update; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _200_set_state_and_location_before_update BEFORE UPDATE ON sms.sending_locations FOR EACH ROW WHEN (((new.center)::text <> (old.center)::text)) EXECUTE FUNCTION sms.tg__sending_locations__set_state_and_location();


--
-- Name: inbound_messages _500_attach_sending_location; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_attach_sending_location BEFORE INSERT ON sms.inbound_messages FOR EACH ROW EXECUTE FUNCTION sms.tg__inbound_messages__attach_to_sending_location();


--
-- Name: sending_locations _500_cascade_sending_location_decomission; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_cascade_sending_location_decomission AFTER UPDATE ON sms.sending_locations FOR EACH ROW WHEN (((old.decomissioned_at IS NULL) AND (new.decomissioned_at IS NOT NULL))) EXECUTE FUNCTION sms.cascade_sending_location_decomission();


--
-- Name: sending_locations _500_choose_default_area_codes_on_sending_location; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_choose_default_area_codes_on_sending_location BEFORE INSERT ON sms.sending_locations FOR EACH ROW WHEN ((COALESCE(array_length(new.area_codes, 1), 0) = 0)) EXECUTE FUNCTION sms.tg__sending_locations_area_code__prefill();


--
-- Name: all_phone_numbers _500_cordon_prev_mapping; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_cordon_prev_mapping AFTER UPDATE ON sms.all_phone_numbers FOR EACH ROW WHEN ((new.cordoned_at IS DISTINCT FROM old.cordoned_at)) EXECUTE FUNCTION sms.cordon_from_number_mappings();


--
-- Name: all_phone_numbers _500_decomission_phone_number; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_decomission_phone_number AFTER UPDATE ON sms.all_phone_numbers FOR EACH ROW WHEN (((old.released_at IS NULL) AND (new.released_at IS NOT NULL))) EXECUTE FUNCTION public.trigger_sell_number();


--
-- Name: sending_locations _500_find_suitable_area_codes; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_find_suitable_area_codes AFTER INSERT ON sms.sending_locations FOR EACH ROW WHEN ((new.purchasing_strategy = 'same-state-by-distance'::sms.number_purchasing_strategy)) EXECUTE FUNCTION public.trigger_job_with_sending_account_info('find-suitable-area-codes');


--
-- Name: inbound_messages _500_forward_inbound_message; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_forward_inbound_message AFTER INSERT ON sms.inbound_messages FOR EACH ROW EXECUTE FUNCTION public.trigger_job_with_profile_info('forward-inbound-message');


--
-- Name: delivery_reports _500_foward_delivery_report; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_foward_delivery_report AFTER INSERT ON sms.delivery_reports FOR EACH ROW WHEN ((new.is_from_service IS FALSE)) EXECUTE FUNCTION public.trigger_forward_delivery_report_with_profile_info();


--
-- Name: sending_locations _500_inherit_purchasing_strategy; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_inherit_purchasing_strategy BEFORE INSERT ON sms.sending_locations FOR EACH ROW WHEN ((new.purchasing_strategy IS NULL)) EXECUTE FUNCTION sms.tg__sending_locations__strategy_inherit();


--
-- Name: all_phone_numbers _500_invalidate_prev_mapping; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_invalidate_prev_mapping AFTER UPDATE ON sms.all_phone_numbers FOR EACH ROW WHEN ((new.released_at IS DISTINCT FROM old.released_at)) EXECUTE FUNCTION sms.invalidate_from_number_mappings();


--
-- Name: sending_locations _500_notice_modified_sending_location; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_notice_modified_sending_location AFTER UPDATE ON sms.sending_locations FOR EACH ROW EXECUTE FUNCTION public.trigger_job('notice-sending-location-change');


--
-- Name: sending_locations _500_notice_new_sending_location; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_notice_new_sending_location AFTER INSERT ON sms.sending_locations FOR EACH ROW EXECUTE FUNCTION public.trigger_job('notice-sending-location-change');


--
-- Name: outbound_messages _500_process_outbound_message; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_process_outbound_message AFTER INSERT ON sms.outbound_messages FOR EACH ROW WHEN ((new.stage = 'processing'::sms.outbound_message_stages)) EXECUTE FUNCTION sms.tg__trigger_process_message();


--
-- Name: phone_number_requests _500_purchase_number; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_purchase_number AFTER INSERT ON sms.phone_number_requests FOR EACH ROW EXECUTE FUNCTION public.trigger_job_with_sending_account_and_profile_info('purchase-number');


--
-- Name: sending_locations _500_queue_determine_area_code_capacity_after_insert; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_queue_determine_area_code_capacity_after_insert AFTER INSERT ON sms.sending_locations FOR EACH ROW WHEN (((new.area_codes IS NOT NULL) AND (array_length(new.area_codes, 1) > 0) AND (new.purchasing_strategy = 'exact-area-codes'::sms.number_purchasing_strategy))) EXECUTE FUNCTION public.trigger_job_with_sending_account_info('estimate-area-code-capacity');


--
-- Name: sending_locations _500_queue_determine_area_code_capacity_after_update; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_queue_determine_area_code_capacity_after_update AFTER UPDATE ON sms.sending_locations FOR EACH ROW WHEN (((old.area_codes <> new.area_codes) AND (array_length(new.area_codes, 1) > 0) AND (new.purchasing_strategy = 'exact-area-codes'::sms.number_purchasing_strategy))) EXECUTE FUNCTION public.trigger_job_with_sending_account_info('estimate-area-code-capacity');


--
-- Name: phone_number_requests _500_queue_messages_after_fulfillment; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_queue_messages_after_fulfillment AFTER UPDATE ON sms.phone_number_requests FOR EACH ROW WHEN (((old.fulfilled_at IS NULL) AND (new.fulfilled_at IS NOT NULL) AND (new.phone_number IS NOT NULL))) EXECUTE FUNCTION sms.tg__phone_number_requests__fulfill();


--
-- Name: outbound_messages_routing _500_send_message_after_fulfillment; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_send_message_after_fulfillment AFTER UPDATE ON sms.outbound_messages_routing FOR EACH ROW WHEN (((old.stage = 'awaiting-number'::sms.outbound_message_stages) AND (new.stage = 'queued'::sms.outbound_message_stages))) EXECUTE FUNCTION sms.trigger_send_message();


--
-- Name: outbound_messages_routing _500_send_message_after_process; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_send_message_after_process AFTER UPDATE ON sms.outbound_messages_routing FOR EACH ROW WHEN (((new.stage = 'queued'::sms.outbound_message_stages) AND (old.stage = 'processing'::sms.outbound_message_stages))) EXECUTE FUNCTION sms.trigger_send_message();


--
-- Name: outbound_messages_routing _500_send_message_basic; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_send_message_basic AFTER INSERT ON sms.outbound_messages_routing FOR EACH ROW WHEN ((new.stage = 'queued'::sms.outbound_message_stages)) EXECUTE FUNCTION sms.trigger_send_message();


--
-- Name: phone_number_requests _500_set_request_type; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_set_request_type BEFORE INSERT ON sms.phone_number_requests FOR EACH ROW EXECUTE FUNCTION sms.tg__set_phone_request_type();


--
-- Name: inbound_messages _500_update_prev_mapping_after_inbound_received; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_update_prev_mapping_after_inbound_received AFTER INSERT ON sms.inbound_messages FOR EACH ROW EXECUTE FUNCTION sms.update_from_number_mappings_after_inbound_received();


--
-- Name: outbound_messages_routing _500_update_prev_mapping_after_routing; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_update_prev_mapping_after_routing AFTER INSERT ON sms.outbound_messages_routing FOR EACH ROW WHEN ((new.decision_stage <> 'toll_free'::text)) EXECUTE FUNCTION sms.update_from_number_mappings_after_routing();


--
-- Name: profile_service_configurations _500_updated_at; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_updated_at BEFORE UPDATE ON sms.profile_service_configurations FOR EACH ROW EXECUTE FUNCTION public.universal_updated_at();


--
-- Name: telnyx_profile_service_configurations _500_updated_at; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_updated_at BEFORE UPDATE ON sms.telnyx_profile_service_configurations FOR EACH ROW EXECUTE FUNCTION public.universal_updated_at();


--
-- Name: tendlc_campaign_mno_metadata _500_updated_at; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_updated_at BEFORE UPDATE ON sms.tendlc_campaign_mno_metadata FOR EACH ROW EXECUTE FUNCTION public.universal_updated_at();


--
-- Name: tendlc_campaigns _500_updated_at; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_updated_at BEFORE UPDATE ON sms.tendlc_campaigns FOR EACH ROW EXECUTE FUNCTION public.universal_updated_at();


--
-- Name: toll_free_use_cases _500_updated_at; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_updated_at BEFORE UPDATE ON sms.toll_free_use_cases FOR EACH ROW EXECUTE FUNCTION public.universal_updated_at();


--
-- Name: twilio_profile_service_configurations _500_updated_at; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _500_updated_at BEFORE UPDATE ON sms.twilio_profile_service_configurations FOR EACH ROW EXECUTE FUNCTION public.universal_updated_at();


--
-- Name: sending_locations _700_sync_profile_provisioned; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _700_sync_profile_provisioned AFTER INSERT OR DELETE OR UPDATE ON sms.sending_locations FOR EACH ROW EXECUTE FUNCTION sms.tg__sync_profile_provisioned();


--
-- Name: toll_free_use_cases _700_sync_profile_provisioned; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _700_sync_profile_provisioned AFTER INSERT ON sms.toll_free_use_cases FOR EACH ROW EXECUTE FUNCTION sms.tg__sync_toll_free_profile_provisioned();


--
-- Name: sending_locations _700_sync_profile_provisioned_after_update; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _700_sync_profile_provisioned_after_update AFTER UPDATE ON sms.sending_locations FOR EACH ROW WHEN ((old.decomissioned_at IS DISTINCT FROM new.decomissioned_at)) EXECUTE FUNCTION sms.tg__sync_profile_provisioned();


--
-- Name: toll_free_use_cases _700_sync_profile_provisioned_after_update; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER _700_sync_profile_provisioned_after_update AFTER UPDATE ON sms.toll_free_use_cases FOR EACH ROW WHEN ((old.phone_number_id IS DISTINCT FROM new.phone_number_id)) EXECUTE FUNCTION sms.tg__sync_toll_free_profile_provisioned();


--
-- Name: delivery_report_forward_attempts ts_insert_blocker; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON sms.delivery_report_forward_attempts FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: delivery_reports ts_insert_blocker; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON sms.delivery_reports FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: inbound_message_forward_attempts ts_insert_blocker; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON sms.inbound_message_forward_attempts FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: inbound_messages ts_insert_blocker; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON sms.inbound_messages FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: outbound_messages ts_insert_blocker; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON sms.outbound_messages FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: outbound_messages_routing ts_insert_blocker; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON sms.outbound_messages_routing FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: outbound_messages_telco ts_insert_blocker; Type: TRIGGER; Schema: sms; Owner: postgres
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON sms.outbound_messages_telco FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: lrn_usage_rollups lrn_usage_rollups_client_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: postgres
--

ALTER TABLE ONLY billing.lrn_usage_rollups
    ADD CONSTRAINT lrn_usage_rollups_client_id_fkey FOREIGN KEY (client_id) REFERENCES billing.clients(id);


--
-- Name: messaging_usage_rollups messaging_usage_rollups_profile_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: postgres
--

ALTER TABLE ONLY billing.messaging_usage_rollups
    ADD CONSTRAINT messaging_usage_rollups_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES sms.profiles(id);


--
-- Name: stripe_customer_subscriptions stripe_customer_subscriptions_customer_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: postgres
--

ALTER TABLE ONLY billing.stripe_customer_subscriptions
    ADD CONSTRAINT stripe_customer_subscriptions_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES billing.stripe_customers(id);


--
-- Name: stripe_customers stripe_customers_client_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: postgres
--

ALTER TABLE ONLY billing.stripe_customers
    ADD CONSTRAINT stripe_customers_client_id_fkey FOREIGN KEY (client_id) REFERENCES billing.clients(id);


--
-- Name: accesses accesses_client_id_fkey; Type: FK CONSTRAINT; Schema: lookup; Owner: postgres
--

ALTER TABLE ONLY lookup.accesses
    ADD CONSTRAINT accesses_client_id_fkey FOREIGN KEY (client_id) REFERENCES billing.clients(id);


--
-- Name: accesses accesses_request_id_fkey; Type: FK CONSTRAINT; Schema: lookup; Owner: postgres
--

ALTER TABLE ONLY lookup.accesses
    ADD CONSTRAINT accesses_request_id_fkey FOREIGN KEY (request_id) REFERENCES lookup.requests(id);


--
-- Name: requests requests_client_id_fkey; Type: FK CONSTRAINT; Schema: lookup; Owner: postgres
--

ALTER TABLE ONLY lookup.requests
    ADD CONSTRAINT requests_client_id_fkey FOREIGN KEY (client_id) REFERENCES billing.clients(id);


--
-- Name: area_code_capacities area_code_capacities_sending_account_id_fkey; Type: FK CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.area_code_capacities
    ADD CONSTRAINT area_code_capacities_sending_account_id_fkey FOREIGN KEY (sending_account_id) REFERENCES sms.sending_accounts(id);


--
-- Name: fresh_phone_commitments fresh_phone_commitments_sending_location_id_fkey; Type: FK CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.fresh_phone_commitments
    ADD CONSTRAINT fresh_phone_commitments_sending_location_id_fkey FOREIGN KEY (sending_location_id) REFERENCES sms.sending_locations(id) ON DELETE CASCADE;


--
-- Name: from_number_mappings from_number_mappings_profile_id_fkey; Type: FK CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.from_number_mappings
    ADD CONSTRAINT from_number_mappings_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES sms.profiles(id) ON DELETE CASCADE;


--
-- Name: inbound_messages inbound_messages_sending_location_id_fkey; Type: FK CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.inbound_messages
    ADD CONSTRAINT inbound_messages_sending_location_id_fkey FOREIGN KEY (sending_location_id) REFERENCES sms.sending_locations(id);


--
-- Name: outbound_messages_awaiting_from_number outbound_messages_awaiting_from__pending_number_request_id_fkey; Type: FK CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.outbound_messages_awaiting_from_number
    ADD CONSTRAINT outbound_messages_awaiting_from__pending_number_request_id_fkey FOREIGN KEY (pending_number_request_id) REFERENCES sms.phone_number_requests(id);


--
-- Name: outbound_messages_awaiting_from_number outbound_messages_awaiting_from_number_profile_id_fkey; Type: FK CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.outbound_messages_awaiting_from_number
    ADD CONSTRAINT outbound_messages_awaiting_from_number_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES sms.profiles(id) ON DELETE CASCADE;


--
-- Name: outbound_messages_routing outbound_messages_routing_profile_id_fkey; Type: FK CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.outbound_messages_routing
    ADD CONSTRAINT outbound_messages_routing_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES sms.profiles(id) ON DELETE CASCADE;


--
-- Name: phone_number_requests phone_number_requests_sending_location_id_fkey; Type: FK CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.phone_number_requests
    ADD CONSTRAINT phone_number_requests_sending_location_id_fkey FOREIGN KEY (sending_location_id) REFERENCES sms.sending_locations(id);


--
-- Name: phone_number_requests phone_number_requests_tendlc_campaign_id_fkey; Type: FK CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.phone_number_requests
    ADD CONSTRAINT phone_number_requests_tendlc_campaign_id_fkey FOREIGN KEY (tendlc_campaign_id) REFERENCES sms.tendlc_campaigns(id);


--
-- Name: all_phone_numbers phone_numbers_sending_location_id_fkey; Type: FK CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.all_phone_numbers
    ADD CONSTRAINT phone_numbers_sending_location_id_fkey FOREIGN KEY (sending_location_id) REFERENCES sms.sending_locations(id);


--
-- Name: profile_service_configurations profile_service_configurations_telnyx_configuration_id_fkey; Type: FK CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.profile_service_configurations
    ADD CONSTRAINT profile_service_configurations_telnyx_configuration_id_fkey FOREIGN KEY (telnyx_configuration_id) REFERENCES sms.telnyx_profile_service_configurations(id) ON DELETE CASCADE;


--
-- Name: profile_service_configurations profile_service_configurations_twilio_configuration_id_fkey; Type: FK CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.profile_service_configurations
    ADD CONSTRAINT profile_service_configurations_twilio_configuration_id_fkey FOREIGN KEY (twilio_configuration_id) REFERENCES sms.twilio_profile_service_configurations(id) ON DELETE CASCADE;


--
-- Name: profiles profiles_client_id_fkey; Type: FK CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.profiles
    ADD CONSTRAINT profiles_client_id_fkey FOREIGN KEY (client_id) REFERENCES billing.clients(id);


--
-- Name: profiles profiles_profile_service_configuration_id_fkey; Type: FK CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.profiles
    ADD CONSTRAINT profiles_profile_service_configuration_id_fkey FOREIGN KEY (profile_service_configuration_id) REFERENCES sms.profile_service_configurations(id) ON DELETE CASCADE;


--
-- Name: profiles profiles_sending_account_id_fkey; Type: FK CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.profiles
    ADD CONSTRAINT profiles_sending_account_id_fkey FOREIGN KEY (sending_account_id) REFERENCES sms.sending_accounts(id);


--
-- Name: profiles profiles_tendlc_campaign_id_fkey; Type: FK CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.profiles
    ADD CONSTRAINT profiles_tendlc_campaign_id_fkey FOREIGN KEY (tendlc_campaign_id) REFERENCES sms.tendlc_campaigns(id);


--
-- Name: profiles profiles_toll_free_use_case_id_fkey; Type: FK CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.profiles
    ADD CONSTRAINT profiles_toll_free_use_case_id_fkey FOREIGN KEY (toll_free_use_case_id) REFERENCES sms.toll_free_use_cases(id);


--
-- Name: sending_locations sending_locations_profile_id_fkey; Type: FK CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.sending_locations
    ADD CONSTRAINT sending_locations_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES sms.profiles(id);


--
-- Name: tendlc_campaign_mno_metadata tendlc_campaign_mno_metadata_campaign_id_fkey; Type: FK CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.tendlc_campaign_mno_metadata
    ADD CONSTRAINT tendlc_campaign_mno_metadata_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES sms.tendlc_campaigns(id);


--
-- Name: tendlc_campaigns tendlc_campaigns_registrar_account_id_fkey; Type: FK CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.tendlc_campaigns
    ADD CONSTRAINT tendlc_campaigns_registrar_account_id_fkey FOREIGN KEY (registrar_account_id) REFERENCES sms.sending_accounts(id);


--
-- Name: tendlc_campaigns tendlc_campaigns_tcr_account_id_fkey; Type: FK CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.tendlc_campaigns
    ADD CONSTRAINT tendlc_campaigns_tcr_account_id_fkey FOREIGN KEY (tcr_account_id) REFERENCES sms.sending_accounts(id);


--
-- Name: toll_free_use_cases toll_free_use_cases_client_id_fkey; Type: FK CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.toll_free_use_cases
    ADD CONSTRAINT toll_free_use_cases_client_id_fkey FOREIGN KEY (client_id) REFERENCES billing.clients(id);


--
-- Name: toll_free_use_cases toll_free_use_cases_phone_number_id_fkey; Type: FK CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.toll_free_use_cases
    ADD CONSTRAINT toll_free_use_cases_phone_number_id_fkey FOREIGN KEY (phone_number_id) REFERENCES sms.all_phone_numbers(id);


--
-- Name: toll_free_use_cases toll_free_use_cases_phone_number_request_id_fkey; Type: FK CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.toll_free_use_cases
    ADD CONSTRAINT toll_free_use_cases_phone_number_request_id_fkey FOREIGN KEY (phone_number_request_id) REFERENCES sms.phone_number_requests(id);


--
-- Name: toll_free_use_cases toll_free_use_cases_sending_account_id_fkey; Type: FK CONSTRAINT; Schema: sms; Owner: postgres
--

ALTER TABLE ONLY sms.toll_free_use_cases
    ADD CONSTRAINT toll_free_use_cases_sending_account_id_fkey FOREIGN KEY (sending_account_id) REFERENCES sms.sending_accounts(id);


--
-- Name: clients; Type: ROW SECURITY; Schema: billing; Owner: postgres
--

ALTER TABLE billing.clients ENABLE ROW LEVEL SECURITY;

--
-- Name: clients clients_policy; Type: POLICY; Schema: billing; Owner: postgres
--

CREATE POLICY clients_policy ON billing.clients TO client USING ((id = billing.current_client_id()));


--
-- Name: accesses accesess_policy; Type: POLICY; Schema: lookup; Owner: postgres
--

CREATE POLICY accesess_policy ON lookup.accesses TO client USING ((client_id = billing.current_client_id()));


--
-- Name: accesses; Type: ROW SECURITY; Schema: lookup; Owner: postgres
--

ALTER TABLE lookup.accesses ENABLE ROW LEVEL SECURITY;

--
-- Name: requests; Type: ROW SECURITY; Schema: lookup; Owner: postgres
--

ALTER TABLE lookup.requests ENABLE ROW LEVEL SECURITY;

--
-- Name: requests requests_policy; Type: POLICY; Schema: lookup; Owner: postgres
--

CREATE POLICY requests_policy ON lookup.requests TO client USING ((client_id = billing.current_client_id()));


--
-- Name: all_phone_numbers; Type: ROW SECURITY; Schema: sms; Owner: postgres
--

ALTER TABLE sms.all_phone_numbers ENABLE ROW LEVEL SECURITY;

--
-- Name: all_phone_numbers client_phone_numbers_policy; Type: POLICY; Schema: sms; Owner: postgres
--

CREATE POLICY client_phone_numbers_policy ON sms.all_phone_numbers TO client USING ((EXISTS ( SELECT 1
   FROM sms.sending_locations
  WHERE (sending_locations.id = all_phone_numbers.sending_location_id)))) WITH CHECK ((EXISTS ( SELECT 1
   FROM sms.sending_locations
  WHERE (sending_locations.id = all_phone_numbers.sending_location_id))));


--
-- Name: profiles client_profile_policy; Type: POLICY; Schema: sms; Owner: postgres
--

CREATE POLICY client_profile_policy ON sms.profiles FOR SELECT TO client USING ((client_id = billing.current_client_id()));


--
-- Name: sending_locations client_sending_location_policy; Type: POLICY; Schema: sms; Owner: postgres
--

CREATE POLICY client_sending_location_policy ON sms.sending_locations TO client USING ((EXISTS ( SELECT 1
   FROM sms.profiles
  WHERE (profiles.id = sending_locations.profile_id)))) WITH CHECK ((EXISTS ( SELECT 1
   FROM sms.profiles
  WHERE (profiles.id = sending_locations.profile_id))));


--
-- Name: profile_service_configurations; Type: ROW SECURITY; Schema: sms; Owner: postgres
--

ALTER TABLE sms.profile_service_configurations ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles; Type: ROW SECURITY; Schema: sms; Owner: postgres
--

ALTER TABLE sms.profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: sending_locations; Type: ROW SECURITY; Schema: sms; Owner: postgres
--

ALTER TABLE sms.sending_locations ENABLE ROW LEVEL SECURITY;

--
-- Name: telnyx_profile_service_configurations; Type: ROW SECURITY; Schema: sms; Owner: postgres
--

ALTER TABLE sms.telnyx_profile_service_configurations ENABLE ROW LEVEL SECURITY;

--
-- Name: tendlc_campaign_mno_metadata; Type: ROW SECURITY; Schema: sms; Owner: postgres
--

ALTER TABLE sms.tendlc_campaign_mno_metadata ENABLE ROW LEVEL SECURITY;

--
-- Name: tendlc_campaigns; Type: ROW SECURITY; Schema: sms; Owner: postgres
--

ALTER TABLE sms.tendlc_campaigns ENABLE ROW LEVEL SECURITY;

--
-- Name: toll_free_use_cases; Type: ROW SECURITY; Schema: sms; Owner: postgres
--

ALTER TABLE sms.toll_free_use_cases ENABLE ROW LEVEL SECURITY;

--
-- Name: twilio_profile_service_configurations; Type: ROW SECURITY; Schema: sms; Owner: postgres
--

ALTER TABLE sms.twilio_profile_service_configurations ENABLE ROW LEVEL SECURITY;

--
-- Name: SCHEMA billing; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA billing TO client;


--
-- Name: SCHEMA geo; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA geo TO client;


--
-- Name: SCHEMA lookup; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA lookup TO client;


--
-- Name: SCHEMA sms; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA sms TO client;


--
-- Name: FUNCTION current_client_id(); Type: ACL; Schema: billing; Owner: postgres
--

GRANT ALL ON FUNCTION billing.current_client_id() TO client;


--
-- Name: TABLE requests; Type: ACL; Schema: lookup; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE lookup.requests TO client;


--
-- Name: FUNCTION send_message(profile_id uuid, "to" public.phone_number, body text, media_urls public.url[], contact_zip_code public.zip_code, send_before timestamp without time zone); Type: ACL; Schema: sms; Owner: postgres
--

GRANT ALL ON FUNCTION sms.send_message(profile_id uuid, "to" public.phone_number, body text, media_urls public.url[], contact_zip_code public.zip_code, send_before timestamp without time zone) TO client;


--
-- Name: TABLE sending_locations; Type: ACL; Schema: sms; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,TRIGGER ON TABLE sms.sending_locations TO client;


--
-- Name: TABLE clients; Type: ACL; Schema: billing; Owner: postgres
--

GRANT SELECT ON TABLE billing.clients TO client;


--
-- Name: TABLE profiles; Type: ACL; Schema: sms; Owner: postgres
--

GRANT SELECT ON TABLE sms.profiles TO client;


--
-- Name: TABLE accesses; Type: ACL; Schema: lookup; Owner: postgres
--

GRANT SELECT,INSERT ON TABLE lookup.accesses TO client;


--
-- Name: TABLE all_phone_numbers; Type: ACL; Schema: sms; Owner: postgres
--

GRANT SELECT ON TABLE sms.all_phone_numbers TO client;


--
-- Name: TABLE zip_area_codes; Type: ACL; Schema: geo; Owner: postgres
--

GRANT SELECT ON TABLE geo.zip_area_codes TO client;


--
-- Name: TABLE fresh_phone_data; Type: ACL; Schema: lookup; Owner: postgres
--

GRANT SELECT ON TABLE lookup.fresh_phone_data TO client;


--
-- Name: TABLE request_results; Type: ACL; Schema: lookup; Owner: postgres
--

GRANT SELECT ON TABLE lookup.request_results TO client;


--
-- Name: TABLE sending_accounts_as_json; Type: ACL; Schema: sms; Owner: postgres
--

GRANT SELECT ON TABLE sms.sending_accounts_as_json TO client;


--
-- PostgreSQL database dump complete
--

