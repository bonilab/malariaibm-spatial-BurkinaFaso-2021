% parse_name.m
%
% Generate the name (title) and filename to use based upon the input filename 
function [name, file, label] = parse_name(file)
    prefix = strrep(file, '-frequency-map.csv', '');
    switch prefix
        case 'bfa-fast-no-asaq'
            name = 'with fast muation rate (no ASAQ)';
            file = 'de-novo-fast-no-asaq';
            label = 'Fast, no ASAQ';
        case 'bfa-slow-no-asaq'
            name = 'with slow muation rate (no ASAQ)';
            file = 'de-novo-slow-no-asaq';
            label = 'Slow, no ASAQ';
            

        case 'bfa-rapid'
            name = 'with Private Market Elimination (Immediate)';
            file = 'rapid';
            label = 'Market';
        case 'bfa-tenyear'
            name = 'with Private Market Elimination (10 years)';
            file = 'ten';            
            label = 'Market, 10y';
        case 'bfa-aldp'
            name = 'with AL/DP MFT (Immediate)';
            file = 'aldp';
            label = 'AL/DP';
        case 'bfa-aldp10'
            name = 'with AL/DP MFT (10 years)';
            file = 'aldp10';
            label = 'AL/DP, 10 y';
        case 'bfa-aldp-tenyear'
            name = 'with AL/DP MFT (Immediate), Private Market Elimiation (10 years)';
            file = 'aldp-tenyear';
            label = 'AL/DP; Market, 10y';        
        case 'bfa-aldp-rapid'
            name = 'with AL/DP MFT (Immediate), Private Market Elimiation (Immediate)';
            file = 'aldp-rapid';       
            label = 'AL/DP; Market';
        case 'bfa-aldp10-rapid'
            name = 'with AL/DP MFT (10 years), Private Market Elimiation (Immediate)';
            file = 'aldp10-rapid';       
            label = 'AL/DP, 10y; Market';            
        case 'bfa-aldp10-tenyear'
            name = 'with AL/DP MFT (10 years), Private Market Elimiation (10 year)';
            file = 'aldp10-tenyear';       
            label = 'AL/DP, 10y; Market, 10y';

        case 'bfa-al-only'
            name = 'with AL only';
            file = 'bfa-al-only';
            label = 'AL only';            
            
        case 'bfa-90-al-10-dp'
            name = 'with AL/DP MFT (90% AL)';
            file = 'bfa-90-al-10-dp';
            label = 'AL/DP MFT (90% AL)';            
        case 'bfa-80-al-20-dp'
            name = 'with AL/DP MFT (80% AL)';
            file = 'bfa-80-al-20-dp';
            label = 'AL/DP MFT (80% AL)';       
        case 'bfa-70-al-30-dp'
            name = 'with AL/DP MFT (70% AL)';
            file = 'bfa-70-al-30-dp';
            label = 'AL/DP MFT (70% AL)';               
        case 'bfa-60-al-40-dp'
            name = 'with AL/DP MFT (60% AL)';
            file = 'bfa-60-al-40-dp';
            label = 'AL/DP MFT (60% AL)';
            
        otherwise
            error("No mapping for prefix %s", prefix);
    end
end

