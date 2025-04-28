-- pgr_fn.toScramSH256

-- drop function if exists pgr_fn."toScramSH256"(varchar);
-- select pgr_fn."toScramSH256"(null);
-- select pgr_fn."toScramSH256"('test');

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
    "tmpRoleName"   varchar = 'temp_scram_gen_' || replace(gen_random_uuid()::text, '-', '');
    "scramPassword" varchar;
begin
    /**
        Generates the SCRAM-SHA-256 encrypted string.
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
    execute format('CREATE ROLE %I WITH NOLOGIN PASSWORD %L', "tmpRoleName", "inStringToHash");

    -- Retrieve the SCRAM-SHA-256 hashed password from pg_authid
    select
        rolpassword::varchar
    into "scramPassword"
    from pg_authid
    where
        rolname = "tmpRoleName";

    -- Drop the temporary role
    execute format('DROP ROLE %I', "tmpRoleName");

    -- Return the SCRAM-SHA-256 string
    return "scramPassword";
end;
$$;

alter function pgr_fn."toScramSH256"(varchar) owner to postgres;

comment on function pgr_fn."toScramSH256"
    is 'Creates SCRAM-SHA-256 encrypted string';

