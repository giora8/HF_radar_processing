%% extract_ang_number.m
function ang_num = extract_ang_number(fname)
% extract the angle number from filename of type: yyyydddttttttt_angdeg.asc

    id = strfind(fname, '_');
    id = id(end);
    ang_str = fname(id+1:id+3);
    ang = ang_str(2:end);
    ang_num = str2double(ang);
    if strcmp(ang_str(1), '-')
        ang_num = -ang_num;
    end
    
end

