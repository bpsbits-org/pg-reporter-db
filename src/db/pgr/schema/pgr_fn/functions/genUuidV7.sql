-- pgr_fn."genUuidV7"

-- drop function if exists pgr_fn."genUuidV7"();

create or replace function pgr_fn."genUuidV7"()
    returns uuid
    security definer
    parallel safe
    language sql
    cost 2
as
$$
    /**
        Generates a UUID according to the UUID version 7 specification (RFC 9562).
        @author bpsbits.org
        @package pgReporter
    */
select
    encode(
            decode(lpad(to_hex(floor(t_ms)::bigint), 12, '0'), 'hex') ||
            int2send((7 << 12)::int2 | ((t_ms - floor(t_ms)) * 4096)::int2) ||
            substring(uuid_send(gen_random_uuid()) from 9 for 8)
        , 'hex')::uuid
from (select extract(epoch from clock_timestamp()) * 1000 as t_ms) s

$$;

alter function pgr_fn."genUuidV7"() owner to postgres;

grant execute on function pgr_fn."genUuidV7"() to public;

comment on function pgr_fn."genUuidV7"
    is 'Generates a UUID according to the UUID version 7 specification (RFC 9562)';
