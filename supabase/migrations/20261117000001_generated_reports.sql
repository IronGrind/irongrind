create table if not exists public.generated_reports (
  id bigint generated always as identity primary key,
  report_type text not null,
  period_label text not null,
  period_start date,
  period_end date,
  filters jsonb not null default '{}'::jsonb,
  output_format text not null check (output_format in ('preview','print','pdf','zip')),
  record_count integer not null default 0 check (record_count >= 0),
  report_data jsonb not null default '[]'::jsonb,
  generated_by uuid not null references public.profiles(id),
  generated_at timestamptz not null default now()
);

create index if not exists generated_reports_generated_at_idx
  on public.generated_reports (generated_at desc, id desc);
create index if not exists generated_reports_type_period_idx
  on public.generated_reports (report_type, period_start, period_end);

alter table public.generated_reports enable row level security;

create policy generated_reports_admin_read
  on public.generated_reports for select to authenticated
  using ((select private.is_admin()));

grant select on public.generated_reports to authenticated;
revoke insert, update, delete, truncate, references, trigger on public.generated_reports from authenticated, anon;

create or replace function public.record_generated_report(
  p_report_type text,
  p_period_label text,
  p_period_start date,
  p_period_end date,
  p_filters jsonb,
  p_output_format text,
  p_record_count integer,
  p_report_data jsonb
) returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
  report_id bigint;
  actor_name text;
begin
  if not (select private.is_admin()) then
    raise exception 'Administrator access required';
  end if;
  if p_output_format not in ('preview','print','pdf','zip') then
    raise exception 'Unsupported report output format';
  end if;

  insert into public.generated_reports (
    report_type, period_label, period_start, period_end, filters,
    output_format, record_count, report_data, generated_by
  ) values (
    left(btrim(p_report_type), 100), left(btrim(p_period_label), 150),
    p_period_start, p_period_end, coalesce(p_filters, '{}'::jsonb),
    p_output_format, greatest(coalesce(p_record_count, 0), 0),
    coalesce(p_report_data, '[]'::jsonb), auth.uid()
  ) returning id into report_id;

  select full_name into actor_name from public.profiles where id = auth.uid();
  insert into public.activity_logs (
    actor_id, actor_name, actor_role, action, entity_type, entity_id, record_label, details
  ) values (
    auth.uid(), coalesce(actor_name, 'Administrator'), 'admin', 'report_generated',
    'generated_report', report_id::text, left(btrim(p_report_type), 100),
    format('%s report for %s; %s record(s)', p_output_format, p_period_label, greatest(coalesce(p_record_count, 0), 0))
  );

  return report_id;
end;
$$;

revoke all on function public.record_generated_report(text,text,date,date,jsonb,text,integer,jsonb) from public, anon;
grant execute on function public.record_generated_report(text,text,date,date,jsonb,text,integer,jsonb) to authenticated;
