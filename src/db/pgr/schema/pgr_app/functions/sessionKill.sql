-- pgr_app.sessionKill

-- drop function if exists pgr_app."sessionKill"(uuid, jsonb);
-- select pgr_app."sessionKill"(null, null);

create or replace function pgr_app."sessionKill"(
    "inSessionHash" uuid,
    "inClientInfo" jsonb default '{}'::jsonb)
    returns boolean
    security definer
    language plpgsql
    volatile
    cost 50
as
$$
declare
    "activeSessionStorageId" uuid;
    "deleteCount"            integer := 0;
begin
    /**
        Kills given session if exists.
        @author bpsbits.org
        @package pgReporter
    */
    -- Sanitize and validate inputs
    if "inSessionHash" is null then
        return false;
    end if;

    -- Find session
    select
        acs."sessionStorageId"
    into "activeSessionStorageId"
    from pgr_app."ActiveSessions" acs
    where
        acs."sessionHash" = "inSessionHash";

    -- If not valid session
    if "activeSessionStorageId" is null then
        return false;
    end if;

    perform pgr_app."sessionSeen"("activeSessionStorageId", 'isSessionKill', "inClientInfo");

    -- Delete session
    delete from pgr_app."ActiveSessions" where "sessionStorageId" = "activeSessionStorageId";
    get diagnostics "deleteCount" = row_count;

    -- Return a session owner id
    return "deleteCount" > 0;
end;
$$;

alter function pgr_app."sessionKill"(uuid, jsonb) owner to postgres;

grant execute on function pgr_app."sessionKill"(uuid, jsonb) to app_pgr_api;

comment on function pgr_app."sessionKill"
    is 'Kills given session.';
