% province_frequency.m
%
% Calcluate the median and IQR of the 580Y frequency for the last year of the 
% simuation, for each provience.
addpath('../Common');
clear;

% Get the frequency data from the files
files = dir('../Loader/out/bfa-fast-no-asaq/*genotype-summary.csv');
frequencies = zeros(size(files, 2), 45);
for ndx = 1:length(files)
   filename = fullfile(files(ndx).folder, files(ndx).name);
   frequencies(ndx, :) = calcluate(filename);
end

% Calcluate the percetile for each district
proviences = {'District', '25th', '50th', '75th'};
for ndx = 1:45
    name = getLocationName(ndx);
    result = horzcat(name, num2cell(prctile(frequencies(:, ndx), [25 50 75])));
    proviences = vertcat(proviences, result);
end

% Write to disk
writematrix(proviences, 'status-quo-percentiles.csv');


function [frequencies] = calcluate(filename)
    % Read the data
    data = readmatrix(filename);

    % Get the last 12 months
    days = unique(data(:, 2));
    days = days(end-11:end);

    % Filter the data
    data = data(ismember(data(:, 2), days), :);

    % Calcluate the frequency for the provience
    proviences = transpose(unique(data(:, 3)));
    frequencies = zeros(1, size(proviences, 2));
    for provience = proviences
        % frequency = [weighted occurances] / [infected indivdiuals]
        frequencies(provience) = sum(data(data(:, 3) == provience, 7)) / sum(data(data(:, 3) == provience, 4));
    end
end