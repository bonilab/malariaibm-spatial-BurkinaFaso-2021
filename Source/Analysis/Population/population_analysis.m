% population_analysis.m
%
% Plot the basic metrics for the model popuation.
addpath('../Common');
clear;

FILENAME = 'data/population_data_1.txt';
SCALING = 0.005;

%FILENAME = 'data/population/population_data_38.txt';  % Population 37.5 
%FILENAME = 'data/population/population_data_42.txt';  % Population 41.2
%SCALING = 0.02;
STARTDATE = '2007-01-01';


%plotIncrease(FILENAME, STARTDATE);
%plotRatio(FILENAME);
%plotSummary(FILENAME, SCALING);
plotPopulation(FILENAME, STARTDATE, SCALING);


function [] = plotIncrease(filename, startdate)
    data = csvread(filename, 1, 0);
    population = data(:, 2);

    % Select every year
    days = data(:, 1);
    days = days(1:12:end, :);
    days(1) = [];

    % Format the dates
    for ndx = drange(1:size(days, 1))
       days(ndx) = addtodate(datenum(startdate), days(ndx), 'day');
    end

    % Calcluate the percent increase in popuation each year
    population = population(1:12:end, :);
    population = ((population(2:end) - population(1:end -1)) ./ population(1:end -1)) * 100;
    average = mean(population);

    % Plot the data
    hold on;
    plot(days, population);
    yline(average, '--', sprintf("Average %.2g%% annual increase", average));
    yline(2.96, '-.', 'Target 2.96% annual increase');
    hold off;

    ylabel('Annual increase in population');
    datetick('x', 'yyyy');
    set(gca, 'XLimSpec', 'Tight');
    
    title('Burkina Faso - Annual Increase in Population');
        
	graphic = gca;
    graphic.FontSize = 18;
end

function [] = plotPopulation(filename, startdate, scaling)
    % Load the data, delete the first entry since births/deaths is zero
    data = csvread(filename, 1, 0);
    data(1, :) = [];

    dn = prepareDates(filename, 1, startdate);
    dn(1) = [];
    
    population = (data(:, 2) ./ scaling) ./ 1000000;
    plot(dn, population);

    ylabel('Population (Millions)');
    datetick('x', 'yyyy');
    set(gca, 'XLimSpec', 'Tight');

    title(sprintf('Burkina Faso - Simulated Population from %s to %s', datestr(dn(1), 'yyyy'), datestr(dn(end), 'yyyy')), 'FontSize', 28);

    graphic = gca;
    graphic.FontSize = 24;
end


function [] = plotRatio(filename)
    data = csvread(filename, 1, 0);
    data(1, :) = [];

    dn = prepareDates(filename, 1, '2007-1-1');
    dn(1) = [];

    hold on;
    ratio = data(:, 4) ./ data(:, 3);
    average_malaria = mean(ratio);
    plot(dn, ratio);
    
    ratio = (data(:, 4) - data(:, 5)) ./ data(:, 3);
    plot(dn, ratio);    
	average_exclusive = mean(ratio);
    hold off;

    ylabel('Ratio Deaths to Births');
    datetick('x', 'yyyy');
    set(gca, 'XLimSpec', 'Tight');

    % Crude Birth Rate: 41.2 - INSD 2018, p. 11
    % Crude Death Rate: 11.8 - INSD 2018, p. 10
    target = 11.8 / 41.2;
    yline(target, '-.', sprintf('Target ratio %.2g', target));

	yline(average_malaria, '--', sprintf('Average ratio %.2g, malaria inclusive', average_malaria));
    yline(average_exclusive, '--', sprintf('Average ratio %.2g, malaria exclusive', average_exclusive));
    
    title('Burkina Faso - Raito of Deaths to Births');
    
    legend({'All Deaths', 'Deaths Exclusive of Malaria'}, 'Location', 'NorthWest');
    legend boxoff;
    
	graphic = gca;
    graphic.FontSize = 18;
end


function [] = plotSummary(filename, scaling)
    % Load the data, delete the first entry since births/deaths is zero
    data = csvread(filename, 1, 0);
    data(1, :) = [];

    dn = prepareDates(filename, 1, '2007-1-1');
    dn(1) = [];

    hold on;
    yyaxis left;
    population = (data(:, 2) ./ scaling) ./ 1000000;
    plot(dn, population);

    ylabel('Population (Millions)');

    yyaxis right;
    births = (data(:, 3) ./ scaling) ./ 1000;
    plot(dn, births);

    deaths = (data(:, 4) ./ scaling) ./ 1000;
    plot(dn, deaths);

    malariadeaths = (data(:, 5) ./ scaling) ./ 1000;
    plot(dn, malariadeaths);
    hold off;
    
    ylabel('Individuals (Thousands)');
    datetick('x', 'yyyy');
    set(gca, 'XLimSpec', 'Tight');

    title('Burkina Faso - Summary of Vital Population Statistics Generated by Model')
    
    legend({'Total Population', 'Births', 'Deaths', 'Malaria Deaths'}, 'Location', 'NorthWest');
    legend boxoff;

    graphic = gca;
    graphic.FontSize = 18;
end
