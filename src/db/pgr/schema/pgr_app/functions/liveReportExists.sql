-- pgr_app.liveReportExists

-- drop function if exists pgr_app."liveReportExists"(uuid);

create or replace function pgr_app."liveReportExists"("inLiveReportId" uuid)
    returns boolean
    security definer
    language sql
    stable
    parallel safe
    cost 1
    leakproof
as
$$
    /**
        Checks whether the specified Live Report exists.
        @author bpsbits.org
        @package pgReporter
    */
select
    exists(
        --
        select
            1
        from pgr_app."LiveReports" lrp
        where
              "inLiveReportId" is not null
          and lrp."lrId" = "inLiveReportId"
        --
    );
$$;

alter function pgr_app."liveReportExists"(uuid) owner to postgres;

grant execute on function pgr_app."liveReportExists"(uuid) to app_pgr_api;

comment on function pgr_app."liveReportExists"
    is 'Checks whether the specified Live Report exists';
