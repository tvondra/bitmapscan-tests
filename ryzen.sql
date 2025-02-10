create table ryzen_results (
  device text,
  build text,
  rows int,
  dataset text,
  relpages int,
  workers int,
  wm int,
  eic int,
  nmatches int,
  ndistinct int,
  run int,
  caching text,
  optimal text,
  timing float
);

copy ryzen_results from '/tmp/ryzen.csv' with (format csv, delimiter ' ', header);

create table ryzen_aggregated as
  select device, build, rows, dataset, relpages, workers, wm, eic, nmatches, ndistinct, caching, optimal, avg(timing) AS timing, count(*) AS cnt
  from ryzen_results group by device, build, rows, dataset, relpages, workers, wm, eic, nmatches, ndistinct, caching, optimal;

create table ryzen_comparison as
  select m.device, m.rows, m.dataset, m.relpages, m.workers, m.wm, m.eic, m.nmatches, m.ndistinct, m.caching, m.optimal,
         m.cnt AS cnt_master, m.timing AS timing_master,
         p1.cnt AS cnt_p1, p1.timing AS timing_p1,
         p2.cnt AS cnt_p2, p2.timing AS timing_p2,
         p3.cnt AS cnt_p3, p3.timing AS timing_p3,
         p4.cnt AS cnt_p4, p4.timing AS timing_p4
  from ryzen_aggregated m
    join ryzen_aggregated p1 using (device, rows, dataset, relpages, workers, wm, eic, nmatches, ndistinct, caching, optimal)
    join ryzen_aggregated p2 using (device, rows, dataset, relpages, workers, wm, eic, nmatches, ndistinct, caching, optimal)
    join ryzen_aggregated p3 using (device, rows, dataset, relpages, workers, wm, eic, nmatches, ndistinct, caching, optimal)
    join ryzen_aggregated p4 using (device, rows, dataset, relpages, workers, wm, eic, nmatches, ndistinct, caching, optimal)
  where m.build = 'master'
    and p1.build = 'patched-0001'
    and p2.build = 'patched-0002'
    and p3.build = 'patched-0003'
    and p4.build = 'patched-0004';


select * from ryzen_comparison order by (timing_p3 / timing_master) desc;

select * from ryzen_comparison order by (timing_p3 - timing_master) desc;
