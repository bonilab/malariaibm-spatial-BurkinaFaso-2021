% c580y_analysis.m
%
% This script was written to allow comparisions to take place between all
% infected indivdiuals and 580Y data to determine why there is an apparent
% linkage between the seasonality in the model and the frequency of 580Y in
% the popuation.
clear;

FILENAME = '../Analysis/Loader/out/0.001983-summary-data.csv';
TITLE = '580Y Comparison, 0.001983 Mutation Rate';

%FILENAME = '../Analysis/Loader/out/0.0001983-summary-data.csv';
%TITLE = '580Y Comparison, 0.0001983 Mutation Rate';

STARTDATE = '2007-1-1';

INFECTEDINDIVIDUALS = 4;
OCCURRENCES = 5;
CLINICAL = 6;
WEIGHTED = 7;

colors = colormap(lines(5));

hold on;
generate(FILENAME, INFECTEDINDIVIDUALS, STARTDATE, colors);
generate(FILENAME, OCCURRENCES, STARTDATE, colors);
generate(FILENAME, CLINICAL, STARTDATE, colors);
generate(FILENAME, WEIGHTED, STARTDATE, colors);
frequency(FILENAME, STARTDATE, colors);

datetick('x', 'yyyy');
addLegend({'Infected Individuals (all genotypes)', '580Y Occurrences', ...
           '580Y Clincial Occurances', '580Y Weighted Occurances', '580Y Frequency'}, colors);

yyaxis left;
ylabel('Discrete Count (log10)');

yyaxis right;
ylabel('580Y Frequency');

title(TITLE);

graphic = gca;
graphic.FontSize = 18;
hold off;

function [] = generate(filename, index, startdate, cm)
    raw = csvread(filename, 1, 0);
    dn = prepareDates(filename, 2, startdate);
    values = zeros(1, size(dn, 2));
    for replicate = transpose(unique(raw(:, 1)))
        data = raw(raw(:, 1) == replicate, :);
        ndx = 1;
        for date = transpose(unique(data(:, 2)))
            values(ndx) = sum(data(data(:, 2) == date, index));
            ndx = ndx + 1;
        end
        plot(dn, log10(values), 'Color', cm(index - 3, :));
    end
end

function [] = frequency(filename, startdate, cm)
    yyaxis right;
    raw = csvread(filename, 1, 0);
    dn = prepareDates(filename, 2, startdate);
    values = zeros(1, size(dn, 2));
    for replicate = transpose(unique(raw(:, 1)))
        data = raw(raw(:, 1) == replicate, :);
        ndx = 1;
        for date = transpose(unique(data(:, 2)))
            % Sum(weighted) / Sum(infected)
            values(ndx) = sum(data(data(:, 2) == date, 7)) / ...
                          sum(data(data(:, 2) == date, 4));
            ndx = ndx + 1;
        end
        plot(dn, values, '-', 'Color', cm(5, :));
    end
end

function [] = addLegend(labels, colors)
    h = zeros(1, 1);
    index = 1;
    for label = labels
        h(index) = scatter(NaN, NaN, [], colors(index, :), 'filled');
        index = index + 1;
    end
	legend(h, cellstr(labels'), 'Location', 'NorthWest');
    legend boxoff;
end