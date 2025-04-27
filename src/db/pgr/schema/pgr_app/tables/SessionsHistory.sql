-- pgr_app.SessionsHistory

-- drop table if exists pgr_app."SessionsHistory";
-- select * from pgr_app."SessionsHistory";

create table pgr_app."SessionsHistory"
(
    "sessionHistoryId" uuid default pgr_fn."genUuidV7"() not null
        constraint "pkSessionsHistory"
            primary key,
    "sessionStorageId" uuid                              not null,
    "sessionData"      jsonb
);

comment on table pgr_app."SessionsHistory"
    is 'Historical records of deleted sessions';

alter table pgr_app."SessionsHistory"
    owner to postgres;
