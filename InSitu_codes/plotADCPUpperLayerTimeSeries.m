%% plotCompHF2ADCP.m
function plotADCPUpperLayerTimeSeries(Vr_ADCP, average_every, Fs)

average_every = average_every*60; % [minutes]
average_every_index = round(average_every * Fs);
% Calculate the number of chunks
numChunks = size(Vr_ADCP, 2) / average_every_index;

% Initialize an array to store the averaged values
averagedValues = zeros(1, numChunks);

% Loop through each chunk and calculate the average
for i = 1:numChunks
    chunkStart = (i - 1) * average_every_index + 1;
    chunkEnd = i * average_every_index;
    averagedValues(i) = mean(Vr_ADCP(end, chunkStart:chunkEnd));
end

% Plot the averaged values
plot(1:numChunks, averagedValues);
xlabel('Chunk Index');
ylabel('Averaged Value');
end

