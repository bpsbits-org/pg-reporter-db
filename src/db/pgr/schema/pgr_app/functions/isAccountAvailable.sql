-- pgr_app.isAccountAvailable

-- drop function if exists pgr_app."isAccountAvailable"(uuid);
-- select pgr_app."isAccountAvailable"(null);

create or replace function pgr_app."isAccountAvailable"("inAccountId" uuid)
    returns boolean
    security definer
    language sql
    stable
    parallel safe
    cost 10
as
$$
    /**
        Checks whether the specified account is available
        @author bpsbits.org
        @package pgReporter
    */
select
    exists(
        --
        select
            1
        from pgr_app."Accounts" acc
        where
              "inAccountId" is not null
          and acc."accountId" = "inAccountId"
          and acc."accountEnabled"
        --
    );
$$;

alter function pgr_app."isAccountAvailable"(uuid) owner to postgres;

grant execute on function pgr_app."isAccountAvailable"(uuid) to app_pgr_api;

comment on function pgr_app."isAccountAvailable"
    is 'Checks whether the specified account is available';
