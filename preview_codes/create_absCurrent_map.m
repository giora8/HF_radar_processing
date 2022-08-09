%% generate 2D map from cur_asc files

fname= 'Z:\20221451940_izr.cur_asc';
[IX,IY,U,V,Uer,Ver,KL]=read_WERA_asc_cur(fname);

U_mat = nan(160, 200);
V_mat = nan(160, 200);

for ii = 1 : length(IX)
    U_mat(IX(ii), IY(ii)) = U(ii);
    V_mat(IX(ii), IY(ii)) = V(ii);
end

%% get longitude, latitude map values

load('lonlat.mat');
[LAT, LON] = meshgrid(lat, lon);

%% velocity value

FigH = coast_station_plot;
ax = gca;
h = pcolor(LON, LAT, sqrt(U_mat.^2 + V_mat.^2));
h.EdgeColor = 'none';

%% quiver plot

hold on; quiver(lon, lat, U_mat', V_mat', 2.5);

%% titles

c = colorbar;
c.Label.String = 'Velocity [cm/s]';
year = fname(4:7);
day = fname(8:10);
hour = string(fname(11:12));
minutes = string(fname(13:14));
str_toDateTime = strcat('1-Jan-', year);
N = str2double(day);
Dt0 = string(datestr(datetime(str_toDateTime)+N-1));
title_str = strcat(Dt0, {' '}, hour, ':', minutes, ' UTC');
title(title_str);

%% vorticity and horizontal divergence maps

[U_x, U_y] = gradient(U_mat, 1500, 1500);
[V_x, V_y] = gradient(V_mat, 1500, 1500);

vort = V_x - U_y;
div = U_x + V_y;

FigH = coast_station_plot;
ax = gca;
h = pcolor(LON, LAT, vort);
h.EdgeColor = 'none';
c = colorbar;
c.Label.String = 'Vorticity [s^{-1}]';
title(title_str);

FigH = coast_station_plot;
ax = gca;
h = pcolor(LON, LAT, div);
h.EdgeColor = 'none';
c = colorbar;
c.Label.String = 'Horizontal Divergence [s^{-1}]';
title(title_str);
