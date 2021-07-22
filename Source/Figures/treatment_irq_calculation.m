% frequnecy_iqr_calculation.m
% 
% Scan the directory of the loader output and report the IQR for the
% replicates of each directory. 
addpath('include');
clear;

[data, labels] = scan('../Analysis/Loader/out/', @report);
bfa_boxplot(data, labels, 'Maximum Monthly Treatment Failure Rate');

% Generate the IRQ output and return the last maximum value for the last
% year of each replicate in the given path
function [tfr] = report(path, name)
    tfr = [];
        
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
        tfr = [tfr monthTfr];
    end

    % Find 25th, 50th, and 75th percentile of the data
    result = prctile(tfr, [25 50 75]);
    
	% Pretty print the results
    fprintf("%s: %.2f%% (IQR %.2f%% - %.2f%%), max: %.2f%%, count: %d\n", name, result(2), result(1), result(3), max(tfr), size(tfr, 2));
end
