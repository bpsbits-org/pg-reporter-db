-- pgr_app.sessionInit

-- drop function if exists pgr_app."sessionInit"(varchar,varchar,jsonb);
-- select pgr_app."sessionInit"(null, null, null);

create or replace function pgr_app."sessionInit"(
    "inLogin" varchar,
    "inPswHash" varchar,
    "inClientInfo" jsonb default '{}'::jsonb
)
    returns jsonb
    security definer
    language plpgsql
    volatile
    cost 200
as
$$
declare
    "sanLogin"             varchar;
    "sanPswHash"           varchar;
    "sanClientInfo"        jsonb;
    "accountId"            uuid;
    "fnResult"             jsonb := jsonb_build_object(
            'rId', pgr_fn."genUuidV7"(),
            'success', false,
            'message', 'Failed to create session',
            'id', null);
    "sessionHashOut"       uuid;
    "sessionId"            uuid;
    "newSessionStorageId"  uuid;
    "newSessionAttributes" jsonb := '{}'::jsonb;
begin
    /**
        Validates login credentials and creates a session and returns session id.
        @author bpsbits.org
        @package pgReporter
    */

    -- Sanitize and validate inputs
    "sanClientInfo" = jsonb_strip_nulls(coalesce("inClientInfo", '{}'::jsonb));
    "sanLogin" = regexp_replace(coalesce("inLogin", ''), '^\s+|\s+$', '');
    if length("sanLogin") < 8 then
        "fnResult" = ("fnResult" || jsonb_build_object('message', 'Invalid login input'));
        perform pgr_app."sessionAuthFailed"("sanLogin", ("fnResult" ->> 'message')::varchar, "sanClientInfo");
        return "fnResult";
    end if;
    "sanPswHash" = regexp_replace(coalesce("inPswHash", ''), '^\s+|\s+$', '');
    if length("inPswHash") < 64 then
        "fnResult" = ("fnResult" || jsonb_build_object('message', 'Invalid password input'));
        perform pgr_app."sessionAuthFailed"("sanLogin", ("fnResult" ->> 'message')::varchar, "sanClientInfo");
        return "fnResult";
    end if;

    -- Validate user credentials
    "accountId" = pgr_app."accountValidateLogin"("sanLogin", "sanPswHash");
    if "accountId" is null then
        "fnResult" = ("fnResult" || jsonb_build_object('message', 'Invalid login credentials'));
        perform pgr_app."sessionAuthFailed"("sanLogin", ("fnResult" ->> 'message')::varchar, "sanClientInfo");
        return "fnResult";
    end if;

    -- Create session
    "sessionId" = pgr_fn."genUuidV7"();
    "sessionHashOut" = encode(decode(md5("sessionId"::varchar), 'hex'), 'hex')::uuid;
    insert into pgr_app."ActiveSessions" ("sessionHash", "sessionOwner", "sessionAttributes")
    values ("sessionHashOut", "accountId", "newSessionAttributes")
    returning "sessionStorageId" into "newSessionStorageId";

    -- Validate that session storage id is returned
    if "newSessionStorageId" is null then
        perform pgr_app."sessionAuthFailed"("sanLogin", ("fnResult" ->> 'message')::varchar, "sanClientInfo");
        return "fnResult";
    end if;

    perform pgr_app."sessionSeen"("newSessionStorageId", 'isSessionInit', "sanClientInfo");

    -- Return session info
    return ("fnResult" || jsonb_build_object('success', true, 'message', 'Session initialized', 'id', "sessionId"));

end;
$$;

alter function pgr_app."sessionInit"(varchar,varchar,jsonb) owner to postgres;

grant execute on function pgr_app."sessionInit"(varchar,varchar,jsonb) to app_pgr_api;

comment on function pgr_app."sessionInit"
    is 'Validates login credentials and creates a session.';
