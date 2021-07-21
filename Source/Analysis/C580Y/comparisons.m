% comparisons.m
%
% This script contains various functions for generating basic plots that
% are useful for assessing the model calibration, or other useful
% comparisons.
addpath('../Analysis/Common');
clear;

STARTDATE = '2007-1-1';
SUMMARY = '../Loader/out/*summary*.csv';

STARTDATE = '2007-01-01';
SCALING = 0.25;


%plotPopulation(FILENAME, STARTDATE, SCALING);
%plotTreatmentFailures(FILENAME, STARTDATE, SCALING);

function [] = plotClinical(directory, startDate)
    files = dir(directory);
    
    hold on;
    for ndx = 1:length(files)
        filename = fullfile(files(ndx).folder, files(ndx).name);
        rate = char(extractBetween(files(ndx).name, 1, 9));
        rate = strrep(rate, '-', '');        
        
        raw = csvread(filename, 1, 0);
        dn = prepareDates(filename, 2, startDate);
        
        cases = zeros(1, size(dn, 2));
        prevlence = zeros(1, size(dn, 2));
        
        for replicate = transpose(unique(raw(:, 1)))
            data = raw(raw(:, 1) == replicate, :);
            ndx = 1;
            for date = transpose(unique(data(:, 2)))
                cases(ndx) = sum(data(data(:, 2) == date, 6));
                prevlence(ndx) = cases(ndx) / sum(data(data(:, 2) == date, 4));
                ndx = ndx + 1;
            end
            yyaxis left;
            plot(dn, log10(cases));
            
            yyaxis right;
            plot(dn, prevlence);
        end           
    end
    hold off;
    
    yyaxis left;
    ylabel('Clinical Episodes (log 10)')
    
    yyaxis right;
    ylabel('Prevelence of 580Y clincial cases vs. all infections')
    
    datetick('x', 'yyyy');
    
    % Save and close
    set(gcf, 'Position', get(0, 'Screensize'));    
	saveas(gcf, sprintf('out/%s-clinical.png', rate));
    clf;
    close;      
end

function [] = plotPopulation(filename, startdate, scaling)
    raw = csvread(filename, 1, 0);
    
    hold on;
    rates = unique(raw(:, 1));
    for rate = transpose(rates)
        data = raw(raw(:, 1) == rate, :);
        
        % Prepare the dates
        dn = [];
        for value = transpose(data(:, 2))
            dn(end + 1) = addtodate(datenum(startdate), value, 'day');
        end 
        
        plot(dn, data(:, 3) ./ scaling ./ 1000000);
    end

    datetick('x', 'yyyy');
    set(gca, 'XLimSpec', 'Tight');

    title('Burkina Faso Population');
    ylabel('Population (Millions)');
    xlabel('Model Year');

    legend(cellstr(num2str(rates, '%g')), 'Location', 'NorthWest', 'NumColumns', 2);
    legend boxoff;

    graphic = gca;
    graphic.FontSize = 18;

    hold off;
end

function [] = plotTreatmentFailures(filename, startdate, scaling)
    raw = csvread(filename, 1, 0);

    hold on;
    rates = unique(raw(:, 1));
    for rate = transpose(rates)
        data = raw(raw(:, 1) == rate, :);
        
        % Prepare the dates
        dn = [];
        for value = transpose(data(2:end, 2))
            dn(end + 1) = addtodate(datenum(startdate), value, 'day');
        end

        % Prepare the treatment failures
        values = data(:, 5) ./ scaling ./ 100000;
        values = values(2:end) -  values(1:end - 1);
        
        plot(dn, values);
    end

    datetick('x', 'yyyy');
    set(gca, 'XLimSpec', 'Tight');

    title('Burkina Faso Treatment Failures vs. Increase in Treatment Coverage');
    ylabel('Treatment Failures (100,000''s)');
    xlabel('Model Year');

    legend(cellstr(num2str(rates, '%g')), 'Location', 'NorthWest', 'NumColumns', 2);
    legend boxoff;

    graphic = gca;
    graphic.FontSize = 18;

    hold off;
end