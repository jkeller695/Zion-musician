-- =====================================================================
--  Optional starter data. Run AFTER schema.sql.
--  Loads the October 2026 accompanist rotation and the Sept 20 hymns
--  (so the "last sung" hints have history from day one).
-- =====================================================================

insert into public.signups (id, data) values
  ('sun-2026-10-04~accompanist~1', '{"name":"Gary",  "service":"sun-2026-10-04","role":"accompanist","n":1}'),
  ('sun-2026-10-11~accompanist~1', '{"name":"Ethan", "service":"sun-2026-10-11","role":"accompanist","n":1}'),
  ('sun-2026-10-18~accompanist~1', '{"name":"Gary",  "service":"sun-2026-10-18","role":"accompanist","n":1}'),
  ('sun-2026-10-25~accompanist~1', '{"name":"Bell",  "service":"sun-2026-10-25","role":"accompanist","n":1}')
on conflict (id) do nothing;

insert into public.hymns (id, data) values
  ('sun-2026-09-20', '{"items":[
     {"slot":"gathering","book":"ELW","num":"853","title":"When Morning Gilds the Skies","note":""},
     {"slot":"day","book":"ELW","num":"659","title":"Will You Let Me Be Your Servant","note":""},
     {"slot":"comm1","book":"ELW","num":"471","title":"Let Us Break Bread Together","note":""},
     {"slot":"comm2","book":"ELW","num":"484","title":"You Satisfy the Hungry Heart","note":""},
     {"slot":"comm3","book":"ELW","num":"461","title":"All Who Hunger, Gather Gladly","note":""},
     {"slot":"sending","book":"ELW","num":"765","title":"Lord of All Hopefulness","note":""}]}')
on conflict (id) do nothing;
