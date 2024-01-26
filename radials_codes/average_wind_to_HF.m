function avg_wind = average_wind_to_HF(wind_data_path)
    load(wind_data_path)
    datetimeValues = datetime(time'+7200, 'ConvertFrom', 'posixtime');
    
    startTime = datetime('2021-03-23 00:00:00', 'Format', 'yyyy-MM-dd HH:mm:ss');
    endTime = datetime('2021-04-15 00:00:00', 'Format', 'yyyy-MM-dd HH:mm:ss');
    hourlyInterval = hours(1); % 1 hour in MATLAB datetime units
 
    mask = (datetimeValues >= startTime) & (datetimeValues <= endTime);
    minutesOfData = minute(datetimeValues);
    filteredMaskMinutes = ~(minutesOfData > 0 & minutesOfData <= 12);
    filtered_datetime = datetimeValues(mask & filteredMaskMinutes);
    
    avg_wind = Vr_wind(mask & filteredMaskMinutes);
    
    binIndices = floor(seconds(filtered_datetime - startTime) / (3600)) + 1;
    
    avg_wind = accumarray(binIndices, avg_wind, [], @mean);
    
end