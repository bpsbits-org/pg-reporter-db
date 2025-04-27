-- pgr_app.LiveReportGroups

-- drop table if exists pgr_app."LiveReportGroups";
-- select * from pgr_app."LiveReportGroups";

create table if not exists pgr_app."LiveReportGroups"
(
    "lrGroupId"    uuid        default pgr_fn."genUuidV7"() not null
        constraint "pkLiveReportGroups" primary key,
    "lrGroupTitle" varchar(32) default '32'                 not null
        constraint "uxLiveReportsTitle" unique
        constraint "checkLiveReportsTitle" check (trim("lrGroupTitle") <> '')
);

comment on table pgr_app."LiveReportGroups" is 'Live Report Groups';

alter table pgr_app."LiveReportGroups"
    owner to postgres;
