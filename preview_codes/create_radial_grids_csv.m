angles = -30 : 5 : 30;
angle_az = 300 + angles;
Rs = 0.25 : 0.64 : 20;
Rs_deg = km2deg(Rs);

coords = zeros(size(angles, 2) * size(Rs,2), 2); % [lat, lon]
HF = [34.545, 31.665];

counter = 1;
for ii = 1 : length(angles)
    for jj = 1 : length(Rs)
        
        [latOut,lonOut] = reckon(HF(2), HF(1), Rs_deg(jj), angle_az(ii));
        coords(counter, 1) = latOut;
        coords(counter, 2) = lonOut;
        counter = counter + 1;
        
    end
end