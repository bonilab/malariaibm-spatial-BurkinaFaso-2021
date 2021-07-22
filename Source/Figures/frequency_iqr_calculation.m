% frequency_iqr_calculation.m
% 
% Scan the directory of the loader output and report the IQR for the
% replicates of each directory. 
addpath('include');
clear;

[data, labels] = scan('../Analysis/Loader/out/', @report);
bfa_boxplot(data, labels, '580Y Frequency');

% Generate the IRQ output and return the last maximum value for the last
% year of each replicate in the given path
function [values] = report(path, name)
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

    % Find 25th, 50th, and 75th percentile of the data
    result = prctile(values, [25 50 75]);
    
	% Pretty print the results
    if strcmp(name, 'bfa-import')
        fprintf("%s: %.3e (IQR: %.3e - %.3e), max: %e.3, count: %d\n", name, result(2), result(1), result(3), max(values), size(values, 2));
        return
    end
    fprintf("%s: %.3g (IQR %.3g - %.3g), max: %.3g, count: %d\n", name, result(2), result(1), result(3), max(values), size(values, 2));
end
