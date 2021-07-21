clear;

% Get the common data for the functions
global raw districts scales;
raw = csvread('data/population-scaling.csv', 1, 0);
districts = sort(transpose(unique(raw(:, 4))));
scales = sort(transpose(unique(raw(:, 1))));    

%scales = 0.25;

%plotError();
plotScaling();

function [] = plotError() 
    % Ganzourgou - Oubritenga - Sanmatenga
    reference = [ 15 31.06; 17 19.03; 25 32.93 ];

    global raw districts scales;
    colors = colormap(jet(size(scales, 2)));
    index = 1;

    hold on;
    for scale = scales
        variance = [];
        error = [];

        % Prepare the data set, discard everything before 4000 days
        data = raw(raw(:, 1) == scale, :);
        data = data(data(:, 3) > 4000, :);
        
        for district = districts
            expected = reference(reference(:, 1) == district, 2);
            values = (data(data(:, 4) == district, 7) - expected) / expected;
            variance(end + 1) = 100 * var(values);
            error(end + 1) = 100 * (sum(values) / size(values, 1));
        end

        if scale == 0.25
            scatter(error, variance, 50, colors(index, :), 'Filled');    
        else
            scatter(error, variance, 50, colors(index, :));
        end
        index = index + 1;
    end

    addLegend(scales, colors, 0, 0.25);
    title('Population Scaling versus Expected Values');
    xlabel('Mean Percent Error');
    ylabel('Variance');

    graphic = gca;
    graphic.FontSize = 18;

    hold off;
end

function [] = plotScaling()
    global raw districts scales;
    
    colors = colormap(jet(size(scales, 2)));

    hold on;
    index = 1;
    values = {};

    for scale = scales
        data = raw(raw(:, 1) == scale, :);
        for district = districts
            timestep = data(data(:, 4) == district, 3);
            eir = data(data(:, 4) == district, 5);
            pfpr = data(data(:, 4) == district, 7);

            plot(timestep, pfpr, 'Color', colors(index, :));
        end
        index = index + 1; 
    end

    xline(4000, '-.', 'Model Burn-in', 'FontSize', 18, 'LabelVerticalAlignment', 'middle');

    addReference();
    addLegend(scales, colors, 1, -1);

    title('Population Scaling versus Expected PfPr_{2-10}');
    xlabel('Model Timestep (days)');
    ylabel('PfPr_{2-10} (Weighted Mean)');

    graphic = gca;
    graphic.FontSize = 18;

    hold off;
end
    
function [] = addReference()
    % Ganzourgou
    %yline(30.9121 + 3.8835, '-.b', '', 'Color', 'black');
    yline(31.06, '--', 'Ganzourgou (31.06%)', 'Color', 'black', 'FontSize', 18, 'LabelHorizontalAlignment', 'right', 'LabelVerticalAlignment', 'bottom');
    %yline(30.9121 - 3.8835, '-.b', '', 'Color', 'black');

    % Oubritenga
    %yline(19.9553 + 3.3406, '-.b', '', 'Color', 'black');
    yline(19.03, '--', 'Oubritenga (19.03%)', 'Color', 'black', 'FontSize', 18, 'LabelHorizontalAlignment', 'right', 'LabelVerticalAlignment', 'bottom');
    %yline(19.9553 - 3.3406, '-.b', '', 'Color', 'black');

    % Sanmatenga
    %yline(36.6661 + 11.9618, '-.b', '', 'Color', 'black');
    yline(32.93, '--', 'Sanmatenga (32.93%)', 'Color', 'black', 'FontSize', 18, 'LabelHorizontalAlignment', 'right');
    %yline(36.6661 - 11.9618, '-.b', '', 'Color', 'black');
end

% Create a custom legend
function [] = addLegend(labels, colors, bottom, diff)
    h = zeros(1, 1);
    index = 1;
    for label = labels
        if diff == label
            h(index) = scatter(NaN, NaN, [], colors(index, :), 'filled');
        else 
            h(index) = scatter(NaN, NaN, [], colors(index, :));
        end
        index = index + 1;
    end
    
    if bottom
        legend(h, cellstr(num2str(labels')), 'Orientation', 'horizontal', 'Location', 'south');
    else
        hleg = legend(h, cellstr(num2str(labels')));
        htitle = get(hleg, 'Title');
        set(htitle, 'String','Scaling Factor');
    end
    legend boxoff;
end