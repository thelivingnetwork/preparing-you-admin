-- Restore admin access to member emails after the 2026-07-09 column-grant
-- lockdown (member emails not obtainable via the API by other members).
--
-- The admin app queries Supabase as the `authenticated` role, so the table
-- SELECT revoke hit admins too ("permission denied for table prep_users").
-- Column privileges are per-role and cannot distinguish admins from members,
-- so admin reads move to SECURITY DEFINER views: owned by postgres (bypasses
-- the column grants + RLS), returning rows ONLY when the caller is a
-- registered admin. Non-admins get zero rows — never an email.
--
-- Apply in the Preparing You project (qvcfgcwecykilbddgqzv) SQL editor.
-- Pairs with the admin-app deploy that reads prep_users_admin/prep_pcms_admin.

begin;

create or replace view public.prep_users_admin as
  select u.*
  from public.prep_users u
  where exists (select 1 from public.prep_admins a where a.user_id = auth.uid());

create or replace view public.prep_pcms_admin as
  select p.*
  from public.prep_pcms p
  where exists (select 1 from public.prep_admins a where a.user_id = auth.uid());

alter view public.prep_users_admin owner to postgres;
alter view public.prep_pcms_admin  owner to postgres;

revoke all on public.prep_users_admin, public.prep_pcms_admin from anon, authenticated;
grant select on public.prep_users_admin to authenticated;
grant select on public.prep_pcms_admin  to authenticated;

commit;
