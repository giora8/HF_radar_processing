%% open_ascii_radial_spectrum.m
function P = open_ascii_radial_spectrum(fname)
%% Inputs
% fname - filename of the .asc file needs to be read
%% Output
% P - spectrum of all range in the .asc file
%
%----------get # of time steps to understand measurement size-------------%

    fid = fopen(fname, 'r');
    tline = fgetl(fid);
    time_dim = count(tline, '.');

%------------------- reading entire data (1D array) ----------------------%

    P_unshaped = fscanf(fid, '%f');
    fclose(fid);

%-------------- reshape to [Range Cell X Frequency] size -----------------%
    try
        P = reshape(P_unshaped, time_dim, length(P_unshaped)/ time_dim)';
    catch
        a=1;
    end
    
end

