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
            
        case 'bfa-0.0001983'
            name = 'with very slow mutation rate';
            file = 'bfa-0.0001983';
            label = 'Very Slow Mutation';
        case 'bfa-0.0003966'
            name = 'with slow mutation rate';
            file = 'bfa-0.0003966';
            label = 'Slow Mutation';
        case 'bfa-0.009915'
            name = 'with fast mutation rate';
            file = 'bfa-0.009915';
            label = 'Fast Mutation';
        case 'bfa-0.01983'
            name = 'with very slow fast rate';
            file = 'bfa-0.01983';
            label = 'Very Fast Mutation';
        case 'bfa-aldp-0.0001983'
            name = 'with AL/DP MFT (Immediate) and very slow mutation rate';
            file = 'bfa-aldp-0.0001983';
            label = 'AL/DP, Very Slow Mutation';
        case 'bfa-aldp-0.0003966'
            name = 'with AL/DP MFT (Immediate) and slow mutation rate';
            file = 'bfa-aldp-0.0003966';
            label = 'AL/DP, Slow Mutation';
        case 'bfa-aldp-0.009915'
            name = 'with AL/DP MFT (Immediate) and fast mutation rate';
            file = 'bfa-aldp-0.009915';
            label = 'AL/DP, Fast Mutation';
        case 'bfa-aldp-0.01983'
            name = 'with AL/DP MFT (Immediate) and very slow fast rate';
            file = 'bfa-aldp-0.01983';
            label = 'AL/DP, Very Fast Mutation';       
        case 'bfa-rapid-0.0001983'
            name = 'with Private Market Elimination (Immediate) and very slow mutation rate';
            file = 'bfa-rapid-0.0001983';
            label = 'Market, Very Slow Mutation';
        case 'bfa-rapid-0.0003966'
            name = 'with Private Market Elimination (Immediate) and slow mutation rate';
            file = 'bfa-rapid-0.0003966';
            label = 'Market, Slow Mutation';
        case 'bfa-rapid-0.009915'
            name = 'with Private Market Elimination (Immediate) and fast mutation rate';
            file = 'bfa-rapid-0.009915';
            label = 'Market, Fast Mutation';
        case 'bfa-rapid-0.01983'
            name = 'with Private Market Elimination (Immediate) and very slow fast rate';
            file = 'bfa-rapid-0.01983';
            label = 'Market, Very Fast Mutation';               
            
        otherwise
            error("No mapping for prefix %s", prefix);
    end
end

