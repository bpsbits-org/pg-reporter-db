/**
    Creates schema pgr_app.
    This schema contains all core elements and functions for the pgReport database application.
 */
create schema if not exists pgr_app;

comment on schema pgr_app is 'pgReporter - Application Data and Features';

alter schema pgr_app owner to postgres;
