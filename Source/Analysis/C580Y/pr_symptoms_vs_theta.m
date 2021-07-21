% pr_symptoms_vs_theta.m
% 
% Plot the mean probablity of progression to symptoms versus the mean theta
% for the infected popuation.
%
% NOTE This script requires 2019b or higher
clear;

% Some constants for the script
MONTHS = 118;
STARTDATE = '2007-1-1';

% Setup for the tiling
tiledlayout(2, 2, 'TileSpacing', 'compact')

% Permanent transmission
nexttile;
scan('data/Permanent/', 'Permanent Transmission', MONTHS, STARTDATE);

% Burkina Faso, seasonal tranmission
nexttile;
scan('data/BFA/', 'Short Seasonal Transmission (Burkina Faso)', MONTHS, STARTDATE);

% Permanent to exaggerated transmission
nexttile;
scan('data/Switch/', 'Permanent to Exaggerated Short Transmission', MONTHS, STARTDATE);

% Exaggerated seasonal transmission
nexttile;
scan('data/Exaggerated/', 'Exaggerated Short Transmission', MONTHS, STARTDATE);

% Common legend
lg = legend({'Probablity of Asymptomatic', 'Unweighted Frequency 580Y', ...
             'Phi (# Clinical / # Infected)', 'Theta', 'Infected'}, ...
             'Orientation','horizontal', 'Location', 'southoutside');


% Scan the directory indicated for replicates to add to the plot
function [] = scan(directory, plotTitle, months, startDate)
    files = dir(strcat(directory, '_aggregate_data_*.csv'));
    for ndx = 1:size(files, 1)
        bloodData = strcat(directory, sprintf('_blood_data_%d.csv', ndx));
        aggregateData = strcat(directory, sprintf('_aggregate_data_%d.csv', ndx));
        dates = add_plot(bloodData, aggregateData, months, startDate);
    end
    format(dates, plotTitle);
end

% Add the filesp provided to the current plot
function [dates] = add_plot(bloodData, aggregateData, months, startDate)
    % Load the data, discard burn-in period
    bd = csvread(bloodData, 1);
    bd = bd(bd(:, 1) > 4000, :);
    agg = csvread(aggregateData, 1);
    agg = agg(agg(:, 1) > 4000, :);
    
    % Get last N months
    days = transpose(unique(bd(:, 1)));
    days = days((end - (months - 1)):end);
    
    % Prepare for the data
    dates = zeros(months, 1);
    
    mean_theta = zeros(months, 1);
    pr_symptoms = zeros(months, 1);
    
    clinical = zeros(months, 1);
    frequency = zeros(months, 1);
    phi = zeros(months, 1);
    infected = zeros(months, 1);
    
    % Extract the relevent data for each month
    for ndx = 1:size(days, 2)
        % Note the dates
        dates(ndx) = addtodate(datenum(startDate), days(ndx), 'day');
        
        % Extract from the blood concentration data
        mean_theta(ndx) = mean(bd(bd(:, 1) == days(ndx), 6));
        pr_symptoms(ndx) = 1 - 0.99 / (1 + (mean_theta(ndx) / 0.4) ^ 4);

        % Extract from the aggregate data
        data = agg(agg(:, 1) == days(ndx), :);   
        clinical(ndx) = data(:, 4);
        frequency(ndx) = data(:, 10) ./ data(:, 3);
        phi(ndx) = clinical(ndx) / data(:, 3);
        infected(ndx) = data(:, 3) / 10000;
    end    
    
    % Add everything to the plot
    hold on;
    plot(dates, pr_symptoms, 'Color', '#7570b3');
    plot(dates, frequency, 'Color', '#000');
    plot(dates, phi, 'Color', '#4daf4a');
    plot(dates, mean_theta, 'Color', '#984ea3');
    plot(dates, infected, 'Color', '#e41a1c');
    ylabel('Frequency / Probablity');    
end

% Format the plot
function [] = format(dates, plotTitle)
    % Format the x-axis for the dates
    for ndx = 1:3:size(dates, 1)
        xline(dates(ndx), ':');
    end
    xline(dates(end - 60));
    datetick('x', 'yyyy');

	% Update the final elements
    title(plotTitle);
    axis tight;
    graphic = gca;
    graphic.FontSize = 18;
end
