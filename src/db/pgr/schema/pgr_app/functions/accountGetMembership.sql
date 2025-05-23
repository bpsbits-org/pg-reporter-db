-- pgr_app.accountGetMembership

-- drop function if exists pgr_app."accountGetMembership"(uuid);
-- select pgr_app."accountGetMembership"(null);

create or replace function pgr_app."accountGetMembership"("inAccountId" uuid)
    returns uuid[]
    security definer
    parallel safe
    language sql
    stable
    cost 50
as
$$
select
    coalesce(array_agg(agr."accountGroupId"), '{}'::uuid[])
from pgr_app."AccountGroups" agr
where
      "inAccountId" is not null
  and agr."accountGroupMembers" @> array ["inAccountId"];
$$;

alter function pgr_app."accountGetMembership"(uuid) owner to postgres;

grant execute on function pgr_app."accountGetMembership"(uuid) to app_pgr_api;

comment on function pgr_app."accountGetMembership"
    is 'Returns an array of group IDs where the account has membership';
