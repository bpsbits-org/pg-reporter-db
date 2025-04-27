-- pgr_app.AccountMemberships

-- drop view if exists pgr_app."AccountMemberships";
-- select * from pgr_app."AccountMemberships";

create or replace view pgr_app."AccountMemberships" as
    select
        acc."accountId",
        pgr_fn."uuidV7ToTS"(acc."accountId")::date                as "accountCreatedOn",
        acc."accountLogin",
        coalesce(acc."accountAttributes" ->> 'name', '')::varchar as "accountOwnerName",
        agr."accountGroupId",
        pgr_fn."uuidV7ToTS"(agr."accountGroupId")::date           as "groupCreatedOn",
        agr."accountGroupTitle"
    from pgr_app."Accounts" acc
             left join pgr_app."AccountGroups" agr
                       on acc."accountId" = any (agr."accountGroupMembers")
    order by agr."accountGroupTitle";

alter view pgr_app."AccountMemberships" owner to postgres;

comment on view pgr_app."AccountMemberships"
    is 'Account Memberships';
