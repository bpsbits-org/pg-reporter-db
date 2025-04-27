-- pgr_fn.toScramSH256

-- drop function if exists pgr_fn."toScramSH256"(varchar);

create or replace function pgr_fn."toScramSH256"("inStringToHash" varchar)
    returns varchar
    security definer
    language plpgsql
    strict
    parallel safe
    cost 100
as
$$
declare
    "tmpRoleName"   text := 'temp_scram_gen_' || replace(gen_random_uuid()::text, '-', '');
    "scramPassword" text;
begin
    /**
        Generates an SHA-256 encrypted string.
        Used for encrypted passwords storage.
        @author bpsbits.org
        @package pgReporter
    */

    -- Ensure pgcrypto is enabled
    if not exists (select 1 from pg_extension where extname = 'pgcrypto') then
        raise exception 'pgcrypto extension is required'
            using errcode = '0A000',
                hint = 'Please run: CREATE EXTENSION pgcrypto;';
    end if;

    -- Create a temporary role with the provided string
    execute format('CREATE ROLE %I WITH LOGIN ENCRYPTED PASSWORD %L', "tmpRoleName", "inStringToHash");

    -- Retrieve the SCRAM-SHA-256 hashed password from pg_authid
    select
        rolpassword
    into "scramPassword"
    from pg_authid
    where
        rolname = "tmpRoleName"

    -- Drop the temporary role
    execute format('DROP ROLE %I', "tmpRoleName");

    -- Return the SCRAM-SHA-256 string
    return "scramPassword"::varchar;
end;
$$;

alter function pgr_fn."toScramSH256"(varchar) owner to postgres;

grant execute on function pgr_fn."toScramSH256"(varchar) to public;

comment on function pgr_fn."toScramSH256"
    is 'Creates SHA-256 encrypted string';
