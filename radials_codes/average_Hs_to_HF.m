function avg_Hs = average_Hs_to_HF(Hs, time)
    
    datetimeValues = datetime(time, 'ConvertFrom', 'posixtime');
    
    startTime = datetime('2021-03-23 00:00:00', 'Format', 'yyyy-MM-dd HH:mm:ss');
    endTime = datetime('2021-04-15 00:00:00', 'Format', 'yyyy-MM-dd HH:mm:ss');
    hourlyInterval = hours(1); % 1 hour in MATLAB datetime units
 
    mask = (datetimeValues >= startTime) & (datetimeValues <= endTime);
    minutesOfData = minute(datetimeValues);
    filteredMaskMinutes = ~(minutesOfData > 0 & minutesOfData <= 12);
    filtered_datetime = datetimeValues(mask & filteredMaskMinutes);
    
    avg_Hs = Hs(mask & filteredMaskMinutes);
    
    binIndices = floor(seconds(filtered_datetime - startTime) / (3600)) + 1;
    
    avg_Hs = accumarray(binIndices, avg_Hs, [], @mean);
    
end