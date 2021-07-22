% plot_pfpr_heatmap.m
%
% This function generates heatmaps at the national level for a single year 
% based upon the supplied imput file.

% Main entry point for the function, reads the supplied file, and generates
%the heatmaps
function plot_pfpr_heatmap(filename, startDate)

    % Load the data and generate the heatmaps
    raw = csvread(filename, 1, 0);
    index = 1;
    for day = transpose(unique(raw(:, 1)))
        subplot(3, 4, index);
        generate(raw, day, startDate);
        index = index + 1;
    end

    % Set the title
    sgtitle("Projected {\it Pf}PR_{2 to 10} in 2030", 'FontSize', 24);
    
    % Save the file
    set(gcf, 'Position',  [0, 0, 2560, 1440]);
    print('-dtiff', '-r300', 'out/pfpr-heatmap.tiff');
    clf;
    close;
end

function generate(raw, date, startDate)
    ROW = 3; COL = 4; DATA = 5;

    % Prepare the data structure
    rows = max(raw(:, ROW) + 1);
    cols = max(raw(:, COL) + 1);
    map = NaN(rows, cols);
    
    % Load the data on to the map structure
    data = raw(raw(:, 1) == date, :);
    for values = transpose(data)
        row = values(ROW) + 1;
        col = values(COL) + 1;
        map(row, col) = values(DATA); 
    end
    
    % Covert the data, prepare the title
    days = addtodate(datenum(startDate), date, 'day');
    title = datestr(datetime(days, 'ConvertFrom', 'datenum'), 'mmmm');

    % Plot the heatmap and color bar
    hm = heatmap(map, 'MissingDataColor', [1.0 1.0 1.0]);
    hm.Colormap = colormap(flipud(autumn));
    caxis(hm, [min(raw(:, DATA)) max(raw(:, DATA))]);
        
    % Apply the remainder of the formatting
    graphic = gca;
    graphic.FontSize = 18;    
    hm.Title = title;
    hm.XDisplayLabels = repmat(' ', cols, 1); 
    hm.YDisplayLabels = repmat(' ', rows, 1);
    grid off;
end