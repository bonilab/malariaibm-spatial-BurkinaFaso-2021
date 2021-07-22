% plot_treatment_failures.m
%
% Plot the treatment failures from the model.

function [] = plot_treatment_failures(directory, startDate)

    % Prepare a color map to use by counting the number of directories
    % NOTE this seems to allocate 2x as many as are needed for some reason
    folders = dir(directory);
    folders(ismember( {folders.name}, {'.', '..'})) = [];

    % Prepare a color map
    colors = colormap(lines(size(folders, 1) / 2));
    ci = 1;    

    % Append the files to the plot
    topLabel = {}; bottomLabel = {};
    topColor = []; bottomColor = [];
    files = dir(directory);
    for ndx = 1:length(files)
        % Skip anything that is not the directories we are looking for
        if ~files(ndx).isdir, continue; end
        if strcmp(files(ndx).name(1), '.'), continue; end
                        
        % Prepare to append to the plot
        filename = fullfile(files(ndx).folder, files(ndx).name);
        label = strrep(parse_name(files(ndx).name), 'with ', '');
        if startsWith(label, '0.0')
            location = 1;
            topLabel = [topLabel label];
            topColor = [topColor; colors(ci, :)];
        else
            location = 2;
            bottomLabel = [bottomLabel, label];
            bottomColor = [bottomColor; colors(ci, :)];
        end
        
        % Update the plot
        subplot(2, 1, location); hold on;
        append_plots(filename, colors(ci, :));
        ci = ci + 1;
    end
        
    % Format the plots
    subplot(2, 1, 1);
    format_legend(topLabel, topColor);
    format_plot('Comparison of Muation Rates', startDate);
    subplot(2, 1, 2);
    format_legend(bottomLabel, bottomColor);
    format_plot('Comparison of Possible Interventions', startDate);
    
    % Save and close
    set(gcf, 'Position',  [0, 0, 2560, 1440]);
    print('-dtiff', '-r300', 'out/treatment-failures.png');
    clf;
    close;    
end


function [] = append_plots(directory, color)
    files = dir(fullfile(directory, '*treatment*.csv'));
    for ndx = 1:length(files)
        % Load the data, note the unique days
        filename = fullfile(files(ndx).folder, files(ndx).name);
        data = csvread(filename, 1, 0);
        data = data(data(:, 2) > 13 * 365, :);
        
        % Total each day
        days = transpose(unique(data(:, 2)));
        total = zeros(size(days, 1)); index = 1;
        for day = days
            total(index) = sum(data(data(:, 2) == day, 6)) / sum(data(data(:, 2) == day, 5));
            index = index + 1;
        end
        
        % Append the plot
        plot(days, total, 'Color', color);
    end
end


function [] = format_legend(labels, colors)
    % Add and format the legend
    item = zeros(1, 1);
    index = 1;
    for label = labels
        item(index) = scatter(NaN, NaN, [], colors(index, :), 'filled');
        index = index + 1;
    end
	legend(item, labels, 'Location', 'NorthWest', 'FontSize', 16);
    legend boxoff;
end


function [] = format_plot(plotTitle, startDate)    
    % Format the rest of the plot
    title(plotTitle);
    ylabel('Treatment Failure Rate');    
    xlabel('Model Year');
    axis tight;
    
    % Format the dates based upon the xaxis and ticks, this code might
    % break if the bounds change
    labels = [];
    for tick = xticks()
        tick = addtodate(datenum(startDate), tick, 'day');
        labels = [labels str2num(datestr(tick, 'yyyy'))];
    end
    set(gca, 'XTick', xticks(), 'XTickLabel', labels)
        
    % Set the font sizes
    graphic = gca;
    graphic.FontSize = 24;
end