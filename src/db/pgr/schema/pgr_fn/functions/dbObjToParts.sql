-- pgr_app.dbObjToParts

-- drop function if exists pgr_fn."dbObjToParts"(varchar);

create or replace function pgr_fn."dbObjToParts"("inStringToParse" varchar)
    returns jsonb
    security definer
    language plpgsql
    immutable
    parallel safe
    cost 4
as
$$
declare
    "sanInput"   varchar = trim(replace(coalesce("inStringToParse", ''), '"', ''));
    "nameSchema" varchar;
    "nameObj"    varchar;
begin
    /**
        Parses database object name into schema and object parts.
        @author bpsbits.org
        @package pgReporter
    */

    if "sanInput" = '' then
        return null;
    end if;

    "nameSchema" = nullif(split_part("sanInput", '.', 1), '');
    "nameObj" = nullif(split_part("sanInput", '.', 2), '');

    if "nameSchema" is null or "nameObj" is null then
        return null;
    end if;

    return jsonb_build_object('schema', "nameSchema", 'object', "nameObj");
end;
$$;

alter function pgr_fn."dbObjToParts"(varchar) owner to postgres;

grant execute on function pgr_fn."dbObjToParts"(varchar) to public;

comment on function pgr_fn."dbObjToParts"
    is 'Parses database object name into schema and object parts.';
