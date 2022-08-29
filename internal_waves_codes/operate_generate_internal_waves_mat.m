addpath(genpath('..\'));

ST = 'is1';
cell_size = 512;
step_size = 512;
range = 100;
distance = 30;
angles = 30;

[neg_mat, zero_mat, pos_mat, sig_neg_mat, sig_zero_mat, sig_pos_mat, Rs, t, alphas] = generate_internal_wave_mat(20, 2, 512, 512, 'is1', '2021082');

fname = strcat('Z:\internal_waves\internal_waves_matrices\', ST, '_cell_',num2str(cell_size),'_step_', num2str(step_size),'_distance_',num2str(distance), '_ang_', num2str(angles), '.mat');
save(fname, 'neg_mat', 'zero_mat', 'pos_mat', 'sig_neg_mat', 'sig_zero_mat', 'sig_pos_mat', 'Rs', 't', 'alphas');