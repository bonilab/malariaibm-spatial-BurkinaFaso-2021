
-- This query returns the data that is used to generate the Matlab plots
select dayselapsed,
  district,
  sum(population) as popuation,
  avg(msd.eir) as eir,
  sum(population * pfprunder5) / sum(population) as pfprunder5,
  sum(population * pfpr2to10) / sum(population) as pfpr2to10,
  sum(population * pfprall) / sum(population) as pfprall
from sim.replicate r
  inner join sim.configuration c on c.id = r.configurationid
  inner join sim.monthlydata md on md.replicateid = r.id
  inner join sim.monthlysitedata msd on msd.monthlydataid = md.id
  inner join sim.location l on l.id = msd.locationid
where r.id = 96054 and eir != 0
group by dayselapsed, district

-- Weighted average for bounded model calibration
select cast(substr(filename, 9, 4) as float) scaling,
  dayselapsed,
  district,
  avg(msd.eir) as eir,
  sum(population * pfprunder5) / sum(population) as pfprunder5,
  sum(population * pfpr2to10) / sum(population) as pfpr2to10,
  sum(population * pfprall) / sum(population) as pfprall
from sim.replicate r
  inner join sim.configuration c on c.id = r.configurationid
  inner join sim.monthlydata md on md.replicateid = r.id
  inner join sim.monthlysitedata msd on msd.monthlydataid = md.id
  inner join sim.location l on l.id = msd.locationid
where c.studyid = 7 and eir != 0
  and filename like '%-bfa-2.yml'
group by filename, district, dayselapsed

-- Select all data for each site
select dayselapsed,
  district, x, y,
  msd.population, msd.treatments, msd.treatmentfailures,
  msd.eir, msd.pfprunder5, msd.pfpr2to10, msd.pfprall
from sim.replicate r
  inner join sim.monthlydata md on md.replicateid = r.id
  inner join sim.monthlysitedata msd on msd.monthlydataid = md.id
  inner join sim.location l on l.id = msd.locationid
where r.id = 35877 and eir != 0

-- PfPR 2 to 10 for a single year (2025) for the country
select dayselapsed,
  district, l.x, l.y,
  sum(population * pfpr2to10) / sum(population) as pfpr2to10
--  avg(pfpr2to10) as pfpr2to10
from sim.configuration c
  inner join sim.replicate r on r.configurationid = c.id
  inner join sim.monthlydata md on md.replicateid = r.id
  inner join sim.monthlysitedata msd on msd.monthlydataid = md.id
  inner join sim.location l on l.id = msd.locationid
where c.id = 59798
  and md.dayselapsed between 8401 and 8766
group by dayselapsed, district, l.x, l.y

-- Days elapsed to dates for a replicate
select md.dayselapsed,
  to_date('2007-01-01', 'yyyy-mm-dd') + interval '1' day * md.dayselapsed as date
from sim.replicate r
  inner join sim.monthlydata md on md.replicateid = r.id
where r.id = 62554