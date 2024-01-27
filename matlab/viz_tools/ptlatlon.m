%% |ptlatlon| documentation
% The |ptlatlon| allows you to get latitude/longitude given a current point, distance and bearing.
% 
%% Syntax
% 
%  [a b] = ptlatlon(lat,lon,b,d,R)
% 
%% Description 
%
% latitude2,longitude2 = pptlatlon(latitude1,longitude1,bearing,distance,earthradius)
%
% This function allows you to get the decimal degrees coordinates of a point given a reference point lat,long 
%(decimal degrees), d distance from that point (km), b bearing (degrees oriented as in the trigonometric circle), R earth radius at that point (km)(average R = 6 371).
% 
%% Author Info
% This function was written by Robin MARTY, intern at New-Zealand Institute for Water and Atmospheric Research on May 08 2018.  
function[lat2,long2]=ptlatlon(lat1,long1,brng,d,R)
% Matlab trigonometry functions work with radians, thus we're swaping our degree coordinates to radians
lat1=deg2rad(lat1);
long1=deg2rad(long1);
brng=deg2rad(brng);
% These calculations were easely found on the internet 
lat2=asin(sin(lat1).*cos(d/R)+cos(lat1).*sin(d/R).*cos(brng));
long2 = long1 + atan2(sin(brng).*sin(d/R).*cos(lat1),cos(d/R)-sin(lat1).*sin(lat2));
% As an output we want decimal degrees, so we're swaping back again
lat2=rad2deg(lat2);
long2=rad2deg(long2);
end