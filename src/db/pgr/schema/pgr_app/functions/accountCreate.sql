-- pgr_app.accountCreate

-- drop function if exists pgr_app."accountCreate"(varchar, varchar, jsonb);

create or replace function pgr_app."accountCreate"(
    "inLogin" varchar,
    "inPswHash" varchar,
    "inAttributes" jsonb default '{}'::jsonb)
    returns uuid
    language plpgsql
    security definer
    volatile
    parallel unsafe
    strict
    cost 1000
as
$$
declare
    "accountIdOut"  uuid    := null;
    "sanAttributes" jsonb   := coalesce(pgr_fn."jsonbStripEmpty"("inAttributes"), '{}'::jsonb);
    "sanLogin"      varchar := regexp_replace(coalesce("inLogin", ''), '^\s+|\s+$', '');
    "sanPswHash"    varchar := regexp_replace(coalesce("inPswHash", ''), '^\s+|\s+$', '');
begin
    /**
        Creates a user account.
        @author bpsbits.org
        @package pgReporter
    */
    -- Sanitize and validate input
    if jsonb_typeof("inAttributes") != 'object' then
        raise exception
            using
                message = 'Account attributes must be a JSON object' ,
                errcode = '22023';
    end if;
    if length("sanLogin") < 8 then
        raise exception
            using
                message = 'Login should be at least 8 characters long',
                errcode = '22023';
    end if;
    if length("sanPswHash") < 64 then
        raise exception
            using
                message = 'Password hash is required',
                errcode = '22023';
    end if;

    -- Ensure that the login name is not taken
    if exists(select
                  1
              from pgr_app."Accounts" acc
              where
                  acc."accountLogin" = "sanLogin") then
        raise exception
            using
                message = 'Given username cannot be used',
                errcode = '23505';
    end if;

    -- Create an account
    insert into pgr_app."Accounts" ("accountLogin", "accountLoginHash", "accountAttributes")
    values ("sanLogin", "sanPswHash", "sanAttributes")
    returning "accountId" into "accountIdOut";

    -- Return account id
    return "accountIdOut";
end;
$$;

alter function pgr_app."accountCreate"(varchar, varchar, jsonb) owner to postgres;

grant execute on function pgr_app."accountCreate"(varchar, varchar, jsonb) to app_pgr_api;

comment on function pgr_app."accountCreate"
    is 'Creates a user account';
