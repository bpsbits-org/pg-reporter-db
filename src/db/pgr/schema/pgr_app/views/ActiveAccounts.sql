-- pgr_app.ActiveAccounts

-- drop view if exists pgr_app."ActiveAccounts";
-- select * from pgr_app."ActiveAccounts";

create or replace view pgr_app."ActiveAccounts" as
    select
        acc."accountId",
        pgr_fn."uuidV7ToTS"(acc."accountId")::date                as "accountCreatedOn",
        acc."accountLogin",
        coalesce(acc."accountAttributes" ->> 'name', '')::varchar as "accountOwnerName",
        acc."accountAttributes",
        acc."accountPrivileges"
    from pgr_app."Accounts" acc
    where
        acc."accountEnabled"
    order by acc."accountLogin";

alter view pgr_app."ActiveAccounts" owner to postgres;

comment on view pgr_app."ActiveAccounts"
    is 'Active Accounts';
