%% extractPXY_nonEmptyCells.m
function [ids_exist, lon_lat_exist] = extractPXY_nonEmptyCells(PXY, lon, lat)
%% Inputs
% PXY - gridded spectrum (latitude, longitude) - 2D cell array, size of 160 X 200
% lon - size: 1 X 200
% lat - size: 1 X 160
% 
%% Output
%  ids_exist - indices of (longitude, latitude) that have measurements
%  lon_lat_exist - coordinates (longitude, latitude) that have meausrments
%
%----------------extract non empty coordinates' indices--------------------

    ids_non_empty=find(~cellfun('isempty',PXY));
    [ii, jj] = ind2sub(size(PXY), ids_non_empty);
    ids_exist = [ii jj];

%-----------values of non empty longitude and latitude---------------------

    lon_exist = lon(ii)'; 
    lat_exist = lat(jj)'; 
    lon_lat_exist = [lon_exist lat_exist];

end
