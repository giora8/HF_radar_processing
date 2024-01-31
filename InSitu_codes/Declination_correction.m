function [True_N_Measured, True_W_Measured] = ...
    Declination_correction(Measured_N, Measured_W, declination_angleE)
% declination_angle - East declination [degrees]

declination_angleE=deg2rad(declination_angleE);
True_N_Measured=Measured_N.*cos(declination_angleE)+Measured_W.*sin(declination_angleE);
True_W_Measured=-Measured_N.*sin(declination_angleE)+Measured_W.*cos(declination_angleE);