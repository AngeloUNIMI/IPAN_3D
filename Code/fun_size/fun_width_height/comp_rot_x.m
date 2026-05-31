function [Xr, Yr, Zr, angle_roll] = comp_rot_x(X_temp, Y_temp, Z_temp, XL_plane, YL_plane, ZL_plane, fitresult)



%-----------------------------------------COMPENSAZIONE ROTAZIONE 3D - X




med = round(numel(X_temp)/2);
%range = round(numel(XL_sf3d_norm)/8*3 - 0);
range = round(numel(X_temp)/8*4 - 1);


%template = [X_ref_pc; Y_ref_pc; Z_ref_pc];
probe = [X_temp'; Y_temp'; Z_temp'];


%c = max(XL_sf3d_norm(med-range:med+range)) - min(XL_sf3d_norm(med-range:med+range));
%b = max(ZL_sf3d_norm(med-range:med+range)) - min(ZL_sf3d_norm(med-range:med+range));

c = max(XL_plane(:)) - min(XL_plane(:));

if size(ZL_plane,2) >= 10,
    %b = max(ZL_plane(:,10)) - min(ZL_plane(:,10));
    b = max(ZL_plane(10,:)) - min(ZL_plane(10,:));
else
    %b = max(ZL_plane(:,end)) - min(ZL_plane(:,end));
    b = max(ZL_plane(end,:)) - min(ZL_plane(end,:));
end


a = sqrt(c^2 + b^2);

angle_roll = asin(b/a);

if fitresult.p10 < 0,
    angle_roll = -angle_roll;
end,


Ricp = [cos(angle_roll) 0 sin(angle_roll); ...
        0 1 0; ...
        -sin(angle_roll) 0 cos(angle_roll)];


%probe_aligned = Ricp*probe + repmat(Ticp,1,length(probe));
probe_aligned = Ricp*probe;

Xr = probe_aligned(1,:)';
Yr = probe_aligned(2,:)';
Zr = probe_aligned(3,:)';