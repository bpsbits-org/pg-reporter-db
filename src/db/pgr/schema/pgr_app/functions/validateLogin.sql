-- pgr_app.validateLogin

-- drop function if exists pgr_app."validateLogin"(varchar, varchar);
-- select pgr_app."validateLogin"(null, null);

create or replace function pgr_app."validateLogin"("inLogin" varchar, "inPswHash" varchar)
    returns uuid
    security definer
    language sql
    stable
    strict
    parallel safe
    leakproof
    cost 20
as
$$
    /**
        Validates login credentials and returns account ID if valid, NULL otherwise.
        @author bpsbits.org
        @package pgReporter
    */
select
    acc."accountId"
from pgr_app."Accounts" acc
where
      acc."accountEnabled"
  and acc."accountLogin" = "inLogin"
  and acc."accountLoginHash" = "inPswHash";
$$;

alter function pgr_app."validateLogin"(varchar, varchar) owner to postgres;

grant execute on function pgr_app."validateLogin"(varchar, varchar) to app_pgr_api;

comment on function pgr_app."validateLogin"
    is 'Validates login credentials and returns account ID if valid';
