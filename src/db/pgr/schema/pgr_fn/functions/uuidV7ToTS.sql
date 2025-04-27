-- pgr_fn.uuidV7ToTS

-- drop function if exists pgr_fn."uuidV7ToTS"(uuid);

create or replace function pgr_fn."uuidV7ToTs"("uuidInput" uuid)
    returns timestamp
    security definer
    language plpgsql
    stable
    parallel safe
as
$$
declare
    "uuidText" varchar = "uuidInput"::text;
    "tsMs"     bigint;
begin
    /**
        Parses UUIDv7 to extract embedded timestamp, returns NULL if not valid UUIDv7.
        @author bpsbits.org
        @package pgReporter
    */

    -- Check that is a valid UUID format and version 7
    if "uuidText" !~ '^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$' then
        return null;
    end if;
    "tsMs" = ('x' || substring("uuidText" from 1 for 8) || substring("uuidText" from 10 for 4))::bit(48)::bigint;
    return to_timestamp("tsMs" / 1000.0);
end;
$$;

alter function pgr_fn."uuidV7ToTs"(uuid) owner to postgres;

grant execute on function pgr_fn."uuidV7ToTs"(uuid) to public;

comment on function pgr_fn."uuidV7ToTs"
    is 'Parses UUIDv7 to extract embedded timestamp, returns NULL if not valid UUIDv7.';
