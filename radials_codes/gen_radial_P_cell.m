function loc_P_mat = gen_radial_P_cell(deg_files, r, theta, dir_path)
    
    loc_P_mat = cell(length(r), length(deg_files));
    for ii = 1 : length(deg_files)
    
        cur_filename = strcat(dir_path, deg_files(ii).name);
        id = strfind(cur_filename, '_');
        id = id(2);
        id_deg = strfind(cur_filename, 'deg');
        cur_deg = str2double(cur_filename(id+1:id_deg-1));
        id_cell =find(ismember(theta, cur_deg));
        
        cur_P = open_ascii_radial_spectrum(cur_filename);
        for jj = 1 : length(r)
            P_r = cur_P(jj, :);
            loc_P_mat(id_cell, jj) =  P_r;
        end
        
        
    end
end

