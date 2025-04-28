-- pgr_app.canAccessLiveReport

-- drop function if exists pgr_app."createAccount"(uuid, uuid);
-- select pgr_app."canAccessLiveReport"(null, null);

create or replace function pgr_app."canAccessLiveReport"("inAccountId" uuid, "inLiveReportId" uuid)
    returns boolean
    security definer
    language plpgsql
    stable
    parallel safe
    cost 150
    leakproof
as
$$
declare
    "isSuperUser"       boolean := false;
    "accountMembership" uuid[];
begin
    /**
        Checks if a given account has permission to access the specified Live Report
        through group membership, direct access, or superuser privileges
        @author bpsbits.org
        @package pgReporter
    */

    if pgr_app."accountIsAvailable"("inAccountId") = false or
       pgr_app."liveReportExists"("inLiveReportId") = false
    then
        return false;
    end if;

    "isSuperUser" = pgr_app."isSuperUser"("inAccountId");
    "accountMembership" = pgr_app."accountGetMembership"("inAccountId");

    return exists(
        --
        select
            1
        from pgr_app."LiveReports" lrp
        where
              lrp."lrId" = "inLiveReportId"
          and (
                  (cardinality("accountMembership") > 0 and lrp."lrGroupLevelAccess" @> "accountMembership") or
                  (lrp."lrAccountLevelAccess" @> "accountMembership") or
                  (cardinality(lrp."lrGroupLevelAccess") = 0 and cardinality("accountMembership") = 0 and
                   lrp."lrAccountLevelAccess" @> "accountMembership") or "isSuperUser"
                  )
        --
    );
end;
$$;

alter function pgr_app."canAccessLiveReport"(uuid, uuid) owner to postgres;

grant execute on function pgr_app."canAccessLiveReport"(uuid, uuid) to app_pgr_api;

comment on function pgr_app."canAccessLiveReport"
    is 'Checks that account is allowed to access Live Report';
