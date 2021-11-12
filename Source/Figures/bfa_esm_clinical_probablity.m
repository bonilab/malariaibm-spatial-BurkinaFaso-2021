% bfa_esm_clinical_probablity.m
%
% Plot the range of Z values that adjust the clinical probablity of of
% symptoms.
clear;

% Fixed variables
p_min = 0.005;
p_max = 0.99;
z = 4.5;

% Bounds of immunity
M = 0:0.01:1;

% Midpoint values
midpoint = 0.1:0.05:1.0;

% Prepare variable connected to Z range
labels = cell(1, size(midpoint, 2));
color = winter(size(midpoint, 2));

% Plot all off the Z-value curves, note the legends
hold on;
ndx = 1;
for mid = midpoint
    p_clinical = (p_max  ./ (1 + (M / mid) .^ z)) ;
            
    if abs(mid - 0.1500) < eps(0.5)
        plot(M, p_clinical, 'color', color(ndx,:), 'linewidth', 5.0);     
        labels{1 ,ndx} = sprintf('{\\bf %0.2f}', mid);
    else
        plot(M, p_clinical, 'color', color(ndx,:), 'linewidth', 1.0);     
        labels{1 ,ndx} = sprintf('%0.2f', mid);
    end           
    
    ndx = ndx + 1;
end 

xlabel('Immunity Level');
ylabel('Probability of Developing Symptoms');
title('Change in Probablity of Developing Symtoms as Midpoint Changes');
legend(labels);
legend boxoff;

graphic = gca;
graphic.FontSize = 20;

set(gcf, 'Position', get(0, 'Screensize'));
