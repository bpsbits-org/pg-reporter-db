-- pgr_app.AccountGroups

-- drop table if exists pgr_app."AccountGroups";
-- select * from pgr_app."AccountGroups";

create table pgr_app."AccountGroups"
(
    "accountGroupId"      uuid        default pgr_fn."genUuidV7"() not null
        constraint "pkAccountGroups" primary key,
    "accountGroupTitle"   varchar(32) default '32'                 not null
        constraint "uxAccountGroupTitle" unique
        constraint "checkAccountGroupTitle" check (trim("accountGroupTitle") <> ''),
    "accountAttributes"   jsonb       default '{}'::jsonb          not null
        constraint "checkAccountGroupAttributesIsObject" check (jsonb_typeof("accountAttributes") = 'object'),
    "accountGroupMembers" uuid[]      default array []::uuid[]     not null
);

comment on table pgr_app."AccountGroups" is 'Account Groups';

alter table pgr_app."AccountGroups"
    owner to postgres;
