-- pgr_app.ActiveSessions

-- drop table if exists pgr_app."Accounts";
-- select * from pgr_app."Accounts";

create table if not exists pgr_app."Accounts"
(
    "accountId"         uuid         default pgr_fn."genUuidV7"()                                 not null
        constraint "pkAccounts" primary key,
    "accountLogin"      varchar(128) default pgr_fn."genUuidV7"()::varchar                        not null
        constraint "uxAccountLogin" unique
        constraint "chkAccountLoginMinLength" check (length(trim("accountLogin")) >= 8),
    "accountLoginHash"  varchar(512) default pgr_fn."toSimpleHash"(pgr_fn."genUuidV7"()::varchar) not null,
    "accountAttributes" jsonb        default '{}'::jsonb                                          not null
        constraint "checkAccountAttributesIsObject" check (jsonb_typeof("accountAttributes") = 'object'),
    "accountPrivileges" jsonb        default '{}'::jsonb                                          not null
        constraint "checkAccountPrivilegesIsObject" check (jsonb_typeof("accountAttributes") = 'object'),
    "accountEnabled"    boolean      default true                                                 not null
);

alter table pgr_app."Accounts"
    owner to postgres;

comment on table pgr_app."Accounts"
    is 'pgReporter Accounts';

-- Create before delete trigger function
create or replace function pgr_app."trgAccountsOnBeforeDelete"()
    returns trigger
    language plpgsql
    security definer
    immutable
    cost 1
as
$$
begin
    raise exception 'Deleting accounts is not allowed. Use accountEnabled flag to disable accounts instead.'
        using hint = 'Update accountEnabled to FALSE to disable the account',
            errcode = 'P0001';
end;
$$;

comment on function pgr_app."trgAccountsOnAfterUpdate"
    is 'Prevents account deletion';

-- Create trigger
create trigger "onBeforeDelete"
    before delete
    on pgr_app."Accounts"
    for each row
execute function pgr_app."trgAccountsOnBeforeDelete"();

comment on trigger "onBeforeDelete" on pgr_app."Accounts"
    is 'Prevents account deletion - accounts should be disabled instead of deleted';

-- Create after update trigger function
create or replace function pgr_app."trgAccountsOnAfterUpdate"()
    returns trigger
    language plpgsql
    security definer
    volatile
    parallel unsafe
    cost 150
as
$$
begin
    insert into pgr_app."AccountsHistory" ("accountId", "accountData")
    values (old."accountId", to_jsonb(old));
    return old;
end;
$$;

comment on function pgr_app."trgAccountsOnAfterUpdate"
    is 'Archives previous account state data after update';

-- Create trigger
create or replace trigger "onAfterUpdate"
    after update
    on pgr_app."Accounts"
    for each row
execute function pgr_app."trgAccountsOnAfterUpdate"();

comment on trigger "onAfterUpdate" on pgr_app."Accounts"
    is 'Archives old state of account';
