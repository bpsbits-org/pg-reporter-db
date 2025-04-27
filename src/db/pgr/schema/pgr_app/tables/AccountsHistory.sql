-- pgr_app.AccountsHistory

-- drop table if exists pgr_app."AccountsHistory";
-- select * from pgr_app."AccountsHistory"

create table if not exists pgr_app."AccountsHistory"
(
    "accountHistoryId" uuid default pgr_fn."genUuidV7"() not null
        constraint "pkAccountsHistory"
            primary key,
    "accountId"        uuid                              not null,
    "accountData"      jsonb
);

comment on table pgr_app."AccountsHistory"
    is 'Historical records of account.';

alter table pgr_app."AccountsHistory"
    owner to postgres;
