-- pgr_app.Privileges

-- drop table if exists pgr_app."Privileges";
-- select * from pgr_app."Privileges";

create table if not exists pgr_app."Privileges"
(
    flag        integer       not null
        constraint "pkPrivileges" primary key
        constraint "checkPrivilegesFlag" check (flag > 0 and (flag & (flag - 1)) = 0),
    title       varchar(32)   not null
        constraint "uxPrivilegesTitle" unique
        constraint "checkPrivilegesTitle" check (trim(title) <> ''),
    description varchar(1024) not null
        constraint "checkPrivilegesDescription" check (trim(description) <> '')
);

comment on table pgr_app."Privileges" is 'List of Privileges';

alter table pgr_app."Privileges"
    owner to postgres;
