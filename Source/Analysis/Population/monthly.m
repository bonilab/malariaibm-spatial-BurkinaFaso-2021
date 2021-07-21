
addpath('../Common');
clear;

startdate = '2007-1-1';

data = csvread('data/12-month.csv', 1, 0);

ndx = 1;
districts = unique(data(:, 2));
for district = transpose(districts)
    subplot(1, 3, ndx);
    
    peak = data(data(:, 2) == district, 5);
    plot(data(data(:, 2) == district, 1) +  datenum(startdate), data(data(:, 2) == district, 5) / peak);
    
    title(getLocationName(district));
    datetick('x', 'mmm');
    axis tight;
    
    ndx = ndx + 1;    
end

sgtitle('Burkina Faso / Seasonal Variance in Reported Cases');