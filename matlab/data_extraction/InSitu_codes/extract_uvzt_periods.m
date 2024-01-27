function [filt_U, filt_V, filt_z, filt_t] = extract_uvzt_periods(U, V, t, z, id_start, id_end)
    
    min_depth = find(U(:, id_start)==0, 1);
    filt_U = U(1: min_depth-1, id_start: id_end);
    filt_V = V(1: min_depth-1, id_start: id_end);
    filt_z = z(1:min_depth-1);
    filt_t = t(id_start: id_end);

    
end

