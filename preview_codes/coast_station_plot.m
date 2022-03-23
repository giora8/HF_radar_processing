%% region_plot.m
function FigH = coast_station_plot

try
%% Caostline plot %%
%-----------------------load coastlines------------------------------------
    
    load('coastlines_high_res.mat');
    
    lat_coasts = randemodnet1.VarName3;
    lon_coasts = randemodnet1.VarName2;

%-------------------extract Israel's shore line----------------------------

    ids_lat = find(lat_coasts<=33 & lat_coasts >= 30.5);
    ids_lon = find(lon_coasts<=36 & lon_coasts >= 33);

    id_is_lat = find(ismember(ids_lat, ids_lon));
    id_is_lon = find(ismember(ids_lon, ids_lat));

    lat_is = lat_coasts(ids_lat(id_is_lat));
    lon_is = lon_coasts(ids_lon(id_is_lon));

%--------------------------plot the coastline------------------------------

    FigH = figure(); 
    plot(lon_is, lat_is, 'k', 'LineWidth',2)

%% add stations location %%

    loc_is1 = [34.545, 31.665]; % (longitude, latitude) - ASHKELON
    loc_is2 = [34.63583 31.83055]; % (longitude, latitude) - ASHDOD

    hold on; plot(loc_is1(1), loc_is1(2), 'x', 'markersize', 10, 'color', [0.5 0.5 0.5], 'LineWidth',3)
    hold on; plot(loc_is2(1), loc_is2(2), 'x', 'markersize', 10,'color', [0.5 0.5 0.5], 'LineWidth',3)

    text(34.545, 31.63, 'Israel 1');
    text(34.65, 31.76, 'Israel 2');
    xlabel('\circ E'); ylabel('\circ N'); 
    
catch
    disp('Missing coastlines file - exist in /Public/Projects/HF team/Codes/Matlab/imported_data_bases/coastlines_high_res.mat');
end

end