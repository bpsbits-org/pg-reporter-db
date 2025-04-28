-- pgr_app.requireActiveAccount

-- drop function if exists pgr_app."requireActiveAccount"(uuid);
-- select pgr_app."requireActiveAccount"(null);

create or replace function pgr_app."requireActiveAccount"("inAccountId" uuid)
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
        Throws an exception if the specified account is not active or does not exist.
        @author bpsbits.org
        @package pgReporter
    */
begin
    if pgr_app."accountIsAvailable"("inAccountId") = false then
        raise exception using
            message = 'Account is not active or does not exist',
            errcode = '22023',
            hint = 'Please provide valid and enabled account id.';
    end if;
    return true;
end;
$$;

alter function pgr_app."requireActiveAccount"(uuid) owner to postgres;

grant execute on function pgr_app."requireActiveAccount"(uuid) to app_pgr_api;

comment on function pgr_app."requireActiveAccount"
    is 'Ensures that the specified account is available';
