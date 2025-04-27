-- pgr_app.toSimpleHash

-- drop function if exists pgr_fn."toSimpleHash"(varchar);

create or replace function pgr_fn."toSimpleHash"("inStringToHash" varchar)
    returns varchar
    security definer
    language plpgsql
    immutable
    leakproof
    strict
    parallel safe
    cost 1000
as
$$
declare
    hash         bytea;
    i            integer;
    "hashB64"    text;
    "sanPswHash" text;
    iterations   integer := 100000;
    "minLength"  integer := 12;
begin
    /**
        Generates a simple hash using SHA-512 with several iterations.
        The identical value is consistently produced for the equivalent input.
        @author bpsbits.org
        @package pgReporter
    */

    -- Ensure pgcrypto is enabled
    if not exists (select 1 from pg_extension where extname = 'pgcrypto') then
        raise exception 'pgcrypto extension is required'
            using errcode = '0A000',
                hint = 'Please run: CREATE EXTENSION pgcrypto;';
    end if;

    "sanPswHash" = regexp_replace(coalesce("inStringToHash", ''), '^\s+|\s+$', '');
    if length("sanPswHash") < "minLength" then
        raise exception 'Password should be at least % characters long', "minLength"
            using
                errcode = '22023',
                hint = 'Choose a longer password';
    end if;
    hash := digest("sanPswHash", 'sha512');
    for i in 1..iterations - 1
        loop
            hash := digest(hash, 'sha512');
        end loop;
    "hashB64" := replace(encode(hash, 'base64'), E'\n', '');
    return (iterations || ':' || "hashB64")::varchar;
end;
$$;

alter function pgr_fn."toSimpleHash"(varchar) owner to postgres;

grant execute on function pgr_fn."toSimpleHash"(varchar) to public;

comment on function pgr_fn."toSimpleHash"
    is 'Creates a simple hash';
