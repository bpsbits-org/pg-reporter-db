-- pgr_app.viewExists

-- drop function if exists pgr_app."viewExists"(varchar, varchar);
-- select pgr_app."viewExists"(null, null);
-- select pgr_app."viewExists"('pgr_app', 'AccountDetails');

create or replace function pgr_app."viewExists"("inSchema" varchar, "inView" varchar)
    returns boolean
    security definer
    language sql
    stable
    cost 10
as
$$
    /**
        Checks whether the specified view exists.
        Mainly used for validating that data object for Live Reports exists.
        @author bpsbits.org
        @package pgReporter
    */
select
    exists(select
               1
           from information_schema.views
           where
                 table_schema = "inSchema"
             and table_name = "inView");
$$;

alter function pgr_app."viewExists"(varchar, varchar) owner to postgres;

grant execute on function pgr_app."viewExists"(varchar, varchar) to app_pgr_api;

comment on function pgr_app."viewExists"
    is 'Checks whether the specified view exists';
