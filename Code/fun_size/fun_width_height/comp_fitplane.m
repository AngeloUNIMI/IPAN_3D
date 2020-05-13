function [fitresult, XL_plane, YL_plane, ZL_plane] = comp_fitplane(X_temp, Y_temp, Z_temp)


[fitresult, gof] = planeFit(X_temp, Y_temp, Z_temp);
XL_plane = min(X_temp):max(X_temp);
YL_plane = min(Y_temp):max(Y_temp);
[XL_plane, YL_plane] = meshgrid(XL_plane, YL_plane);
ZL_plane = fitresult.p00 + fitresult.p10.*XL_plane + fitresult.p01.*YL_plane;