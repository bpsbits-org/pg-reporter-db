-- pgr_app.FailedAuthorizations

-- drop table if exists pgr_app."FailedAuthorizations";

create table if not exists pgr_app."FailedAuthorizations"
(
    "failedAuthId" uuid default pgr_fn."genUuidV7"() not null
        constraint "pkFailedAuthorizations"
            primary key,
    "login"        varchar(128),
    "info"         varchar(1024),
    "clientInfo"   jsonb
);

comment on table pgr_app."FailedAuthorizations"
    is 'Failed authorizations log';

alter table pgr_app."FailedAuthorizations"
    owner to postgres;
