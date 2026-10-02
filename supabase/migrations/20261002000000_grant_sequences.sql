grant usage, select on all sequences in schema public to anon, authenticated;

alter default privileges in schema public
  grant usage, select on sequences to anon, authenticated;