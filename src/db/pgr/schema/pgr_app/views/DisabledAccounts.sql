-- pgr_app.DisabledAccounts

-- drop view if exists pgr_app."DisabledAccounts";
-- select * from pgr_app."DisabledAccounts";

create or replace view pgr_app."DisabledAccounts" as
    select
        acc."accountId",
        pgr_fn."uuidV7ToTS"(acc."accountId")::date                as "accountCreatedOn",
        acc."accountLogin",
        coalesce(acc."accountAttributes" ->> 'name', '')::varchar as "accountOwnerName",
        acc."accountAttributes",
        acc."accountPrivileges"
    from pgr_app."Accounts" acc
    where
        acc."accountEnabled" = false
    order by acc."accountLogin";

alter view pgr_app."DisabledAccounts" owner to postgres;

comment on view pgr_app."DisabledAccounts"
    is 'Active Accounts';
