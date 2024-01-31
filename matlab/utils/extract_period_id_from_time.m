function [idx_min, idx_max] = extract_period_id_from_time(matlab_time, timestamp_min, timestamp_max)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

[~, idx_min] = min(abs(matlab_time - timestamp_min));
[~, idx_max] = min(abs(matlab_time - timestamp_max));


end