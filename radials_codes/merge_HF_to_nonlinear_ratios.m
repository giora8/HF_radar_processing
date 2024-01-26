function [R_back_final, R_on_final] = merge_HF_to_nonlinear_ratios(wavedata)
    
    datetimeValues = datetime(wavedata.WaveData.time, 'ConvertFrom', 'posixtime');
    r_backwards = wavedata.WaveData.RatiosBackward;
    r_onwards = wavedata.WaveData.RatiosOnward;
    
    startTime = datetime('2021-03-23 00:00:00', 'Format', 'yyyy-MM-dd HH:mm:ss');
    endTime = datetime('2021-04-15 00:00:00', 'Format', 'yyyy-MM-dd HH:mm:ss');
    hourlyInterval = hours(1); % 1 hour in MATLAB datetime units
 
    mask = (datetimeValues >= startTime) & (datetimeValues <= endTime);
    minutesOfData = minute(datetimeValues);
    filteredMaskMinutes = ~(minutesOfData > 0 & minutesOfData <= 12);
    filtered_datetime = datetimeValues(mask & filteredMaskMinutes);
    
    R_back = r_backwards(mask & filteredMaskMinutes);
    R_on = r_onwards(mask & filteredMaskMinutes);
    
    binIndices = floor(seconds(filtered_datetime - startTime) / (3600)) + 1;
    
    R_back_final = accumarray(binIndices, R_back, [], @mean);
    R_on_final = accumarray(binIndices, R_on, [], @mean);
    
end

