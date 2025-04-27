-- pgr_app.isSuperUser

-- drop function if exists pgr_app."isSuperUser"(uuid);
-- select pgr_app."isSuperUser"(null);

create or replace function pgr_app."isSuperUser"("inAccountId" uuid)
    returns boolean
    security definer
    language sql
    stable
    parallel safe
    cost 20
as
$$
    /**
        Checks whether the specified account is active and possesses superuser privileges.
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
          and acc."accountEnabled"
          and acc."accountId" = "inAccountId"
          and jsonb_typeof(acc."accountPrivileges" -> 'isSuperUser') is not null
          and (acc."accountPrivileges" ->> 'isSuperUser')::boolean
        --
    );
$$;

alter function pgr_app."isSuperUser"(uuid) owner to postgres;

grant execute on function pgr_app."isSuperUser"(uuid) to app_pgr_api;

comment on function pgr_app."isSuperUser"
    is 'Is account active and superuser';
