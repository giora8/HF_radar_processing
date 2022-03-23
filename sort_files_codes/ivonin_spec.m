%% ivonin_spec.m
function [f_peaks, U, partial_f, partial_P] = ivonin_spec(PXY, range, lon, lat, freq, fbragg, plt_flag)
%% Inputs
% PXY - gridded spectrum (latitude, longitude) - 2D cell array,
% probably size of 160 X 200
% range - indices of the selected sub-range from entire coverage area
% lon - size: 1 X 200
% lat - size: 1 X 160
% freq - frequency axis from WERA
% f_B - Bragg frequency of HF
% plt_flag - 1: for area & spectrum plot. 0: no plot
%
%% Output
%  figure of coverage area is created
%  U: calculated velocities in each depth according to ivonin 2004
%   

%------------generate average spectrum over desired region-----------------
    if iscell(PXY)
        longitude_indices = range(:, 1);
        latitude_indices = range(:, 2);
        P = PXY{longitude_indices(1), latitude_indices(1)}';

        for cur_cell = 2 : length(longitude_indices)
            P = (P + PXY{longitude_indices(cur_cell), latitude_indices(cur_cell)}') ./ 2;
        end
    else
        P = PXY;
    end

%---------------------------coverage area plot-----------------------------
    
    if plt_flag == 1
        [~] = coast_station_plot;
        
        hold on;
        scatter(lon(longitude_indices), lat(latitude_indices), '.');
    end

%---------------------------Doppler spectrum plot--------------------------    
  
    freq_norm = freq ./ fbragg ;
    
    first_harmonic = [ 1 -1 ];
    second_harminic = [sqrt(2) -sqrt(2)];
    corner_wave = [2^(3/4) -2^(3/4)];
    
    if plt_flag == 1
        figure(2);
        plot(freq_norm, P);
        hold on;
        xline(first_harmonic(1),'--k'); xline(first_harmonic(2),'--k');
        xline(second_harminic(1),'--k'); xline(second_harminic(2),'--k');
        xline(corner_wave(1),'--k'); xline(corner_wave(2),'--k');

        xlabel('Normalized Frequency [f_B]');
        ylabel('Backscattered Power [dB]');
        xlim([min(freq_norm) max(freq_norm)]);
    end
 
 %------------------------Currents calculation-----------------------------
 
     undisturbed_vals = [first_harmonic ; second_harminic ; corner_wave];
     [f_peaks, partial_f, partial_P] = find_ivonin_peaks(P, undisturbed_vals, freq_norm, 1, 'max');
          
     f_diff = f_peaks - undisturbed_vals;
     f_diff = f_diff .* fbragg;
     lamda_EM = 3e8 / 8.3e6 ;
     lambda_bragg = lamda_EM / 2;
     
     U = lambda_bragg .* f_diff;
     
%----------------Display currents on main Doppler figure------------------%

    if plt_flag == 1
       
        figure(2); hold on;
        
        [~, min_id1] = min(abs(freq - f_peaks(1, 1)));
        [~, min_id2] = min(abs(freq - f_peaks(1, 2)));
        [~, max_id] = max(P);
        
        f_txt1 = freq(min_id1);
        f_txt2 = freq(min_id2);
        P_txt = P(max_id) + 2;
        
        U_1_p = num2str(U(1, 1));
        U_1_P = U_1_p(1:4);
        U_1_n = num2str(U(1, 2));
        U_1_n = U_1_n(1:4);
        
        text(f_txt1, P_txt, strcat('U_{1_p}=', U_1_P, 'm/s'));
        text(f_txt2, P_txt, strcat('U_{1_n}=', U_1_n, 'm/s'));
        
        df = f_peaks(1, :) - undisturbed_vals(1, :);
        df_p = num2str(df(1)*fbragg);
        df_p = df_p(1:6);
        df_n = num2str(df(2)*fbragg);
        df_n = df_n(1:6);
        
        title(strcat('\Deltaf_n = ', df_n, ' [Hz]  \Deltaf_p = ', df_p, ' [Hz]'));
        
    end

end