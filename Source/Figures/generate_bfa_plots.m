% generate_bfa_plots.m
%
% Generate heatmaps and 580Y frequency plot based upon the data downloaded
% by the Python loader script.
addpath('include');
addpath('../Analysis/Common');
clear;

DIRECTORY = '../Analysis/Loader/out';
FREQUENCY = '../Analysis/Loader/out/*frequency*.csv';

STARTDATE = '2007-1-1';
if ~exist('out', 'dir'), mkdir('out'); end

% NOTE for most of these the default image size is 2560 x 1440 at 300 DPI
%      exact sizes can be changed though
plot_heatmaps(FREQUENCY, STARTDATE);

plot_district_frequency(DIRECTORY, STARTDATE);
plot_regional_frequency(DIRECTORY, STARTDATE);
plot_national_frequency(DIRECTORY, STARTDATE);
 
plot_frequency_treatmentfailures(DIRECTORY, STARTDATE);
plot_genotype_frequency(DIRECTORY, STARTDATE);

plot_treatment_data(DIRECTORY, STARTDATE);
% plot_treatment_failures(DIRECTORY, STARTDATE);
