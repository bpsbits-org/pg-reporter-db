-- pgr_app.sessionPing

-- drop function if exists pgr_app."sessionPing"(uuid, jsonb, boolean);
-- select pgr_app."sessionPing"(null, null, null);

create or replace function pgr_app."sessionPing"(
    "inSessionHash" uuid,
    "inClientInfo" jsonb default '{}'::jsonb,
    "inIsSessionPing" boolean default false)
    returns uuid
    security definer
    language plpgsql
    strict
    volatile
    cost 50
as
$$
declare
    "activeSessionStorageId" uuid;
    "activeSessionOwnerId"   uuid;
    "pingType"               varchar := case when "inIsSessionPing" = true then 'isSessionPing' else 'isSessionValidation' end;
begin
    /**
        Validates that a given session exists and is active.
        @author bpsbits.org
        @package pgReporter
    */

    -- Purge expired sessions first
    call pgr_app."sessionClearExpired"();

    -- Find session
    select
        acs."sessionStorageId",
        acs."sessionOwner"
    into "activeSessionStorageId", "activeSessionOwnerId"
    from pgr_app."ActiveSessions" acs
    where
          acs."sessionHash" = "inSessionHash"
      and acs."sessionExpires" > (current_timestamp at time zone 'UTC');

    -- If not valid session
    if "activeSessionOwnerId" is null then
        return null;
    end if;

    perform pgr_app."sessionSeen"("activeSessionStorageId", "pingType", "inClientInfo");

    -- Return a session owner id
    return "activeSessionOwnerId";
end;
$$;

alter function pgr_app."sessionPing"(uuid, jsonb, boolean) owner to postgres;

grant execute on function pgr_app."sessionPing"(uuid, jsonb, boolean) to app_pgr_api;

comment on function pgr_app."sessionPing"
    is 'Validates that a given session exists and is active.';
