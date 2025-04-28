-- pgr_app.sessionSeen

-- drop function if exists pgr_app."sessionSeen"(uuid, varchar, jsonb);
-- select pgr_app."sessionSeen"(null, null, null);

create or replace function pgr_app."sessionSeen"(
    "inSessionStorageId" uuid,
    "inType" varchar default 'isSessionPing',
    "inClientInfo" jsonb default '{}'::jsonb)
    returns uuid
    security definer
    language plpgsql
    strict
    volatile
    cost 25
as
$$
declare
    "sanClientInfo" jsonb   := jsonb_strip_nulls("inClientInfo");
    "outLastSeenId" uuid;
    "sanType"       varchar := coalesce(nullif(regexp_replace("inType", '[^a-zA-Z]', '', 'g'), ''), 'isSessionPing');
begin
    /**
        Creates last seen record.
        @author bpsbits.org
        @package pgReporter
    */

    -- Create a last-seen record
    insert into pgr_app."LastSeen" ("sessionStorageId", "lastSeenAttributes", "clientInfo")
    values ("inSessionStorageId", jsonb_build_object("sanType", true), "sanClientInfo")
    returning "lastSeenId" into "outLastSeenId";

    -- Return a session owner id
    return "outLastSeenId";
end;
$$;

alter function pgr_app."sessionSeen"(uuid, varchar, jsonb) owner to postgres;

grant execute on function pgr_app."sessionSeen"(uuid, varchar, jsonb) to app_pgr_api;

comment on function pgr_app."sessionSeen"
    is 'Creates last seen record';
