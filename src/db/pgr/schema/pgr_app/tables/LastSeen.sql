-- pgr_app.LastSeen

-- drop table if exists pgr_app."LastSeen";

create table if not exists pgr_app."LastSeen"
(
    "lastSeenId"         uuid default pgr_fn."genUuidV7"() not null
        constraint "pkLastSeen"
            primary key,
    "sessionStorageId"   uuid                              not null,
    "lastSeenAttributes" jsonb,
    "clientInfo"         jsonb
);

comment on table pgr_app."LastSeen" is 'Last seen log';

alter table pgr_app."LastSeen"
    owner to postgres;
