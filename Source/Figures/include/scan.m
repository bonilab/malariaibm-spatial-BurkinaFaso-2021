% scan.m
% 
% Scan the path provided for data files and call the reporting function
% when they are found. This script is intended to be used with the IRQ 
% reporting and box plot generation. 
function [data, labels] = scan(path, report_function)
    files = dir(path);
    data = {}; labels = {};
    for ndx = 1:length(files)
        if ~files(ndx).isdir, continue; end
        if strcmp(files(ndx).name(1), '.'), continue; end
        values = report_function(fullfile(files(ndx).folder, files(ndx).name), files(ndx).name);
        [~, ~, label] = parse_name(files(ndx).name);
        labels{end + 1} = label;
        data{end + 1} = values;
    end
end