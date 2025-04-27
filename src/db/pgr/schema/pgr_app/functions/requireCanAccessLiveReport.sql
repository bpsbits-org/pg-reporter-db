-- pgr_app.requireCanAccessLiveReport

-- drop function if exists pgr_app."requireCanAccessLiveReport"(uuid, uuid);

create or replace function pgr_app."requireCanAccessLiveReport"("inAccountId" uuid, "inLiveReportId" uuid)
    returns boolean
    security definer
    language plpgsql
    stable
    parallel safe
    cost 15
    leakproof
as
$$
    /**
        Throws an exception if the specified account is not allowed to access the given Live Report.
        @author bpsbits.org
        @package pgReporter
    */
begin
    if pgr_app."canAccessLiveReport"("inAccountId", "inLiveReportId") = false then
        raise exception using
            message = 'Not permitted',
            errcode = '42501',
            hint = 'Insufficient privileges to access given Live Report.';
    end if;
    return true;
end;
$$;

alter function pgr_app."requireCanAccessLiveReport"(uuid, uuid) owner to postgres;

grant execute on function pgr_app."requireCanAccessLiveReport"(uuid, uuid) to app_pgr_api;

comment on function pgr_app."requireCanAccessLiveReport"
    is 'Ensures that the specified account is allowed to access given Live Report';
