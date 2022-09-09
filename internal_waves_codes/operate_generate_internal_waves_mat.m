addpath(genpath('..\'));

Synology_path = 'Z:';

ST = 'is1';
cell_size = 512;
step_size = 512;
range = 50;
distance = 40;
angles = 2;
day = '2021102';
hhmm_start = char('0000');
hhmm_end = char('0140');

[neg_mat, zero_mat, pos_mat, sig_neg_mat, sig_zero_mat, sig_pos_mat,...
    acc_neg_mat, acc_zero_mat, acc_pos_mat, Rs, t, alphas, F]...
    = generate_internal_wave_mat(Synology_path, distance, angles, cell_size, step_size,...
    range, 'is1', day, hhmm_start, hhmm_end);

fname = strcat(Synology_path, '\internal_waves\internal_waves_matrices\', ST,...
    '_cell_',num2str(cell_size),'_step_', num2str(step_size),...
    '_distance_',num2str(distance), '_ang_', num2str(angles),'_day_',...
    day, '_from_', hhmm_start, '_to_', hhmm_end, '.mat');
save(fname, 'neg_mat', 'zero_mat', 'pos_mat', 'sig_neg_mat',...
    'sig_zero_mat', 'sig_pos_mat', 'Rs', 't', 'alphas', 'F');
