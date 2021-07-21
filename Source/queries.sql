-- Clinical case data for calibration range
SELECT district,
	max(population) AS population,
	sum(cases) AS cases,
	round(sum(treatedcases) * 0.832, 0) AS reportedcases,
	round((sum(treatedcases) * 0.832) / (max(population) / 1000), 0) AS clinicalper1000,
	round(cast(sum(pfpr2to10 * population) / sum(population) as numeric), 2) AS pfpr2to10,
	round(sum(cases) / max(population), 2) as incidence_acd
FROM (
	SELECT md.dayselapsed, l.district,
		sum(msd.population) AS population,
		sum(msd.clinicalepisodes) AS cases,
		sum(msd.treatments) AS treatedcases,
		sum(msd.pfpr2to10 * msd.population) / sum(msd.population) AS pfpr2to10
	FROM sim.configuration c
		INNER JOIN sim.replicate r ON r.configurationid = c.id
		INNER JOIN sim.monthlydata md ON md.replicateid = r.id
		INNER JOIN sim.monthlysitedata msd ON msd.monthlydataid = md.id
		INNER JOIN sim.location l on l.id = msd.locationid
	WHERE r.id = 123701
	AND md.dayselapsed BETWEEN (16 * 365) AND (17 * 365)
	GROUP BY md.dayselapsed, l.district) iq
GROUP BY district
ORDER BY district

-- Orginal betas query for calibration
SELECT replicateid,
  zone, population, access, beta,
  eir, 
  CASE WHEN zone IN (0, 1) THEN max ELSE pfpr2to10 END AS pfpr,
  min, pfpr2to10, max
FROM (
  SELECT replicateid,
    filename,
    cast((regexp_matches(filename, '^(\d*)-(\d*)-([\.\d]*)-([\.\d]*)'))[1] as integer) AS zone,
    cast((regexp_matches(filename, '^(\d*)-(\d*)-([\.\d]*)-([\.\d]*)'))[2] as integer) AS population,
    cast((regexp_matches(filename, '^(\d*)-(\d*)-([\.\d]*)-([\.\d]*)'))[3] as float) AS access,
    cast((regexp_matches(filename, '^(\d*)-(\d*)-([\.\d]*)-([\.\d]*)'))[4] as float) AS beta,
    avg(eir) AS eir, 
    min(pfpr2to10) AS min, 
    avg(pfpr2to10) AS pfpr2to10, 
    max(pfpr2to10) AS max
  FROM sim.configuration c
    INNER JOIN sim.replicate r on r.configurationid = c.id
    INNER JOIN sim.monthlydata md on md.replicateid = r.id
    INNER JOIN sim.monthlysitedata msd on msd.monthlydataid = md.id
  WHERE studyid = 1
    AND md.dayselapsed >= (4352 - 366)
  GROUP BY replicateid, filename) iq
WHERE (beta = 0 and pfpr2to10 = 0) OR (beta != 0 and min != 0)       
ORDER BY zone, population, access, pfpr

-- Basic monitoring query
select filename, replicateid, 
  starttime, now() - starttime as runningtime, 
  max(dayselapsed) as modeldays
from sim.replicate r
  inner join sim.configuration c on c.id = r.configurationid
  inner join sim.monthlydata md on md.replicateid = r.id
where r.endtime is null
group by filename, replicateid, starttime
order by modeldays desc

-- Count of running replicates
select c.studyid, c.filename, count(r.id) as replicates,
  sum(case when r.endtime is null then 1 else 0 end) as running,
  sum(case when r.endtime is not null then 1 else 0 end) as complete
from sim.configuration c
  inner join sim.replicate r on r.configurationid = c.id
where c.studyid > 2
group by c.studyid, c.filename

-- Treatment failures / work in progress
select c.id,
  r.id,
  md.dayselapsed,
  md.treatmentfailures
from sim.configuration c
  inner join sim.replicate r on r.configurationid = c.id
  inner join sim.monthlydata md on md.replicateid = r.id
where (c.studyid = 3 or c.studyid >4)
  and r.endtime is not null  
  and md.dayselapsed >= 4748
order by c.id, r.id, dayselapsed

select distinct c.id, filename , c.studyid
from sim.configuration c 
  inner join sim.replicate r on r.configurationid = c.id
where (c.studyid = 3 or c.studyid >4)
  and r.endtime is not null
order by c.studyid

-- Plasmepsin double copy frequency
select gd.district, gd.dayselapsed, gd.occurances / ld.infectedindividuals as frequency
from (
  select l.district, md.dayselapsed, sum(mgd.weightedoccurrences) as occurances
  from sim.replicate r
    inner join sim.monthlydata md on md.replicateid = r.id 
    inner join sim.monthlygenomedata mgd on mgd.monthlydataid = md.id
    inner join sim.location l on l.id = mgd.locationid
    inner join sim.genotype g on g.id = mgd.genomeid
  where r.id = 111390
    and g.name ~ '^......2.'
  group by l.district, md.dayselapsed) gd
inner join (
  select l.district, md.dayselapsed, sum(msd.infectedindividuals) as infectedindividuals
  from sim.replicate r
    inner join sim.monthlydata md on md.replicateid = r.id 
    inner join sim.monthlysitedata msd on msd.monthlydataid = md.id
    inner join sim.location l on l.id = msd.locationid
  where r.id = 111390
  group by l.district, md.dayselapsed) ld on gd.district = ld.district and gd.dayselapsed = ld.dayselapsed

-- Genotype Frequency query / work in progress
SELECT replicateid, dayselapsed, year, substring(g.name, 1, 7) as name, frequency
FROM (
	SELECT mgd.replicateid, mgd.genomeid, mgd.dayselapsed, 
		TO_CHAR(TO_DATE('2007-01-01', 'YYYY-MM-DD') + interval '1' day * mgd.dayselapsed, 'YYYY') AS year,
		mgd.weightedoccurrences / msd.infectedindividuals AS frequency
	FROM (
		SELECT md.replicateid, md.id, md.dayselapsed, mgd.genomeid, sum(mgd.weightedoccurrences) AS weightedoccurrences
		FROM sim.monthlydata md INNER JOIN sim.monthlygenomedata mgd ON mgd.monthlydataid = md.id
		WHERE md.replicateid = 110962 AND md.dayselapsed > 4015
		GROUP BY md.id, md.dayselapsed, mgd.genomeid) mgd
	INNER JOIN (
		SELECT md.id, sum(msd.infectedindividuals) AS infectedindividuals
		FROM sim.monthlydata md INNER JOIN sim.monthlysitedata msd ON msd.monthlydataid = md.id
		WHERE md.replicateid = 110962 AND md.dayselapsed > 4015
		GROUP BY md.id) msd 
	ON msd.id = mgd.id) frequency inner join sim.genotype g on g.id = frequency.genomeid

-- October peaks
select dayselapsed, 
  cast(to_date('2007-1-1', 'yyyy-mm-dd') + dayselapsed*INTERVAL'1 day' as varchar) date,
  ROUND(cast(sum(population * pfpr2to10) / sum(population) as decimal), 3) as pfpr2to10,
  ROUND((sum(msd.infectedindividuals) / cast(sum(msd.population) as decimal)) * 100, 3) as pfprall
from sim.replicate r
  inner join sim.monthlydata md on md.replicateid = r.id
  inner join sim.monthlysitedata msd on msd.monthlydataid = md.id
where r.configurationid = 59797
  and dayselapsed > 4000
--  and dayselapsed in (5022, 6117, 7213, 8309, 9405, 10866)
  and cast(to_date('2007-1-1', 'yyyy-mm-dd') + dayselapsed*INTERVAL'1 day' as varchar) ~ '^....-10-.*'
group by dayselapsed
order by dayselapsed asc

-- Treatment failure comparison
-- 59797 - de novo emergence
-- 59801 - vector control
select c.id,
  md.dayselapsed, 
  sum(md.treatmentfailures) / count(md.treatmentfailures) tfaverage
from sim.configuration c
  inner join sim.replicate r on r.configurationid = c.id
  inner join sim.monthlydata md on md.replicateid = r.id
where (c.id = 59797 or c.id = 59801)
  and md.treatmentfailures != 0
group by c.id, dayselapsed
order by c.id, dayselapsed

-- Select country level treatment faliures
SELECT cast((regexp_matches(filename, '^(\d\.\d*)-bfa\.yml'))[1] as float) as rate,
  md.replicateid, md.dayselapsed, md.treatmentfailures
FROM sim.configuration c 
  inner join sim.replicate r on r.configurationid = c.id
  inner join sim.monthlydata md on md.replicateid = r.id
WHERE c.studyid = 18
  and md.dayselapsed > 4015

-- Query for dates
select distinct dayselapsed, to_date('2007-1-1', 'yyyy-mm-dd') + dayselapsed*INTERVAL'1 day'
from sim.monthlydata
where replicateid = 62339
order by dayselapsed desc

-- Select country level summary across all districts and studies
select cast((regexp_matches(filename, '^(\d\.\d*)-bfa\.yml'))[1] as float) as rate,
  dayselapsed,
  sum(clinicalepisodes) as clinicalepisodes,
  sum(md.treatmentfailures) as treatmentfailures,
  avg(msd.eir) as eir,
  sum(population * pfprunder5) / sum(population) as pfprunder5,
  sum(population * pfpr2to10) / sum(population) as pfpr2to10,
  sum(population * pfprall) / sum(population) as pfprall
from sim.replicate r
  inner join sim.configuration c on c.id = r.configurationid
  inner join sim.monthlydata md on md.replicateid = r.id
  inner join sim.monthlysitedata msd on msd.monthlydataid = md.id
where c.studyid = 16
  and msd.eir != 0 
  and md.treatmentfailures != 0
group by filename, dayselapsed

select cast((regexp_matches(filename, '^(\d\.\d*)-bfa\.yml'))[1] as float) as rate, 
  dayselapsed, 
  sum(msd.population) as population, 
  sum(msd.treatments) as treatments, 
  sum(msd.treatmentfailures) as treatmentfailures
from sim.configuration c
  inner join sim.replicate r on c.id = r.configurationid
  inner join sim.monthlydata md on r.id = md.replicateid
  inner join sim.monthlysitedata msd on msd.monthlydataid = md.id
where c.studyid = 16
  and md.treatmentfailures != 0
  and msd.eir != 0
group by rate, dayselapsed

-- Select country level summary genome data across all districts and studies
select cast((regexp_matches(filename, '^(\d\.\d*)-bfa\.yml'))[1] as float) as rate,
  dayselapsed,
  sum(occurrences) as occurrences,
  sum(clinicaloccurrences) as clinicaloccurrences,
  sum(occurrences0to5) as occurrences0to5,
  sum(occurrences2to10) as occurrences2to10
from sim.replicate r
  inner join sim.configuration c on c.id = r.configurationid
  inner join sim.monthlydata md on md.replicateid = r.id
  inner join sim.monthlygenomedata mgd on mgd.monthlydataid = md.id
where c.studyid = 16
group by filename, dayselapsed

-- Select country level summary with data broken down by genotype
select cast((regexp_matches(filename, '^(\d\.\d*)-bfa\.yml'))[1] as float) as rate,
  dayselapsed,
  g.name,
  sum(occurrences) as occurrences,
  sum(clinicaloccurrences) as clinicaloccurrences,
  sum(occurrences0to5) as occurrences0to5,
  sum(occurrences2to10) as occurrences2to10
from sim.replicate r
  inner join sim.configuration c on c.id = r.configurationid
  inner join sim.monthlydata md on md.replicateid = r.id
  inner join sim.monthlygenomedata mgd on mgd.monthlydataid = md.id
  inner join sim.genotype g on mgd.genomeid = g.id
where c.studyid = 16
group by filename, dayselapsed, g.name

-- Grid of resistance frequency post model burn-in
select dayselapsed, l.x, l.y,
  sum(mgd.weightedfrequency) as resistancefrequency
from sim.monthlydata md
  inner join sim.monthlygenomedata mgd on mgd.monthlydataid = md.id
  inner join sim.location l on l.id = mgd.locationid
  inner join sim.genotype g on g.id = mgd.genomeid
where md.replicateid = 62248
  and md.dayselapsed > (365 * 11)
  and g.name ~ '^.....Y..'
group by dayselapsed, x, y