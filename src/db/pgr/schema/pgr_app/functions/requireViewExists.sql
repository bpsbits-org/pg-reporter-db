-- pgr_app.requireViewExists

-- drop function if exists pgr_app."requireViewExists"(varchar);
-- select pgr_app."requireViewExists"(null);
-- select pgr_app."requireViewExists"('pgr_app."AccountDetails"');

create or replace function pgr_app."requireViewExists"("inViewName" varchar)
    returns jsonb
    security definer
    language plpgsql
    stable
    parallel safe
    cost 25
    leakproof
as
$$
declare
    "viewNameParts" jsonb;
begin
    /**
        Throws an exception if the specified view is missing,
        otherwise returns view name extracted into schema and object parts.
        @author bpsbits.org
        @package pgReporter
    */
    "viewNameParts" = pgr_fn."dbObjToParts"("inViewName");
    if "viewNameParts" is null then
        raise exception
            using
                message = 'Invalid object name',
                errcode = '22023',
                hint = 'Name of view should contain both the schema and name.';
    end if;
    if pgr_app."viewExists"("viewNameParts" ->> 'schema', "viewNameParts" ->> 'object') = false then
        raise exception
            using
                message = 'Requested view does not exist',
                errcode = '42P01',
                hint = 'Requested view should exists in database.';
    end if;
    return "viewNameParts";
end;
$$;

alter function pgr_app."requireViewExists"(varchar) owner to postgres;

grant execute on function pgr_app."requireViewExists"(varchar) to app_pgr_api;

comment on function pgr_app."requireViewExists"
    is 'Ensures that the specified view exists and returns its name extracted into schema and object parts';
