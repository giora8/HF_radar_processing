basic_path = 'C:\Giora\TAU\MEPlab\HF Radar\files\';
filename_spec = '20210830620_is1.spec';
filename_sort = '20210830620_is1.SORT';

[WERA,t,R,I,Q] = read_WERA_sort(strcat(basic_path, filename_sort));
[Time,LON,LAT,a,b,freq,fbragg,PXY] = read_WERA_spec(strcat(basic_path, filename_spec), 'UTM');
ids_non_empty=find(~cellfun(@isempty,PXY));
[ii, jj] = ind2sub(size(PXY), ids_non_empty);
P = PXY{ii(1), jj(1)}';

for cur_cell = 2 : length(ii)
    P(end+1, :) = PXY{ii(cur_cell), jj(cur_cell)}';
end

x = [length(ii): -1 : 1];

[F, X] = meshgrid(freq, x);

figure(); surf(F, X, P, 'edgecolor', 'none'); view([0 90]);
xlabel('Doppler shift [Hz]'); ylabel('Distance [A.U]');
xlim([min(freq) max(freq)]); ylim([min(x) max(x)]);

N1 = 170; N2 = 350;
P_partial = P(:, N1:N2);
F_partial = F(:, N1:N2);
X_partial = X(:, N1:N2);

p_mean = mean(P_partial, 1);
figure(); plot(freq(N1:N2), p_mean);
xlabel('Doppler shift [Hz]'); ylabel('mean power over all distance [dB]');
% figure(); surf(F_partial, X_partial, P_partial, 'edgecolor', 'none'); view([0 90]);
% xlabel('Doppler shift [Hz]'); ylabel('Distance [A.U]');
% xlim([min(freq) max(freq)]); ylim([min(x) max(x)]);
