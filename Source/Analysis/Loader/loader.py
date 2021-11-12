#!/usr/bin/python

##
# loader.py
#
# This Python2 script pulls the relevent study data from the server.
##
import csv
import glob
import os
import psycopg2
import sys

from utility import progressBar

# Connection string for the database
CONNECTION = "host=masimdb.vmhost.psu.edu dbname=burkinafaso user=sim password=sim"

# Default path template for downloaded replicates
PATH_TEMPLATE = "out/{}"

# Default filename path template for downloaded replicates
FREQUENCIES_TEMPLATE = "out/{}/{}-genotype-frequencies.csv"
GENOTYPE_TEMPLATE = "out/{}/{}-genotype-summary.csv"
TREATMENT_TEMPLATE = "out/{}/{}-treatment-summary.csv"

# Indices in getReplicates query
LABEL = 0
REPLICATEID = 4
COMPLETE = 5


# Return the components of the frequency data for each cell after the burn-in period is complete
def get_580y_frequency_subset(replicateId, subset):
    sql = """   
        SELECT dayselapsed, l.x, l.y, infectedindividuals,
            sum(clinicaloccurrences) AS clinicaloccurrences,
            sum(weightedoccurrences) AS weightedoccurrences
        FROM (
            SELECT md.replicateid, md.id, mgd.location, md.dayselapsed,
                sum(CASE WHEN g.name ~ '^.....Y..' THEN mgd.clinicaloccurrences ELSE 0 END) AS clinicaloccurrences,
                sum(CASE WHEN g.name ~ '^.....Y..' THEN mgd.weightedoccurrences ELSE 0 END) AS weightedoccurrences
            FROM sim.monthlydata md
                INNER JOIN sim.monthlygenomedata mgd ON mgd.monthlydataid = md.id
                INNER JOIN sim.genotype g ON g.id = mgd.genomeid
            WHERE md.replicateid = %(replicateId)s AND md.dayselapsed in ({})
            GROUP BY md.id, mgd.location) one
        INNER JOIN (
            SELECT md.id, msd.location, msd.infectedindividuals 
            FROM sim.monthlydata md
                INNER JOIN sim.monthlysitedata msd ON msd.monthlydataid = md.id
            WHERE md.replicateid = %(replicateId)s AND md.dayselapsed in ({})) two ON one.id = two.id AND one.location = two.location
        INNER JOIN sim.location l on l.id = one.location
        GROUP BY dayselapsed, l.x, l.y, infectedindividuals""".format(subset, subset)
    return select(sql, {'replicateId':replicateId, 'startDay':startDay})


# Return the aggergated annual data for each of the replicates contained within
#  the study for the date range (i.e., months) indicated
def get_annual_data(studyId, dates, publicmarket):
    sql = """
        SELECT filename,
            replicateid,
            max(population) AS population,
            sum(cases) AS cases,
            round(sum(treatedcases) * %(publicmarket)s, 0) AS reportedcases,
            round((sum(treatedcases) * %(publicmarket)s) / (max(population) / 1000), 0) AS clinicalper1000,
            round(cast(sum(pfpr2to10 * population) / sum(population) as numeric), 2) AS pfpr2to10
        FROM (
            SELECT replace(c.filename, '.yml', '') AS filename,
                md.replicateid, 
                md.dayselapsed,
                sum(msd.population) AS population,
                sum(msd.clinicalepisodes) AS cases,
                sum(msd.treatments) AS treatedcases,
                sum(msd.pfpr2to10 * msd.population) / sum(msd.population) AS pfpr2to10
            FROM sim.configuration c
                INNER JOIN sim.replicate r ON r.configurationid = c.id
                INNER JOIN sim.monthlydata md ON md.replicateid = r.id
                INNER JOIN sim.monthlysitedata msd ON msd.monthlydataid = md.id
            WHERE c.studyid = %(studyId)s
            AND md.dayselapsed IN %(dates)s
            GROUP BY c.filename, md.replicateid, md.dayselapsed) iq
        GROUP BY replicateid, filename
        ORDER BY filename"""
    return select(sql, {'publicmarket':publicmarket, 'studyId':studyId, 'dates':dates})


# Get a list of all of the studies (i.e., configurations) associated with this studyId
def get_studies(studyId):
    sql = """
    SELECT DISTINCT c.id, replace(c.filename, '.yml', '') AS filename, r.aggregationlevel
    FROM sim.configuration c
        INNER JOIN sim.replicate r on r.configurationid = c.id
    WHERE c.studyid = %(studyId)s"""
    return select(sql, {'studyId':studyId})


# Return all of the replicates for the given configuration id
def get_replicates(configurationId, label):
    sql = """
    SELECT %(label)s as label,
        nrows, ncols, c.id AS configurationid, r.id AS replicateid,
	    CASE WHEN r.endtime IS NULL THEN 0 ELSE 1 END As complete
    FROM sim.configuration c INNER JOIN sim.replicate r ON r.configurationid = c.id
    WHERE c.id = %(configurationId)s
      AND r.endtime IS NOT NULL"""
    return select(sql, {'configurationId':configurationId, 'label':label})


# Retrive all of the genotype frequency data for the replicate. 
def get_frequency_data(replicateId, startDay, modelStartDate):
    sql = """
        SELECT replicateid, dayselapsed, year, substring(g.name, 1, 7) as name, frequency
        FROM (
            SELECT mgd.replicateid, mgd.genomeid, mgd.dayselapsed, 
                TO_CHAR(TO_DATE(%(modelStartDate)s, 'YYYY-MM-DD') + interval '1' day * mgd.dayselapsed, 'YYYY') AS year,
                mgd.weightedoccurrences / msd.infectedindividuals AS frequency, msd.infectedindividuals
            FROM (
                SELECT md.replicateid, md.id, md.dayselapsed, mgd.genomeid, sum(mgd.weightedoccurrences) AS weightedoccurrences
                FROM sim.monthlydata md INNER JOIN sim.monthlygenomedata mgd ON mgd.monthlydataid = md.id
                WHERE md.replicateid = %(replicateId)s AND md.dayselapsed > %(startDay)s
                GROUP BY md.id, md.dayselapsed, mgd.genomeid) mgd
            INNER JOIN (
                SELECT md.id, sum(msd.infectedindividuals) AS infectedindividuals
                FROM sim.monthlydata md INNER JOIN sim.monthlysitedata msd ON msd.monthlydataid = md.id
                WHERE md.replicateid = %(replicateId)s AND md.dayselapsed > %(startDay)s
                GROUP BY md.id) msd 
            ON msd.id = mgd.id) frequency inner join sim.genotype g on g.id = frequency.genomeid"""
    return select(sql, {'replicateId':replicateId, 'startDay':startDay, 'modelStartDate':modelStartDate})            


# Get the summary data for the given replicate genotype information after the given date
def get_genotype_summary(replicateId, startDay):
    sql = """
        SELECT dayselapsed, l.district,
            sum(infectedindividuals) AS infectedindividuals,
            sum(occurrences) AS occurrences,
            sum(clinicaloccurrences) AS clinicaloccurrences,
            sum(weightedoccurrences) AS weightedoccurrences
        FROM (
            SELECT md.replicateid, md.id, mgd.location, md.dayselapsed,
                sum(CASE WHEN g.name ~ '^.....Y..' THEN mgd.occurrences ELSE 0 END) AS occurrences,
                sum(CASE WHEN g.name ~ '^.....Y..' THEN mgd.clinicaloccurrences ELSE 0 END) AS clinicaloccurrences,
                sum(CASE WHEN g.name ~ '^.....Y..' THEN mgd.weightedoccurrences ELSE 0 END) AS weightedoccurrences
            FROM sim.monthlydata md
                INNER JOIN sim.monthlygenomedata mgd ON mgd.monthlydataid = md.id
                INNER JOIN sim.genotype g ON g.id = mgd.genomeid
            WHERE md.replicateid = %(replicateId)s AND md.dayselapsed > %(startDay)s
            GROUP BY md.id, mgd.location) one
        INNER JOIN (
            SELECT md.id, msd.location, msd.infectedindividuals 
            FROM sim.monthlydata md
                INNER JOIN sim.monthlysitedata msd ON msd.monthlydataid = md.id
            WHERE md.replicateid = %(replicateId)s AND md.dayselapsed > %(startDay)s) two ON one.id = two.id AND one.location = two.location
        INNER JOIN sim.location l on l.id = one.location
        GROUP BY dayselapsed, l.district"""
    return select(sql, {'replicateId':replicateId, 'startDay':startDay})


# Get the summary data for the given replicate treatment information after the given date
def get_treatment_summary(replicateId, startDay):
    sql = """
        SELECT dayselapsed, l.district,
            sum(infectedindividuals) AS infectedindividuals,
            sum(clinicalepisodes) AS clinicalepisodes,
            sum(treatmentfailures) AS treatmentfailures,
            sum(nontreatment) AS nontreatment,
	        sum(population) as population
        FROM (
            SELECT md.id, 
                msd.location, md.dayselapsed, msd.infectedindividuals, msd.population,
                msd.clinicalepisodes, msd.treatmentfailures, msd.nontreatment
        FROM sim.monthlydata md
            INNER JOIN sim.monthlysitedata msd ON msd.monthlydataid = md.id
        WHERE md.replicateid = %(replicateId)s AND md.dayselapsed > %(startDay)s) one
        INNER JOIN sim.location l on l.id = one.location
        GROUP BY dayselapsed, l.district"""
    return select(sql, {'replicateId':replicateId, 'startDay':startDay})


# Query and save the annual data for the study id provided
def process_annual_data(studyId):
    # Percentage of public market treatments, drawn from configuration
    # 3: Status Quo
    # 4: Rapid Private Market Elimination
    # 5: Ten Year Private Market Elimination
    # 6: Status Quo
    # 7: Rapid Private Market Elimination
    publicmarket = {
        3: {2025: 0.832, 2030: 0.832, 2035: 0.832},
        4: {2025: 1.0, 2030: 1.0, 2035: 1.0},
        5: {2025: 0.916, 2030: 1.0, 2035: 1.0},
        6: {2025: 0.832, 2030: 0.832, 2035: 0.832},
        7: {2025: 1.0, 2030: 1.0, 2035: 1.0}
    }

    # Range of dates for the year
    ranges = {
        2025: (6575, 6606, 6634, 6665, 6695, 6726, 6756, 6787, 6818, 6848, 6879, 6909),
        2030: (8401, 8432, 8460, 8491, 8521, 8552, 8582, 8613, 8644, 8674, 8705, 8735),
        2035: (10227, 10258, 10286, 10317, 10347, 10378, 10408, 10439, 10470, 10500, 10531, 10561)
    }

    # Exit if a study was not provided
    if studyId not in publicmarket.keys():
        print("Invalid study provided, {}".format(studyId))
        exit(1)

    # Let the user know what we are doing
    print("Processing annual data...")
    count = 0
    progressBar(count, len(ranges.keys()))
    
    for key in ranges.keys():
        # Query and save the data
        data = get_annual_data(studyId, ranges[key], publicmarket[studyId][key])
        with open("out/{}-{}-annual-data.csv".format(key, studyId), "wb") as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(["filename", "replicateid", "population", "cases", "reportedcases", "clinicalper1000", "pfpr2to10"])
            for row in data:
                writer.writerow(list(row))

        # Note the process
        count = count + 1
        progressBar(count, len(ranges.keys()))


# Process the frequency data by aggregating it together across all cells and replicates for each rate
def process_frequencies(replicates, subset):
    # If there are not replicates, then return
    if len(replicates) == 0: return

    # Update the user and note common data
    print("Processing {} replicate frequencies...".format(len(replicates)))
    nrows = replicates[0][1]
    ncols = replicates[0][2]
    
    # Note the progress
    total = 0
    progressBar(total, len(replicates) + 1)

    # Iterate through all of the rows
    currentRate = None
    for replicate in replicates:

        # Reset the replicate count on a new row
        if currentRate != replicate[0]:
            if currentRate is not None: 
                save_frequencies(data, currentRate)
                del data
            currentRate = replicate[0]
            data = {}

        # Run a short query to see if we have anything to work with
        for row in get_580y_frequency_subset(replicate[REPLICATEID], subset):
            days = row[0]
            if days not in data: data[days] = [[[0, 0, 0] for _ in range(nrows)] for _ in range(ncols)]
            c = row[1]
            r = row[2]

            # Array formatted as: 0 - infectedindividuals (query index 3)
            #                     1 - weightedoccurrences (query index 5)
            #                     3 - count
            data[days][r][c][0] += row[3]
            data[days][r][c][1] += row[5]
            data[days][r][c][2] += 1

        # Note the progress
        total = total + 1
        progressBar(total, len(replicates) + 1)

    # Save the last data set
    save_frequencies(data, currentRate)
    progressBar(total + 1, len(replicates) + 1) 


# Process the summary data by appending it for each complete replicate and day
def process_summaries(replicates, burnIn, modelStartDate):
    # Update the user
    print("Processing {} replicate summaries...".format(len(replicates)))

    # Note the progress
    total = 0
    progressBar(total, len(replicates) + 1)

    # Iterate through all of the rows
    for replicate in replicates:

        # Only download complete summaries
        if replicate[COMPLETE] == False: continue

        # Check to see if the work has already been done
        filename = GENOTYPE_TEMPLATE.format(replicate[LABEL], replicate[REPLICATEID])
        if not os.path.exists(filename):
            save_genotype_summary(replicate[LABEL], replicate[REPLICATEID], burnIn)

        filename = TREATMENT_TEMPLATE.format(replicate[LABEL], replicate[REPLICATEID])
        if not os.path.exists(filename):
            save_treatment_summary(replicate[LABEL], replicate[REPLICATEID], burnIn)

        filename = FREQUENCIES_TEMPLATE.format(replicate[LABEL], replicate[REPLICATEID])
        if not os.path.exists(filename):
            save_genotype_frequencies(replicate[LABEL], replicate[REPLICATEID], burnIn, modelStartDate)
        
        # Note the progress
        total = total + 1
        progressBar(total, len(replicates) + 1)

    # Note that we are done
    progressBar(len(replicates) + 1, len(replicates) + 1) 


def save_frequencies(data, rate):
    with open("out/{}-frequency-map.csv".format(rate), "wb") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["days", "row", "col", "frequency"])

        for day in sorted(data.keys()):
            for row in range(len(data[day])):
                for col in range(len(data[day][row])):

                    # Array formatted as: 0 - infectedindividuals (query index 3)
                    #                     1 - weightedoccurrences (query index 5)
                    #                     3 - count

                    # If the count is still zero, press on
                    count = data[day][row][col][2]
                    if count == 0: continue

                    infectedindividuals = data[day][row][col][0]
                    weightedoccurrences = data[day][row][col][1]                   

                    # Save the average of the frequencies recorded
                    frequency = (weightedoccurrences / count) / (infectedindividuals / count)
                    writer.writerow([day, row, col, frequency])


# Query for the genotype frequencies data and save it to disk
def save_genotype_frequencies(label, replicateId, burnIn, modelStartDate):
    # Create the path if it doesn't exist
    path = PATH_TEMPLATE.format(label)
    if not os.path.exists(path): os.makedirs(path)

    # Load the data
    data = get_frequency_data(replicateId, burnIn, modelStartDate)

    # Save the data to disk as a CSV file. 
    filename = FREQUENCIES_TEMPLATE.format(label, replicateId)
    with open(filename, "wb") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["replicateId", "days", "year", "name", "frequency"])
        for row in data:
            writer.writerow(list(row))


# Query for the genotype summary information and save it to disk
def save_genotype_summary(label, replicateId, burnIn):
    # Create the path if it doesn't exist
    path = PATH_TEMPLATE.format(label)
    if not os.path.exists(path): os.makedirs(path)

    # Load the data
    data = get_genotype_summary(replicateId, burnIn)   

    # Save the data to disk as a CSV file, replicateid is redundant, but useful
    # when scripting to avoid messing around with the filename in Matlab
    filename = GENOTYPE_TEMPLATE.format(label, replicateId) 
    with open(filename, "wb") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["replicateId", "days", "district", "infectedindividuals", "occurrences", "clinicaloccurrrences", "weightedoccurrences"])
        for row in data:
            data = [replicateId] + list(row)
            writer.writerow(data)


# Query for the treatment summary information and save it to disk
def save_treatment_summary(label, replicateId, burnIn):
    # Create the path if it doesn't exist
    path = PATH_TEMPLATE.format(label)
    if not os.path.exists(path): os.makedirs(path)

    # Load the data
    data = get_treatment_summary(replicateId, burnIn)   

    # Save the data to disk as a CSV file, replicateid is redundant, but useful
    # when scripting to avoid messing around with the filename in Matlab
    filename = TREATMENT_TEMPLATE.format(label, replicateId) 
    with open(filename, "wb") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["replicateId", "days", "district", "infectedindividuals", "clinicalepisodes", "treatmentfailures", "nontreatment", "population"])
        for row in data:
            data = [replicateId] + list(row)
            writer.writerow(data)    


def main(studyId, burnIn, subset, modelStartDate):

    # Get the studies
    print("Querying for studies...")
    studies = get_studies(studyId)
    if len(studies) == 0:
        print("No studies to process!")
        return
    
    # Get the annual data
    process_annual_data(studyId)

    # Let the user know what is going on
    if len(studies) == 1:
        print("Processing study...")
    else:
        print("Processing {} studies...".format(len(studies)))
    
    counter = 1
    for study in studies:
        # Process the replicates for this study
        replicates = get_replicates(study[0], study[1])
        process_summaries(replicates, burnIn, modelStartDate)

        # Only generate the frequency map if logging was at the cellular level
        if study[2] == 'C':
            process_frequencies(replicates, subset)
        
        # Update the status for the user
        if len(studies) > 1:
            print("{} of {} studies complete".format(counter, len(studies)))
            counter += 1


def select(sql, parameters):
    # Open the connection
    connection = psycopg2.connect(CONNECTION)
    cursor = connection.cursor()

    # Execute the query, note the rows
    cursor.execute(sql, parameters)
    rows = cursor.fetchall()

    # Clean-up and return
    cursor.close()
    connection.close()
    return rows


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: ./loader.py [studyId] [startDay]")
        print("studyId  - database id of the study")
        print("startDay - the first model day to start processing data for")
        exit(0)

    # Prepare the environment
    if not os.path.exists("out"): 
        os.makedirs("out")
    else:
        for filename in glob.glob("out/*summary*.csv"): os.remove(filename)

    # Parse the parameters
    studyId = int(sys.argv[1])
    startDay = int(sys.argv[2])

    # TODO Get this from somewhere else
    MODELSTARTDATE = "2007-01-01"

    # TODO Find a better way of getting the subset
    # October every three years starting in 2020 - 5022, 6117, 7213, 8309, 9405, 10866
    # January every five years starting in 2021 - 5114, 6940, 8766, 10592
    main(studyId, startDay, "5114, 6940, 8766, 10592", MODELSTARTDATE)

