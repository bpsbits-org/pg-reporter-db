-- pgr_app.LiveReports

-- drop table if exists pgr_app."LiveReports";
-- select * from pgr_app."LiveReports";

create table if not exists pgr_app."LiveReports"
(
    "lrId"                 uuid   default pgr_fn."genUuidV7"() not null
        constraint "pkLiveReports" primary key,
    "lrReportView"         varchar(128)                        not null
        constraint "uxLiveReportView" unique
        constraint "checkLiveReportView" check (trim("lrReportView") <> ''),
    "lrGroupId"            uuid                                not null
        constraint "fkLiveReportGroups" references pgr_app."LiveReportGroups" ("lrGroupId"),
    "lrTitle"              varchar(32)                         not null
        constraint "checkLiveReportsTitle" check (trim("lrTitle") <> ''),
    "lrDescription"        varchar(1024)                       not null
        constraint "checkLiveReportsDescription" check (trim("lrDescription") <> ''),
    "lrAttributes"         jsonb  default '{}'::jsonb          not null
        constraint "checkLrAttributesIsObject" check (jsonb_typeof("lrAttributes") = 'object'),
    "lrGridAttributes"     jsonb  default '{}'::jsonb          not null
        constraint "checkLrGridAttributesIsObject" check (jsonb_typeof("lrGridAttributes") = 'object'),
    "lrGridColumns"        jsonb  default '[]'::jsonb          not null
        constraint "checkLrGridColumnsIsArray" check (jsonb_typeof("lrGridColumns") = 'array'),
    "lrAccountLevelAccess" uuid[] default array []::uuid[]     not null,
    "lrGroupLevelAccess"   uuid[] default array []::uuid[]     not null
);

comment on table pgr_app."LiveReports" is 'Live Reports';

alter table pgr_app."LiveReports"
    owner to postgres;
