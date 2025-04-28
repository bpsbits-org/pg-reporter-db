-- pgr_fn.jsonbStripEmpty

-- drop function if exists pgr_fn."jsonbStripEmpty"(jsonb);

-- select pgr_fn."jsonbStripEmpty"(null);
-- select pgr_fn."jsonbStripEmpty"('[]'::jsonb);
-- select pgr_fn."jsonbStripEmpty"('"Some text"'::jsonb);
-- select pgr_fn."jsonbStripEmpty"('""'::jsonb);
-- select pgr_fn."jsonbStripEmpty"('true'::jsonb);
-- select pgr_fn."jsonbStripEmpty"('123'::jsonb);
-- select pgr_fn."jsonbStripEmpty"('{}'::jsonb);
-- select pgr_fn."jsonbStripEmpty"('{"x":null,"y":{"x":[]}}'::jsonb);

create or replace function pgr_fn."jsonbStripEmpty"("inJsonData" jsonb)
    returns jsonb
    security definer
    language plpgsql
    immutable
    strict
    parallel safe
    cost 100
as
$$
declare
    "jsonInput" jsonb := jsonb_strip_nulls("inJsonData");
    "result"    jsonb = '{}';
    "key"       text;
    "value"     jsonb;
begin
    /**
        Strips null values, empty objects, and empty arrays from JSONB data.
        @author bpsbits.org
        @package pgReporter
    */

    -- Strip nulls
    "jsonInput" = jsonb_strip_nulls("jsonInput");

    -- Handle arrays
    if jsonb_typeof("jsonInput") = 'array' then
        "result" = '[]'::jsonb;
        for "value" in select jsonb_array_elements("jsonInput")
            loop
                "value" = pgr_fn."jsonbStripEmpty"("value");
                if "value" is not null and "value" != '{}'::jsonb and "value" != '[]'::jsonb then
                    "result" = "result" || "value";
                end if;
            end loop;
        return case when jsonb_array_length("result") = 0 then null else "result" end;
    end if;

    -- Handle objects
    if jsonb_typeof("jsonInput") = 'object' then
        for "key", "value" in select k, v from jsonb_each("jsonInput") as t(k, v)
            loop
                "value" = pgr_fn."jsonbStripEmpty"("value");
                if "value" is not null and "value" != '{}'::jsonb and "value" != '[]'::jsonb then
                    "result" = "result" || jsonb_build_object("key", "value");
                end if;
            end loop;
        return case when "result" = '{}'::jsonb then null else "result" end;
    end if;

    -- Return result
    return "jsonInput";
end;
$$;

alter function pgr_fn."jsonbStripEmpty"(jsonb) owner to postgres;

grant execute on function pgr_fn."jsonbStripEmpty"(jsonb) to public;

comment on function pgr_fn."jsonbStripEmpty"
    is 'Strips null values, empty objects, and empty arrays from JSONB data.';
