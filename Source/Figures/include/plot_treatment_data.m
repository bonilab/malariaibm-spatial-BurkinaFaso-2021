% Generate plots based upon the summary input files
function [] = plot_treatment_data(directory, startDate)
    files = dir(directory);
    for ndx = 1:length(files)
        % Skip anything that is not the directories we are looking for
        if ~files(ndx).isdir, continue; end
        if strcmp(files(ndx).name(1), '.'), continue; end

        % Plot the national summary and district summary
        filename = fullfile(files(ndx).folder, files(ndx).name);
        [plotTitle, file] = parse_name(files(ndx).name);        
        generate(filename, startDate, plotTitle, file);
    end
end

% Generates a single plot based upon the data files in the supplyed
% subdirectory, saves the plot to disk.
function [] = generate(directory, startDate, plotTitle, file)
    
    hold on;
    replicates = 0;
    files = dir(fullfile(directory, '*treatment*.csv'));
    for ndx = 1:length(files)
        % Load the data, note the unique days
        filename = fullfile(files(ndx).folder, files(ndx).name);
        data = csvread(filename, 1, 0);
        days = transpose(unique(data(:, 2)));
        
        % Allocate the arrays
        clinicalcases = zeros(size(days, 2), 1);
        treatmentfailures = zeros(size(days, 2), 1);
        nontreatment = zeros(size(days, 2), 1);
        
        % Get the data, format the date in the process
        for ndy = 1:length(days)
            treatmentfailures(ndy) = sum(data(data(:, 2) == days(ndy), 6));
            nontreatment(ndy) = sum(data(data(:, 2) == days(ndy), 7));
            days(ndy) = addtodate(datenum(startDate), days(ndy), 'day');
        end
                
        % Plot the data
        yyaxis left;
        plot(days, log10(treatmentfailures), '-');
        yyaxis right;
        plot(days, log10(nontreatment), '.-');
        
        % Update the replicate count
        replicates = replicates + 1;
    end
    hold off;

    % Add labels, title, apply formatting
    datetick('x', 'yyyy');
    xlabel('Model Year');
    yyaxis left;
    ylabel('Treatment Failures (log_{10})');
    yyaxis right;
    ylabel('Non-treatment (log_{10})');    

    % Apply the title
    sgtitle({sprintf('Treatment Failures and Non-treatment %s (%d Replicates)', ...
        plotTitle, length(files))}, 'FontSize', 24);  
    
    graphic = gca;
    graphic.FontSize = 24;
    
    % Save and close
    set(gcf, 'Position',  [0, 0, 2560, 1440]);
    print('-dtiff', '-r300', sprintf('out/%s-treatment-replicates.png', file));
    clf;
    close;    
end