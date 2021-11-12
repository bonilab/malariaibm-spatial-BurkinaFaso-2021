#!/usr/bin/env python3

# plot_violin.py
#
# Clean the temp from the loader and plot is as violin plots.
#
# Note that this script is fairly fragile since it assumes that all of the 
# replicates have been completed, CSV files generated with the MATLAB script
# and annual data files are in the correct path.
import csv
import glob
import matplotlib.pyplot as plt 
import numpy as np 
import os
import pandas as pd

from matplotlib import rc_file
from pathlib import Path


def plot_core(filter, yaxis, filename, showmeans=True):
    labels  = ['Baseline', 
        '10 year AL/DP MFT', 
        'Rapid AL/DP MFT',
        '10 year Private Market Elimination',
        '10 year Private Market Elimination,\n10 year AL/DP MFT',
        '10 year Private Market Elimination,\nRapid AL/DP MFT',
        'Rapid Private Market Elimination',
        'Rapid Private Market Elimination,\n10 year AL/DP MFT',
        'Rapid Private Market Elimination,\nRapid AL/DP MFT']
    plot(filter, yaxis, filename, labels, showmeans)


def plot_mft(filter, yaxis, filename, showmeans=True):
    labels = ['50% AL / 50% DHA-PPQ MFT',
        '60% AL / 40% DHA-PPQ MFT',
        '70% AL / 30% DHA-PPQ MFT',
        '80% AL / 20% DHA-PPQ MFT',
        '90% AL / 10% DHA-PPQ MFT',
        'AL Only']
    plot(filter, yaxis, filename, labels, showmeans)


def plot_sensitivity(filter, yaxis, filename, showmeans=True):
    labels = [
        'Very Fast (+10x)',
        'Fast (+5x)',
        'Status Quo\nBaseline',
        'Slow (-5x)',
        'Very Slow (-5x)',
        'Very Fast (+10x)',
        'Fast (+5x)',
        'Rapid AL/DHA-PPQ MFT\nBaseline',
        'Slow (-5x)',
        'Very Slow (-5x)',
        'Very Fast (+10x)',
        'Fast (+5x)',
        'Rapid Private Market Elimination\nBaseline',
        'Slow (-5x)',
        'Very Slow (-5x)'
    ]
    plot(filter, yaxis, filename, labels, showmeans)


def plot(filter, yaxis, filename, labels, showmeans):
    # Note the colors used
    COLORS = ['#1b9e77', '#d95f02', '#7570b3']

    # Set our formatting
    rc_file("matplotlibrc-violin")

    # Read the first CSV file and prepare the temp
    path_root = Path('data')
    temp = pd.read_csv(Path(path_root, filter.format(2025)), index_col=0, header=None).T
    replicates = temp.shape[0]
    studies = temp.shape[1]
    
    # Read the rest of the CSV files
    years = ['2025', '2030', '2035']
    data = np.zeros((len(years), replicates, studies))
    for i, yr in enumerate(years):
        data[i,:,:] = pd.read_csv(Path(path_root, filter.format(yr)), index_col=0, header=None).T

    # Determine the divisor for the data set - this gives us the rows and columns
    if len(labels) % 5 == 0:
        divisor = 5
    elif len(labels) % 3 == 0:
        divisor = 3        
    else:
        print("Unbalanced number of entries {}, expected divisor of 3 or 5".format(len(labels)))
        exit(1)

    # Violin plot, grouped by policy
    data_labels = temp.columns
    data_labels = labels
    fig, axs = plt.subplots(nrows=int(len(labels) / divisor), ncols=divisor, figsize=(20, 25), sharey=True, sharex=True,
                            gridspec_kw={'left':0.09, 'right':0.97, 'top':0.95, 'bottom':0.06, 'wspace':0.2, 'hspace':0.22})

    # Format the sub plots
    for ax, (il, l) in zip(axs.flat, enumerate(data_labels)):
        # Generate the plot, hold on to the object for formatting
        vp = ax.violinplot(data[:,:,il].T, positions=range(len(years)), showmeans=showmeans)

        # Format the plot
        ax.set_xticks(range(len(years)))
        ax.set_xticklabels(years)
        if il % divisor == 0:
            ax.set_ylabel(yaxis)
        if il // divisor == 2:
            ax.set_xlabel('Model year')
        ax.set_title(l, fontsize=20)

        # Adjust the color of the plot, assuming each row is a similar concept
        # HOWEVER, this for the MFT plot since all items are related
        if len(data_labels) == 6:
            continue
        index = int(il / divisor)
        for part in ('cbars','cmins','cmaxes','cmeans', 'cmedians'):
            if part in vp:
                vp[part].set_edgecolor(COLORS[index])
        for body in vp['bodies']:
            body.set_facecolor(COLORS[index])

    # Save the figure to disk
    fig.savefig(filename)



# Convert the temp from the loader to the expected format
def prep_pfpr_clinical():
    PATH = "../Analysis/Loader/out/annual-data"
    POLICIES = ['bfa-fast-no-asaq',
                'bfa-aldp10',
                'bfa-aldp',
                'bfa-tenyear',
                'bfa-aldp10-tenyear',
                'bfa-aldp-tenyear',
                'bfa-rapid',
                'bfa-aldp10-rapid',
                'bfa-aldp-rapid']

    for year in (2025, 2030, 2035):
        for current in POLICIES:        
            for file in glob.glob("{}/{}-*.csv".format(PATH, year)):
                temp = pd.read_csv(file)
                for column in temp.filename.unique():
                    
                    # Only write the current column to preserve order
                    if column == current:

                        # Filter the temp and write it
                        clinical = temp[temp.filename == column].clinicalper1000.to_numpy()
                        pfpr = temp[temp.filename == column].pfpr2to10.to_numpy()
                        write_row("data/yr{}_clinical.csv".format(year), [column] + list(clinical))
                        write_row("data/yr{}_pfpr.csv".format(year), [column] + list(pfpr))


def write_row(filename, temp):
    with open(filename, "a") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(temp)


if __name__ == "__main__":
    # The extension to be used, TIFF files will be dramatically larger than PNG
    EXTENSION = 'tif'

    # Plots that need to be generated by this script
    if not os.path.isfile("data/yr2025_clinical.csv"):
        prep_pfpr_clinical()
    plot_core("yr{}_pfpr.csv", "$\it{Pf}$PR$_{2-10}$", "out/bfa-2025to2035-pfpr.{}".format(EXTENSION))
    plot_core("yr{}_clinical.csv", "Clinical Cases per 1000", "out/bfa-2025to2035-clinical.{}".format(EXTENSION), False)

    # Plots that should have data from Matlab, plasmespin needs to be plotted without means
    plot_core("yr{}_580y.csv", "580Y Frequency", "out/bfa-2025to2035-580y.{}".format(EXTENSION))
    plot_core("yr{}_knf_plasmepsin.csv", "3x3$\it{knf}$ and multicopy $\it{Plasmepsin}$ 2,3", "out/bfa-2025_2035-3x3_knf_plasmepsin.{}".format(EXTENSION))
    plot_core("yr{}_knf.csv", "Frequency of \n$\it{Pfcrt}$-k76 $\it{Pfmrd}$1-N86 $\it{Pfmrd}$1-184F", "out/bfa-2025_2035-3x3_knf.{}".format(EXTENSION))
    plot_core("yr{}_plasmespin.csv", "Frequency of \nmulticopy $\it{Plasmepsin}$ 2,3", "out/bfa-2025to2035-plasmepsin.{}".format(EXTENSION), False)
    plot_core("yr{}_tmfailures.csv", "Treatment Failure Rate", "out/bfa-2025to2035-treatmentfailures.{}".format(EXTENSION))
    plot_mft("yr{}_mft_580y.csv", "580Y Frequency", "out/bfa-2025to2035-mft-580y.{}".format(EXTENSION))    
    plot_sensitivity('yr{}_sensitivity_580y.csv', '580Y Frequency', "out/bfa-2025to2035-sensitivity-580y.{}".format(EXTENSION))