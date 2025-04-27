-- pgr_app.ActiveSessions

-- drop table if exists pgr_app."ActiveSessions";
-- select * from pgr_app."ActiveSessions";

create table if not exists pgr_app."ActiveSessions"
(
    "sessionStorageId"  uuid                     default pgr_fn."genUuidV7"()                           not null
        constraint "pkActiveSessions" primary key,
    "sessionHash"       uuid                     default pgr_fn."genUuidV7"()                           not null
        constraint "uxActiveSessionHash" unique,
    "sessionOwner"      uuid                     default pgr_fn."genUuidV7"()                           not null,
    "sessionAttributes" jsonb                    default '{}'::jsonb                                    not null
        constraint "checkSessionAttributesIsObject" check (jsonb_typeof("sessionAttributes") = 'object'),
    "sessionExpires"    timestamp with time zone default (now() at time zone 'UTC' + interval '1 week') not null
);

alter table pgr_app."ActiveSessions"
    owner to postgres;

comment on table pgr_app."ActiveSessions" is 'Active Sessions';

-- Create after delete trigger function
create or replace function pgr_app."trgActiveSessionsOnAfterDelete"()
    returns trigger
    language plpgsql
    security definer
    volatile
    cost 100
as
$$
begin
    insert into pgr_app."SessionsHistory" ("sessionStorageId", "sessionData")
    values (old."sessionStorageId", to_jsonb(old));
    return old;
end;
$$;

alter function pgr_app."trgActiveSessionsOnAfterDelete"() owner to postgres;

comment on function pgr_app."trgActiveSessionsOnAfterDelete"
    is 'Archives deleted sessions to SessionsHistory.';

-- Create after delete trigger
create or replace trigger "onAfterDelete"
    after delete
    on pgr_app."ActiveSessions"
    for each row
execute function pgr_app."trgActiveSessionsOnAfterDelete"();

comment on trigger "onAfterDelete" on pgr_app."ActiveSessions"
    is 'Archives deleted sessions to SessionsHistory';
