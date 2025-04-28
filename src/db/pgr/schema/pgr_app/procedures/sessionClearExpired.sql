-- pgr_app.sessionClearExpired

-- drop procedure if exists pgr_app."sessionClearExpired"();
-- call pgr_app."sessionClearExpired"();

create or replace procedure pgr_app."sessionClearExpired"()
    security definer
    language sql
as
$$
    /**
        Erases all expired sessions.
        @author bpsbits.org
        @package pgReporter
    */
delete
from pgr_app."ActiveSessions" acs
where
    acs."sessionExpires" < (current_timestamp at time zone 'UTC');
$$;

alter procedure pgr_app."sessionClearExpired"() owner to postgres;

grant execute on procedure pgr_app."sessionClearExpired"() to app_pgr_api;

comment on procedure pgr_app."sessionClearExpired"
    is 'Erases all expired sessions.';
