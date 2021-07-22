% bfa_esm_cyclic_curves.m
%
% Generate a "dashboard" of various data points from the cellular reporter
clear;

STARTDATE = '2009-01-01';

% Burkina Faso, calibrated ecozones
%generate_plot('CyclicCurves_data/_580Y_Sahelian', 'Sahelian (short transmission)', STARTDATE);
%generate_plot('CyclicCurves_data/_580Y_Sudano-Sahelian', 'Sudano-Sahelian (long transmission)', STARTDATE);
generate_plot('CyclicCurves_data/_580Y_Sudanian', 'Permanent Transmission ', STARTDATE);

% Exaggerated 
%generate_plot('CyclicCurves_data/_580Y_ExaggeratedSahelian', 'Exaggerated Short Transmission', STARTDATE);
%generate_plot('CyclicCurves_data/_580Y_ExaggeratedSahelianToSudanian', 'Exaggerated Short to Permanent Transmission', STARTDATE);


function [] = generate_plot(directory, region, startDate)
    % Read the data and discard the first 11 years as burn in
    agg_data = csvread(strcat(directory, '/_aggregate_data_0.csv'), 1, 0);
    agg_data = agg_data(agg_data(:, 1) > (11 * 365), :);
    blood_data = csvread(strcat(directory, '/_blood_data_0.csv'), 1, 0);
    blood_data = blood_data(blood_data(:, 1) > (11 * 365), :);

    % Note the dates, prepare our x values
    dates = unique(agg_data(:, 1));
    xValues = dates + datenum(startDate);
    
    % Prepare the variables for storage
    theta = zeros(size(dates, 1), 1);
    pr_symptoms = zeros(size(dates, 1), 1);
    clinical = zeros(size(dates, 1), 1);
    infected = zeros(size(dates, 1), 1);

    % Extract the relevent immunolgoical data
    for ndx = 1:size(dates, 1)
        theta(ndx) = mean(blood_data(blood_data(:, 1) == dates(ndx), 6));
        pr_symptoms(ndx) = 1 - 0.99 / (1 + (theta(ndx) / 0.4) ^ 4);
        clinical(ndx) = agg_data(agg_data(:, 1) == dates(ndx), 4);
        infected(ndx) = agg_data(agg_data(:, 1) == dates(ndx), 3);
    end

	% Prepare the first plot when shows the frequency of 580Y
    subplot(2, 1, 1);
    hold on;
    plot(xValues, agg_data(:, 9) ./ agg_data(:, 3));   % 580yWeighted
    plot(xValues, agg_data(:, 10) ./ agg_data(:, 3));  % 508yUnweighted
%    add_lines(xValues);    
    hold off;
    title(sprintf('580Y Frequency, %s', region));
    format_plot({'580Y Weighted', '580Y Unweighted'}, 'Frequency', false);
    
	% Prepare the second plot which shows the immunological data
    subplot(2, 1, 2);
    hold on;
    plot(xValues, theta);
    plot(xValues, pr_symptoms);
    plot(xValues, clinical ./ infected);
%    add_lines(xValues);
    hold off;
    title(sprintf('Immunological Data, %s', region));
    format_plot({'Theta', 'Probablity of Asymptomatic', 'Phi (Number Clincial / Number Infected)'}, '', true);
end

function [] = add_lines(values)
    for ndx = 1:3:size(values, 1)
        xline(values(ndx), ':');
    end
end

function [] = format_plot(legendItems, label, box)
    ylabel(label);
    datetick('x', 'yyyy');

    legend(legendItems, 'Location', 'NorthWest');
    if ~box
        legend boxoff;
    end
    
    axis tight;
    graphic = gca;
    graphic.FontSize = 18;
end