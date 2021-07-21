% rainy_season.m
%
% This file contains settings and plots that can be used to fit the
% seasonality for a given location. The seasonality works off the equation:
%   
%   multiplier = base + (a * sin^+(b * pi * (phi - t) / 365))
%
% where base is the minimum multiplier to apply.
clear;

hold on;

% Reference settings for no seasonality adjustment (i.e., persistant)
% [flat, flat_rain] = seasonality(1, 0, 1, 0);
% plot(1:365, flat);

[short, short_rain] = seasonality(0.1, -0.9, 2.5, 146);
item(1) = plot(1:365, short);

[long, long_rain] = seasonality(0.1, -0.9, 2.3, 155);
item(2) = plot(1:365, long);

%plot(1:365, short_rain);
%plot(1:365, long_rain);

xline(220, '-.', 'Midpoint Short Rainy Season', 'FontSize', 18);
xline(235, '-.', 'Midpoint Long Rainy Season', 'FontSize', 18);

xline(166, '-.', 'Approximate Start of Rainy Season', 'FontSize', 18);
xline(274, '-.', 'Approximate End of Short Rainy Season', 'FontSize', 18);
xline(305, '-.', 'Approximate End of Long Rainy Season', 'FontSize', 18);

title('Seasonality of Malaira in Burkina Faso', 'fontsize', 32);
legend(item, 'Short Seasonality', 'Long Seasonality', 'FontSize', 18, 'Location','northwest');
legend('boxoff')

xlabel('Month', 'fontsize', 24);
ylabel('Beta Multiplier', 'fontsize', 24);
datetick('x', 'mmm');

plot = gca;
plot.FontSize = 18;

function [multiplier, rainy] = seasonality(base, a, b, phi)
    t = 1:365;
    multiplier = a * sin(b * pi * (phi - t) / 365);
    multiplier(multiplier < 0) = 0;
    multiplier = base + multiplier;
    rainy = (multiplier > base);
end