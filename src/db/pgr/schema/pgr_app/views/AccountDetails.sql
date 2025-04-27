-- pgr_app.AccountDetails

-- drop view if exists pgr_app."AccountDetails";
-- select * from pgr_app."AccountDetails";

create or replace view pgr_app."AccountDetails" as
    select
        acc."accountId",
        pgr_fn."uuidV7ToTS"(acc."accountId")::date                 as "accountCreatedOn",
        acc."accountLogin",
        coalesce(acc."accountAttributes" ->> 'name', '')::varchar  as "accountOwnerName",
        coalesce(acc."accountAttributes" ->> 'email', '')::varchar as "accountOwnerEmail",
        coalesce(acc."accountAttributes" ->> 'phone', '')::varchar as "accountOwnerPhone",
        acc."accountAttributes",
        acc."accountPrivileges"
    from pgr_app."Accounts" acc
    order by acc."accountLogin";

alter view pgr_app."AccountDetails" owner to postgres;

comment on view pgr_app."AccountDetails"
    is 'Account Details';
