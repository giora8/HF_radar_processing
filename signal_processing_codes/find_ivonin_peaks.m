%% find_ivonin_peaks.m
function [f_peaks, partial_f_mat, partial_P_mat] = find_ivonin_peaks(P, undisturbed_vals, freq_norm, plt_flag, method)
%% Inputs
% P - backscattered Doppler spectra of size 1 X 512
% undisturbed_vals - normalized frequencies of theoretical backscattered
% waves
% freq_norm - frequency axis of size 1 X 512
% plt_flag - true for plot peaks
% method - type of method to find the peak: 'max' for detect maximal value
% inside the window. 'centroid' for Calculate centroid inside
% window
%% Output
% f_peaks: measured peaks (slightly different than undisturbed values)
% f_range: frequency range of the partial section where the peak exist
% P_range: power values of the partial frequency section where the peak exist
%
% -----------------find indices of unditurbed vals-------------------------
    
    undisturbed_ids = zeros(size(undisturbed_vals));
    
    for cur_peak = 1 : size(undisturbed_vals, 1)
        neg_val = undisturbed_vals(cur_peak, 1);
        pos_val = undisturbed_vals(cur_peak, 2);

        [~, cur_id_neg] = min(abs(freq_norm - neg_val));
        [~, cur_id_pos] = min(abs(freq_norm - pos_val));
        
        undisturbed_ids(cur_peak, 1) = cur_id_neg ;
        undisturbed_ids(cur_peak, 2) = cur_id_pos ;
    end
    
%--------------create window next to each undisturbed peak-----------------

    freq_step = freq_norm(2) - freq_norm(1);
    window_size = 0.15 ; % [f_B]
    %window_size = 0.25 ; % [f_B]
    expand_ids = ceil(window_size / freq_step);
    
    window_inds = zeros(numel(undisturbed_ids), 2);
    for cur_win = 1 : size(window_inds, 1)
        [a, b] = ind2sub(size(undisturbed_ids), cur_win);
        window_inds(cur_win, 1) = undisturbed_ids(a, b) - expand_ids;
        window_inds(cur_win, 2) = undisturbed_ids(a, b) + expand_ids;
    end

%------------------find maximal peak in each window------------------------
   
    if(plt_flag == 1)
        N = numel(undisturbed_vals);
        f = figure(3);
        f.Position = [100 100 1000 600];
    end

    f_peaks = zeros(size(undisturbed_vals));
    partial_f_mat = zeros(size(undisturbed_vals, 1), 1+window_inds(1, 2)-window_inds(1, 1));
    partial_P_mat = zeros(size(undisturbed_vals, 1), 1+window_inds(1, 2)-window_inds(1, 1));
    for cur_spec = 1 : numel(undisturbed_ids)

    % locate peak next to undisturbed values %

        partial_f = freq_norm(window_inds(cur_spec, 1):window_inds(cur_spec, 2));
        partial_P = P(window_inds(cur_spec, 1):window_inds(cur_spec, 2));
        
        if plt_flag == 1
            figure(2); hold on;
            plot(partial_f, partial_P, 'red');
        end

        partial_f_mat(cur_spec, :) = partial_f;
        partial_P_mat(cur_spec, :) = partial_P;

        [a, b] = ind2sub(size(undisturbed_vals), cur_spec);
        [vals, peak] = findpeaks(partial_P, 'MinPeakDistance', length(partial_P)-2);
        
        % sign sections around peaks on the full spectrum plot %
        
        if(plt_flag == 1)
            figure(3);
            subplot(N/ceil(N/2), ceil(N/2), cur_spec);
            findpeaks(partial_P, partial_f, 'MinPeakDistance', max(partial_f)-min(partial_f)-0.0001);
            hold on;
            xline(undisturbed_vals(a, b),'--k');
            if(cur_spec == 1 || cur_spec == 4)
                ylabel('Backscattered Power [dB]');
            end
            if(cur_spec <=6 && cur_spec >= 4)
                xlabel('normalized frequency [f_B]');
            end 
        end
        
        % return peak values for 'max' option
        
        if strcmp(method, 'max')
            if (~isempty(peak))
                [~, max_id] = max(vals);
                f_peaks(a, b) = partial_f(peak(max_id));
            else
                f_peaks(a, b) = 0;  % if could not detect peak - fill with zero
            end
            
        % return peak values for 'centroid' option
        
        else
            if strcmp(method, 'centroid')
                %% temp add-on
                if (~isempty(peak))
                    [~, max_id] = max(vals);
                    f_peaks(a, b) = partial_f(peak(max_id));
                else
                    f_peaks(a, b) = 0;  % if could not detect peak - fill with zero
                end
                temp_id = find(ismember(freq_norm, f_peaks(cur_spec)));
                partial_f = freq_norm(temp_id-expand_ids:temp_id+expand_ids);
                partial_P = P(window_inds(cur_spec, 1):window_inds(cur_spec, 2));
                %%
                f_peaks(a, b) = trapz(partial_f, partial_f .* partial_P) / trapz(partial_f, partial_P);
            end

        end
        
    end
    
end