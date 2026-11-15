-- Let authenticated staff review the submitted membership form without granting
-- direct table access to membership applications or member profiles.
create or replace function public.staff_pending_membership_requests()
returns jsonb language plpgsql security definer set search_path = '' as $$
begin
  if not coalesce(private.is_staff(), false) and not coalesce(private.is_admin(), false) then
    raise exception 'Active staff or admin access required';
  end if;
  return coalesce((select jsonb_agg(q order by q.submitted_at) from (
    select id, full_name, application_type, email, mobile, date_of_birth, age,
      sex, height, height_unit, weight_kg, emergency_contact_data,
      plan, plan_price, start_date, end_date, fitness_goals, health_conditions,
      other_medical_conditions, signature_path, submitted_at
    from public.membership_applications where status = 'pending'
  ) q), '[]'::jsonb);
end;
$$;

revoke all on function public.staff_pending_membership_requests() from public, anon;
grant execute on function public.staff_pending_membership_requests() to authenticated;
