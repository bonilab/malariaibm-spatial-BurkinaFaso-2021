% bfa_rainy.m
%
% This file contains various functions used to evalute how effective the
% seasonality alignment is for Burkina Faso.
clear;

hold on;

plot_seasonality('data/bfa-short.csv', 'Short', '12,627 population, 85% access to treatment, Beta 0.50');

hold off;

function [] = plot_seasonality(filename, period, attributes)

    % Load the data and prepare the dates
    data = csvread(filename, 1, 0);
    dn = [];
    for days = data(:, 2)'
        dn(end+1) = addtodate(datenum('2006-1-1'), days, 'day');
    end

    % Plot the major data
    plot(dn, data(:, 6));

    % Set the number of days, default short
    days = 220;
    if period == "Long"
        days = 235;
    end
    
    % Plot the markers for the peaks
    for year = 0:5
        offset = addtodate(dn(1), days, 'day');
        offset = addtodate(offset, year, 'year');
        if year == 0
            label = 'Expected Peak';
        else
            label = '';
        end
        line = xline(offset, '-.', label, 'FontSize', 18);
        line.LabelVerticalAlignment = 'middle';
        line.LabelHorizontalAlignment = 'center';
    end

    datetick('x', 'yyyy');
    axis tight;

    title({sprintf('Burkina Faso, %s Seasonality', period), attributes});
    xlabel('Model Year');
    ylabel('PfPR_{2 to 10}');

    graph = gca;
    graph.FontSize = 18;
end
