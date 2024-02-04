function datetime_arr = HFtimestamp2datetime(yyyydddhhmm_mat)
%HFTIMESTAMP2DATETIME Summary of this function goes here
%   Detailed explanation goes here
for ii =1 : length(yyyydddhhmm_mat)

    cur_date = char(yyyydddhhmm_mat(ii));
    cur_year = str2double(cur_date(1:4));
    cur_day = str2double(cur_date(5:7));
    cur_hour = str2double(cur_date(8:9));
    cur_min = str2double(cur_date(10:11));

    cur_datetimeObj = datetime(cur_year, 1, 1) + days(cur_day - 1) + hours(cur_hour) + minutes(cur_min);
    datetime_arr(ii) = cur_datetimeObj;
end

end

