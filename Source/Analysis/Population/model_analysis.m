% model_analysis.m
%
% Generate plots that allow us to compare how the model performs at scale 
% when working with seasonal and non-seasonal data.
%
% TODO Go through this script and move anything useful over to the support
% TODO repostiory. The plotSimuatedVsReferencePfPR should NOT be used since
% TODO the correct one exists in the supprot repository.
addpath('../Common');
clear;

STARTDATE = '2007-1-1';

% Plot of national change, plus seasonality
%plot_weighted_pfpr(FILENAME, STARTDATE, 5, 'Under 5');
%plot_weighted_pfpr(FILENAME, STARTDATE, 6, '2 to 10');
%plot_weighted_pfpr(FILENAME, STARTDATE, 7, 'All');

% Various comparison points
%plot_district_pfpr(FILENAME, STARTDATE, 4, 'Boulkiemdé', 5, 'Under 5');
%plot_district_pfpr(FILENAME, STARTDATE, 41, 'Soum', 5, 'Under 5');
%plot_district_pfpr(FILENAME, STARTDATE, 44, 'Kossi', 5, 'Under 5');


% Plot the monthly PfPR values
function [] = monthlyPfPR(filename, startDate, single)
    % Load the data and reference data
    data = csvread(filename, 1, 0);
    reference = csvread('../Common/weighted_pfpr.csv');
    dn = prepareDates(filename, 1, startDate);

    % Prepare the color map
    colors = colormap(parula(size(unique(data(:, 2)), 1)));
    
    % Prepare the burn-in marker point
    start = addtodate(datenum(startDate), 4000, 'day');
    
    % Iterate over the zones
    zones = unique(reference(:, 3));
    for zone = transpose(zones)
    
        % Filter and iterate over the districts
        districts = unique(reference(reference(:, 3) == zone, 1));
        if size(zones, 1) > 1 && not(single)
            subplot(size(zones, 1), 1, zone + 1);
        end
        
        % Select the correct plot format
        hold on;
        for district = transpose(districts)
            pfpr = data(data(:, 2) == district, 6);
            scatter(dn, pfpr, 50, colors(district, :), 'Filled');    
        end 
        
        % Add the plot features
        yline(0, '-.');
        xline(start, '-.', 'Model Burn-in', 'LabelVerticalAlignment', 'bottom');
        
        datetick('x', 'yyyy');
        xlim([min(dn) max(dn)])                
        ylabel('PfPR_{2 to 10}');
        xlabel('Model Year');

        % Adjust the title, fonts as needed
        if size(zones, 1) > 1 && not(single)
            title(sprintf('Simulated Monthly PfPr_{2 to 10} Over Time (Zone {%d})', zone));
        else
            title('Simulated Monthly PfPr_{2 to 10} Over Time');
            graphic = gca;
            graphic.FontSize = 18;
        end        

        hold off;
    end
end

% Plot the error in PfPR to the reference data, presuming that transmission
% is perennial.
function [] = perennialError(filename, startDate) 
    % Load the data and reference data
    data = csvread(filename, 1, 0);
    reference = csvread('../Common/weighted_pfpr.csv');
    dn = prepareDates(filename, 1, startDate);

    hold on;
    districts = unique(data(:, 2));
    colors = colormap(parula(size(districts, 1)));
    for district = transpose(districts)
        expected = reference(reference(:, 1) == district, 2);
        pfpr = data(data(:, 2) == district, 6);
        error = ((pfpr - expected) / expected) * 100;
        scatter(dn, error, 50, colors(district, :), 'Filled');    
    end 

    yline(0, '-.');
    start = addtodate(datenum(startDate), 4000, 'day');
    xline(start, '-.', 'Model Burn-in', 'FontSize', 18, 'LabelVerticalAlignment', 'bottom');

    datetick('x', 'yyyy');
    title('Expected PfPr_{2 to 10} versus Simulated');
    ylabel('Percent Error');
    xlabel('Days Elapsed');

    graphic = gca;
    graphic.FontSize = 18;
    hold off;
end

% Plot the error summary in PfPR to the reference data, presuming the
% transmission ie perennial.
function [] = perennialErrorSummary(filename) 
    % Load reference data
    reference = csvread('../Common/weighted_pfpr.csv');
    
    % Load and trim the evaluation data to post-burn-in
    data = csvread(filename, 1, 0);
    data = data(data(:, 1) >= 4000, :);
    districts = unique(data(:, 2));

    hold on;
    for district = transpose(districts)
        expected = reference(reference(:, 1) == district, 2);
        pfpr = data(data(:, 2) == district, 6);
        values = (pfpr - expected) / expected;
        sd = std(values) * 100;
        error = sum(values) / size(values, 1) * 100;
        scatter(error, sd, 'filled');
        name = getLocationName('include/bfa_locations.csv', district);
        text(error + 0.025, sd + 0.0005, name);
    end

    title('Simulated vs. Expected PfPR on a Perennial Basis (Post-Burn-in)');
    xlabel('Mean Percent Error');
    ylabel('Standard Deviation');

    graphic = gca;
    graphic.FontSize = 18;
    hold off;
end

% Generate the simuated versus reference PfPR values, which can be used as
% figure one for a manuscript.
function [] = plotSimuatedVsReferencePfPR(filename)
    CENTER_MIN = 0; CENTER_MAX = 80;

    % Load the reference data
    reference = csvread('../Common/weighted_pfpr.csv');

    % Load and trim the evaluation data to post-burn-in
    data = csvread(filename, 1, 0);
    data = data(data(:, 1) >= (11 * 365), :);
    data = data(data(:, 1) <= (16 * 365), :);
    districts = unique(data(:, 2));
    
    % Prepare the color map
    count = max(reference(:, 2));
    colors = colormap(parula(count));

    % Since the MAP values are the mean, we want to compare against the
    % mean of our data, but highlight the seasonal minima and maxima
    hold on;
    for district = transpose(districts)
        expected = reference(reference(:, 1) == district, 2);
        pfpr = data(data(:, 2) == district, 6); 
        
        % We want the seasonal maxima, filter out the local maxima, once
        % this is done we should only have six points left
        maxima = pfpr(pfpr > mean(pfpr));
        maxima = maxima(maxima > maxima - std(maxima));
        maxima = findpeaks(maxima);
        
        % Repeat the same process for the minima as the maxima
        minima = pfpr(pfpr < mean(pfpr)) .* -1;
        minima = minima(minima > minima - std(minima));
        minima = findpeaks(minima);

        % Plot from the maxima to the minima, connected by a line
        line([expected expected], [mean(maxima) abs(mean(minima))], 'LineStyle', '--', 'LineWidth', 1.5, 'Color', 'black');
        scatter(expected, mean(maxima), 100, [99 99 99] / 255, 'filled', 'MarkerEdgeColor', 'black');
        scatter(expected, mean(pfpr), 100, colors(district, :), 'filled', 'MarkerEdgeColor', 'black');
        scatter(expected, abs(mean(minima)), 75, [99 99 99] / 255, 'filled', 'MarkerEdgeColor', 'black');
    end
    hold off;
    
%     text(18, 15, 'Bazega: 265 per 1000');   % 21
%     text(16, 15, 'All ages incidence: 444 to 527');
%     
%     text(30, 17, 'Houet: 268 per 1000');    % 8
%     text(28, 17, '313 to 449');
%     
%     text(57, 47, 'Soum: 449 per 1000');     % 41
%     text(55, 47, '243 to 353');
    
    
    % Set the limits
    xlim([CENTER_MIN CENTER_MAX]);
    ylim([CENTER_MIN CENTER_MAX]);
    pbaspect([1 1 1]);
    
    % Plot the reference error lines
    data = get(gca, 'YLim');
    line([data(1) data(2)], [data(1)*1.05 data(2)*1.1], 'Color', [0.5 0.5 0.5], 'LineStyle', '-.');
    line([data(1) data(2)], [data(1)*1.05 data(2)*1.05], 'Color', [0.5 0.5 0.5], 'LineStyle', '-.');
    line([data(1) data(2)], [data(1)*0.95 data(2)*0.95], 'Color', [0.5 0.5 0.5], 'LineStyle', '-.');
    text(data(2), data(2) * 0.95, '-5%', 'FontSize', 16);
    line([data(1) data(2)], [data(1)*0.95 data(2)*0.9], 'Color', [0.5 0.5 0.5], 'LineStyle', '-.');
    text(data(2), data(2) * 0.9, '-10%', 'FontSize', 16);
    
    % Plot the reference center line
    line([data(1) data(2)], [data(1) data(2)], 'Color', 'black', 'LineStyle', '-.');
    text(data(2), data(2) + 0.5, '\pm0%', 'FontSize', 16);
        
    ylabel('Simulated {\it Pf}PR_{2 to 10}');
    xlabel('Reference {\it Pf}PR_{2 to 10}');

    title('Burkina Faso, Simuated versus Reference {\it Pf}PR_{2 to 10} values');

    graphic = gca;
    graphic.FontSize = 20;
end

% Plot the PfPR for the district indicated for a five year interval, starting 11 years after the 
% model start date, assumes paramters for Burkina Faso.
function [] = plot_district_pfpr(filename, startDate, province, districtName, pfprIndex, subscript)
    
    % Load and filter five years of data
    data = csvread(filename, 1, 0);
    data = data(data(:, 1) >= (11 * 365), :);
    data = data(data(:, 1) <= (16 * 365), :);
    
    % Filter the district
    data = data(data(:, 2) == province, :);
    
    % Plot
    plot(data(:, 1) + datenum(startDate), data(:, pfprIndex));
    
    % Format
    xlabel('Model Year');
    ylabel(sprintf('PfPR_{%s}', subscript));
    title(sprintf('Five Year PfPR_{%s} for Province of %s, Burkina Faso', subscript, districtName));
    
    datetick('x', 'mmm yyyy');
    axis tight;
        
    graphic = gca;
    graphic.FontSize = 18;    
end

% Plot the population wehighted PfPR for a five year interval, starting 11 years after the 
% model start date, assumes paramters for Burkina Faso.
function [] = plot_weighted_pfpr(filename, startDate, index, subscript)
    data = csvread(filename, 1, 0);
    data = data(data(:, 1) >= (11 * 365), :);
    data = data(data(:, 1) <= (16 * 365), :);
    
    dates = unique(data(:, 1));
    pfpr = zeros(size(dates, 1), 1);

    for ndx = 1:size(dates, 1)
        values = data(data(:, 1) == dates(ndx), :);
        for district = 1:45
            pfpr(ndx) = pfpr(ndx) + (values(district, 3) * values(district, index));
        end
        pfpr(ndx) = pfpr(ndx) / sum(values(:, 3));
    end

    plot(dates + datenum(startDate), pfpr);
    yline(mean(pfpr), '--', sprintf('Mean PfPR_{%s} (%.2f%%)', subscript, mean(pfpr)), 'FontSize', 12);

    xlabel('Model Year');
    ylabel(sprintf('Population Weighted Mean PfPR_{%s}', subscript));
    title(sprintf('National Popuation Weighted Mean PfPr_{%s} for Five Years', subscript));

    datetick('x', 'mmm yyyy');
    axis tight;
    
    graphic = gca;
    graphic.FontSize = 18;
end

% Plot the error summary in PfPR to the refernce data, presuming the
% transmission is seasonal.
function [] = seasonalError(filename, startDate)
    % Load the data and reference data
    data = csvread(filename, 1, 0);
    reference = csvread('../Common/weighted_pfpr.csv');
    dn = prepareDates(filename, 1, startDate);

    % Prepare the color map
    colors = colormap(parula(size(unique(data(:, 2)), 1)));
    
    % Prepare the burn-in marker point
    start = addtodate(datenum(startDate), 4000, 'day');
    
    % Iterate over the zones
    zones = unique(reference(:, 3));
    for zone = transpose(zones)
    
        % Filter and iterate over the districts
        districts = unique(reference(reference(:, 3) == zone, 1));
        subplot(3, 1, zone + 1);
        hold on;
        for district = transpose(districts)
            expected = reference(reference(:, 1) == district, 2);
            pfpr = data(data(:, 2) == district, 6);
            error = pfpr - expected;
            %scatter(dn, error, 50, colors(district, :), 'Filled');    
            plot(dn, error, 50, colors(district, :));    
        end 
        
        % At the plot features
        yline(0, '-.');
        xline(start, '-.', 'Model Burn-in', 'LabelVerticalAlignment', 'bottom');

        datetick('x', 'yyyy');
        xlim([min(dn) max(dn)])
        title(sprintf('Expected PfPr_{2 to 10} versus Simulated (Zone {%d})', zone));
        ylabel('Percent Error Realative to Peak');
        xlabel('Model Year');
        hold off;
    end
end

% Plot the error summary in PfPR to the refernece data, presuming the
% trasnmission is seasonal.
function [] = seasonalErrorSummary(filename)
    % Load reference data
    reference = csvread('../Common/weighted_pfpr.csv');
    
    % Load and trim the evaluation data to post-burn-in
    data = csvread(filename, 1, 0);
    data = data(data(:, 1) >= (11 * 365), :);
    districts = unique(data(:, 2));
            
    hold on;
    for district = transpose(districts)
        expected = reference(reference(:, 1) == district, 2);
        pfpr = data(data(:, 2) == district, 6);
        
        % We want the seasonal maxima, filter out the local maxima, once
        % this is done we should only have ten points left (i.e., number of
        % years)
        peaks = pfpr(pfpr > mean(pfpr));
        peaks = peaks(peaks > peaks - std(peaks));
        peaks = findpeaks(peaks);
        
        % Find the real error and SD
        error = peaks - expected;
        sd = std(error);
        mre = sum(error) / size(error, 1);
        scatter(mre, sd, 45, 'filled');
        name = getLocationName(district);
        text(mre + 0.02, sd + 0.01, name, 'FontSize', 18);
    end
            
    title('Simulated vs. Expected {\it Pf}PR_{2 to 10} on a Seasonal Basis (Post Burn-in)', 'FontSize', 28);
    xlabel('Mean Difference in Peak {\it Pf}Pr_{2 to 10} Relative to Reference Value');
    ylabel('Standard Deviation for Ten Years');
    
    graphic = gca;
    graphic.FontSize = 24;
    hold off;
end

% Plot the population of individuals in the model from the start date.
function [] = plotPopulation(filename, startDate)
    
    % Extract the relevent data
    data = csvread(filename, 1, 0);
    dayselapsed = unique(data(:, 1));
    population = [];
    for day = transpose(dayselapsed)
        population = [population, sum(data(data(:, 1) == day, 3))];
    end

    % Scale the raw back to full population
    population = population ./ 0.25;

    % Round off to millions
    population = population ./ 1000000;

    % Generate the population plot
    dn = prepareDates(filename, 1, startDate);
    plot(dn, population);
    
    % Format the plot
    datetick('x', 'yyyy');
    title('Growth of Simulated Population');
    ylabel('Population (millions)');
    xlabel('Days Elapsed');
    graphic = gca;
    graphic.FontSize = 18;    
end
