/**
    Creates schema pgr_fn and alters it to suit specific needs.
    This schema contains all public functions for the pgReport database application.
    These functions do not modify data or expose sensitive information.
 */
create schema if not exists pgr_fn;

comment on schema pgr_fn is 'pgReporter - Public Functions';

alter schema pgr_fn owner to postgres;

-- Grant usage on schema
grant usage on schema pgr_fn to public;

-- Grant execute on all existing functions
grant execute on all functions in schema pgr_fn to public;

-- Grant execute on future functions (alters default privileges)
alter default privileges in schema pgr_fn
    grant execute on functions to public;
