% plot_frequency_treatmentfailures.m
% 
% Plot the 580Y and plasmepsim double copy frequency versus the treatment
% failures at a national level.

% Generate plots based upon the summary input files
function [] = plot_frequency_treatmentfailures(directory, startDate)
    files = dir(directory);
    for ndx = 1:length(files)
        % Skip anything that is not the directories we are looking for
        if ~files(ndx).isdir, continue; end
        if strcmp(files(ndx).name(1), '.'), continue; end

        % Plot the frequency and treatment failures
        filename = fullfile(files(ndx).folder, files(ndx).name);
        [plotTitle, file] = parse_name(files(ndx).name);        
        generate(filename, startDate, plotTitle, file);
    end
end

% Iterate over the replicates in the directory, generate, and save the plot.
function [] = generate(directory, startDate, plotTitle, file)

    % Add all of the replicates in the directory to the plot
    hold on;
    files = dir(fullfile(directory, '*genotype-frequencies.csv'));
    for ndx = 1:length(files)
        frequencyFile = fullfile(files(ndx).folder, files(ndx).name);
        summaryFile = strrep(frequencyFile, '-genotype-frequencies', '-treatment-summary');
        addReplicate(frequencyFile, summaryFile, startDate);
    end
    hold off;
    
    % Finalize the formatting of the plot
    yyaxis left;
    ylabel('Genotype Frequency');
    yyaxis right;
    ylabel('Treatment Failures (log_{10})');
    datetick('x', 'yyyy');
    xlabel('Model Year');
    title(sprintf('Frequency and Treatment Failures, %s (%d Replicates)', plotTitle, length(files)));

    legend({'Plasmepsin 2-3 2 Copy Frequency', '580Y Frequency', 'TNF---- Frequency', 'KNF---- Frequency', 'Treatment Failures'}, 'Location', 'NorthWest');
    legend('boxoff');

    graphic = gca;
    graphic.YAxis(1).Color = 'black';
    graphic.YAxis(2).Color = 'black';
    graphic.FontSize = 16;
    
    % Save and close
    set(gcf, 'Position',  [0, 0, 2560, 1440]);
    print('-dtiff', '-r300', sprintf('out/%s-frequency-treatment.png', file));
    clf;
    close; 
end

% Add the singel replicate to the current plot
function [] = addReplicate(frequencyFile, summaryFile, startDate)
    % Load the data files
    frequencyTable = readtable(frequencyFile, 'PreserveVariableNames', true);
    dates = table2array(unique(frequencyTable(:, 2)));
    genotypes = table2array(unique(frequencyTable(:, 4)));
    summaryTable = readtable(summaryFile, 'PreserveVariableNames', true);
    
    % Parse out the genotypes that we are looking for
    plasmespin = genotypes(~cellfun('isempty', regexp(genotypes, '......2', 'match')));
    c580y = genotypes(~cellfun('isempty', regexp(genotypes, '.....Y.', 'match')));
    KNF = genotypes(~cellfun('isempty', regexp(genotypes, 'KNF....', 'match')));
    TNF = genotypes(~cellfun('isempty', regexp(genotypes, 'TNF....', 'match')));
    
    % Prepare the data sets
    frequencyPlasmespin = zeros(size(dates, 1), 1);
    frequency580Y = zeros(size(dates, 1), 1);
    frequencyTNF = zeros(size(dates, 1), 1);
    frequencyKNF = zeros(size(dates, 1), 1);
    failures = zeros(size(dates, 1), 1);    
    
    % Extract all of the freqeuncy data
    for date = 1:size(dates)
        failures(date) = sum(summaryTable(summaryTable.days == dates(date), :).treatmentfailures);
        filtered = frequencyTable(frequencyTable.days == dates(date), :);
        for genotype = 1:size(plasmespin)
            frequency = filtered(string(filtered.name) == plasmespin(genotype), :);
            if ~isempty(frequency)
                frequencyPlasmespin(date) = frequencyPlasmespin(date) + frequency.frequency;
            end
        end
        for genotype = 1:size(c580y)
            frequency = filtered(string(filtered.name) == c580y(genotype), :);
            if ~isempty(frequency)
                frequency580Y(date) = frequency580Y(date) + frequency.frequency;
            end
        end     
        for genotype = 1:size(TNF)
            frequency = filtered(string(filtered.name) == TNF(genotype), :);
            if ~isempty(frequency)
                frequencyTNF(date) = frequencyTNF(date) + frequency.frequency;
            end
        end    
        for genotype = 1:size(KNF)
            frequency = filtered(string(filtered.name) == KNF(genotype), :);
            if ~isempty(frequency)
                frequencyKNF(date) = frequencyKNF(date) + frequency.frequency;
            end
        end          
        dates(date) = addtodate(datenum(startDate), dates(date), 'day');
    end    
    
    % Add the replicate to the plot
    yyaxis left;
    plot(dates, frequencyPlasmespin, 'Color', 'blue', 'LineStyle', '-', 'Marker', 'none');
    plot(dates, frequency580Y, 'Color', 'red', 'LineStyle', '-', 'Marker', 'none');
    plot(dates, frequencyTNF, 'Color', 'green', 'LineStyle', '--', 'Marker', 'none');
    plot(dates, frequencyKNF, 'Color', 'green', 'LineStyle', '-', 'Marker', 'none');
    yyaxis right;
    plot(dates, log10(failures), 'Color', 'black', 'LineStyle', '-', 'Marker', 'none');    
end