% basic_plots.m
%
% This file contains various basic plots that were used while writing the
% manuscript but that may not appear in the manuscript or supplmental
% materials.
addpath('../Common');
clear;

STARTDATE = '2007-1-1';

%plot_october_pfpr('data/0.001983-summary-pfpr.csv', STARTDATE);

plot_october_pfpr('data/fig7/fig7-october-pfpr.csv', STARTDATE);
%plot_treatment_failures('data/fig7/fig7-treatment-failures.csv', STARTDATE);

% Plot the data set for the treatment failures
function [] = plot_treatment_failures(filename, startdate)
    raw = csvread(filename, 1, 0);
    dn = prepareDates(filename, 2, startdate);

    hold on
    for studyid = transpose(unique(raw(:, 1)))
       data = raw(raw(:, 1) == studyid, :);

       plot(dn(:, 1:size(data, 1)), data(:, 3));
    end
    hold off;

    legend({'De Novo Emergence', 'Vector Control'});
    datetick('x', 'yyyy');

    title('Burkina Faso - de novo mutation versus vector control');
    ylabel('Treatment Failures');
    xlabel('Model Year');

    graphic = gca;
    graphic.FontSize = 18;
end

% Plot the data set that is limited October (approximate peak of Burkina
% Faso malaria season).
function [] = plot_october_pfpr(filename, startdate)
    data = csvread(filename, 1, 0);
    dn = prepareDates(filename, 1, startdate);
    plot(dn, data(:, 2));

    datetick('x', 'yyyy');

    title('Burkina Faso - October PfPR_{2 to 10}, 0.001983 mutation rate');
    ylabel('PfPR_{2 to 10}');
    xlabel('Model Year');

    graphic = gca;
    graphic.FontSize = 18;
end