function avg_map = adcp_averagor(config, input_map)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
avg_map = containers.Map;
t_matlab = input_map('matlab_time');
dt_sec = (t_matlab(2) - t_matlab(1)) * 24 * 60 * 60;
Fs = 1 / dt_sec;
average_every = config.ADCP.period.average_time_minutes;
average_every_index = round(average_every * Fs);
% Calculate the number of chunks
numChunks = length(t_matlab) / average_every_index;
keys = input_map.keys();
for ii = 1 : length(keys)
    key_measurements = input_map(keys{ii});
    % Initialize an array to store the averaged values
    avg_target = zeros(size(key_measurements, 1), numChunks);
    % Loop through each chunk and calculate the average
    for i = 1:numChunks
        chunkStart = (i - 1) * average_every_index + 1;
        chunkEnd = i * average_every_index;
        avg_target(:, i) = mean(key_measurements(:, chunkStart:chunkEnd), 2);
    end
    avg_map(keys{ii}) = avg_target;
end