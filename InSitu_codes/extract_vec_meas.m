%% extracting basic measurements

load('C:\Giora\TAU\MEPlab\HF_Radar\files\vector\vector_measurement.mat');
v = vector_vel_pres(:, 1:3);

v(:, 1) = v(:, 1) + 0.20585;
v(:, 2) = v(:, 2) + 0.18801;

P = vector_vel_pres(:, 4);
VV = sqrt(v(:, 1).^2 + v(:, 2).^2);
figure(); plot(VV);
fs = 8;
dt = 1 / fs;
t_end = length(P) * dt;

t = linspace(0, t_end, length(P));
figure(); plot(t./60, VV);
xlabel('time after 8 AM UTC [minutes]');
ylabel('|V| [m/s]');
id1 = 63232;
id2 = 89552;
%id1 = 63220;
%id2 = 89549;

v_cut = v(id1:id2, :);
P_cut = P(id1:id2);
t_cut = t(id1:id2);

plot(t_cut, P_cut);

V_abs = sqrt(v_cut(:, 1).^2 + v_cut(:, 2).^2);
figure(); plot(t_cut./60, V_abs);
xlabel('time after 8 AM UTC [minutes]');
ylabel('|V| [m/s]');

r_hat = 300;  % azimuth of the radial with respect to the north
alpha_u = r_hat - 270;
alpha_v = r_hat - 240;

Vr = v_cut(:, 1) .* cos(deg2rad(alpha_u)) - v_cut(:, 2) .* cos(deg2rad(alpha_v));
Vtheta = v_cut(:, 1) .* sin(deg2rad(alpha_u)) + v_cut(:, 2) .* sin(deg2rad(alpha_v));

%% histograms

bins = -2 : 0.05 : 2;
figure(); X_u = histogram(v_cut(:, 1), bins);
xlabel('u [m/s]'); ylabel('Counts');

figure(); X_v = histogram(v_cut(:, 2), bins);
xlabel('v [m/s]'); ylabel('Counts');

%% averaging

val_to_avg = v_cut(:, 2);
average_every = 1; % [minutes]
N_cells = round(average_every * 60 / dt);
dT = fix(length(val_to_avg)/N_cells);
val_avg = zeros(dT + 1, 1);
counter = 1;
for ii = 1 : N_cells : length(val_to_avg)-N_cells
    
    val_avg(counter) = mean(val_to_avg(ii:ii+N_cells));
    counter = counter + 1;
    
end

val_avg(end) = mean(val_to_avg(ii+N_cells:end));
figure(); plot(val_avg);
xlabel('time [min]'); ylabel('v [m/s]');

%% cocky averaging

% Create sample data
PulseRateF = v_cut(:, 2);
average_every = 1; % [minutes]
N_cells = round(average_every * 60 / dt);
% Define the block parameter.  Average in a 100 row by 1 column wide window.
blockSize = [N_cells, 1];
% Block process the image to replace every element in the 
% 100 element wide block by the mean of the pixels in the block.
% First, define the averaging function for use by blockproc().
meanFilterFunction = @(theBlockStructure) mean(theBlockStructure.data(:));
% Now do the actual averaging (block average down to smaller size array).
blockAveragedDownSignal = blockproc(PulseRateF, blockSize, meanFilterFunction);
% Let's check the output size.
[rows, columns] = size(blockAveragedDownSignal);
%figure(); plot(blockAveragedDownSignal);
hold on; plot(blockAveragedDownSignal);
xlabel('time [min]'); ylabel('v [m/s]');