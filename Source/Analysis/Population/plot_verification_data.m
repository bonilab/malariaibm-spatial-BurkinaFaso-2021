
addpath('../Common');
clear;

data = csvread('data/120342-verification-data.csv', 1, 0);
data = data(data(:, 1) > (11 * 365), :);
data = data(data(:, 1) < (12 * 365), :);

labels = {};

hold on;
for district = transpose(unique(data(:, 2)))
    pfpr = mean(data(data(:, 2) == district, 6));
    labels{end + 1} = sprintf("%s (%d), %.2f%%", getLocationName(district), district, pfpr);
    plot(data(data(:, 2) == district, 1) + datenum('2007-01-01'), data(data(:, 2) == district, 6));
end

datetick('x', 'yyyy-mm-dd');

legend(labels, 'Location', 'NorthWest');
legend boxoff;

axis tight;