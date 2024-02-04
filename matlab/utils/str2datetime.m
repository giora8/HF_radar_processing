function datetime_arr = str2datetime(datetime_str)
%STR2DATETIME Summary of this function goes here
%   Detailed explanation goes here

for ii =1 : length(datetime_str)
    try
        datetime_obj = datetime(datetime_str(ii), 'InputFormat', 'dd-MMM-yyyy HH:mm:ss');
    catch
        datetime_obj = datetime(datetime_str(ii), 'InputFormat', 'dd-MMM-yyyy');
    end
    datetime_arr(ii) = datetime_obj;
end

end

