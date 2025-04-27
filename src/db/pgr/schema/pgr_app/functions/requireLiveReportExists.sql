-- pgr_app.requireLiveReportExists

-- drop function if exists pgr_app."requireLiveReportExists"(uuid);
-- select pgr_app."requireLiveReportExists"(null);

create or replace function pgr_app."requireLiveReportExists"("inLiveReportId" uuid)
    returns boolean
    security definer
    language plpgsql
    stable
    parallel safe
    cost 5
    leakproof
as
$$
    /**
        Throws an exception if the specified Live Report is missing.
        @author bpsbits.org
        @package pgReporter
    */
begin
    if pgr_app."liveReportExists"("inLiveReportId") = false then
        raise exception using
            message = 'Unknown Live Report',
            errcode = '22023',
            hint = 'Please provide a valid Live Report ID.';
    end if;
    return true;
end;
$$;

alter function pgr_app."requireLiveReportExists"(uuid) owner to postgres;

grant execute on function pgr_app."requireLiveReportExists"(uuid) to app_pgr_api;

comment on function pgr_app."requireLiveReportExists"
    is 'Ensures that the specified Live Report exists';
