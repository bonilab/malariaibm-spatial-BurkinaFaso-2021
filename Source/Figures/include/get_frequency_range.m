% get_frequency_range.m
%
% Report the minimum and maximum frequency range for the file supplied.

function [minimum, maximum] = get_frequency_range(filename)
    % Load and filter the data to the last time point
    data = csvread(filename, 1, 0);
    data = data(data(:, 1) == max(data(:, 1)), :);
    
    % Return the minimum and maximum
    minimum = min(data(:, 4));
    maximum = max(data(:, 4));
end