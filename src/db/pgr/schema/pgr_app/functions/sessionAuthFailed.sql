-- pgr_app.sessionAuthFailed

-- drop function if exists pgr_app."sessionAuthFailed"(varchar, varchar, jsonb);
-- select pgr_app."sessionAuthFailed"(null, null, null);

create or replace function pgr_app."sessionAuthFailed"(
    "inLogin" varchar,
    "inMessage" varchar default 'Authorization failed',
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
    "sanClientInfo"   jsonb := jsonb_strip_nulls("inClientInfo");
    "outFailedAuthId" uuid;
begin
    /**
        Creates a failed auth record
        @author bpsbits.org
        @package pgReporter
    */

    -- Create a session authorization failed record
    insert into pgr_app."FailedAuthorizations"(login, info, "clientInfo")
    values ("inLogin", trim("inMessage"), "sanClientInfo")
    returning "failedAuthId" into "outFailedAuthId";

    -- Return id
    return "outFailedAuthId";
end;
$$;

alter function pgr_app."sessionAuthFailed"(varchar, varchar, jsonb) owner to postgres;

grant execute on function pgr_app."sessionAuthFailed"(varchar, varchar, jsonb) to app_pgr_api;

comment on function pgr_app."sessionAuthFailed"
    is 'Creates a failed auth record';
