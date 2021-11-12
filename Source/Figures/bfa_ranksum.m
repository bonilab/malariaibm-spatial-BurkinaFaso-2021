% bfa_ranksum.m
%
% Calculate the p-Value using the Wilcoxon rank sum test for the various
% policy changes versus the status quo scenario.
addpath('include');
clear;

% Global is bad, but this this script reuses the scan function which
% doesn't take three paramters
global BASELINE_PATH;

% Status quo vs all other policies
BASELINE_PATH = '../Analysis/Loader/out/bfa-fast-no-asaq';
scan('../Analysis/Loader/out/', @calcluate);

% Rapid elmiation with default mutation rate vs all other policies
BASELINE_PATH = '../Analysis/Loader/out/bfa-rapid';
scan('../Analysis/Loader/out/', @calcluate);

% AL/DHA-PPQ MFT with default mutation rate vs all other policies
BASELINE_PATH = '../Analysis/Loader/out/bfa-aldp';
scan('../Analysis/Loader/out/', @calcluate);

function [values] = read_genotype(path)
    values = [];

    files = dir(fullfile(path, '*genotype-summary.csv'));
    for ndx = 1:length(files)
        % Load the data and discard everything but the last year
        filename = fullfile(files(ndx).folder, files(ndx).name);
        data = csvread(filename, 1, 0);
        data = data(data(:, 2) > 10958, :);

        % Find the max value for the year
        values = [values max(sum(data(:, 7)) / sum(data(:, 4)))];
    end   
end

function [values] = read_treatment(path)
    values = [];
        
    files = dir(fullfile(path, '*treatment-summary.csv'));
    for ndx = 1:length(files)
        % Load the data and discard everything but the last year
        filename = fullfile(files(ndx).folder, files(ndx).name);
        data = csvread(filename, 1, 0);
        data = data(data(:, 2) > 10958, :);
        
        % Find the maximum monthly across the district sum
        monthTfr = 0;
        for day = transpose(unique(data(:, 2)))
            value = sum(data(data(:, 2) == day, 6)) / sum(data(data(:, 2) == day, 5)) * 100;
            monthTfr = max(monthTfr, value);
        end

        % Append the district max
        values = [values monthTfr];
    end  
end

% Generate the IRQ output and return the last maximum value for the last
% year of each replicate in the given path
function [values] = calcluate(path, name)
    global BASELINE_PATH;

    % Calcluate the p-value for 580Y frequency
    baseline = read_genotype(BASELINE_PATH);
    policy = read_genotype(path);
    p_freq = ranksum(baseline, policy);

    % Calcluate the p-value for treatment failures
    baseline = read_treatment(BASELINE_PATH);
    policy = read_treatment(path);
    p_treat = ranksum(baseline, policy);
    
    % Print and return the results
    fprintf("%s: p: %f (580Y freqeuncy); %f (treatment failures)\n", name, p_freq, p_treat);
    values = [p_freq p_treat];
end