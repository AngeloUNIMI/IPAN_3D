function [Xr, Yr, Zr, angle_pitch] = comp_rot_y(X, Y, Z, XL_plane, YL_plane, ZL_plane, fitresult)



c = max(YL_plane(:)) - min(YL_plane(:));

if size(ZL_plane,2) >= 10,
    b = max(ZL_plane(:,10)) - min(ZL_plane(:,10));
else
    b = max(ZL_plane(:,end)) - min(ZL_plane(:,end));
end,

a = sqrt(c^2 + b^2);

angle_pitch = asin(b/a);

if fitresult.p01 > 0,
    angle_pitch = -angle_pitch;
end,


Ricp = [1 0 0;  ...
        0 cos(angle_pitch) -sin(angle_pitch); ...
        0 sin(angle_pitch) cos(angle_pitch)];

    
probe = [X'; Y'; Z'];
probe_aligned = Ricp*probe;

Xr = probe_aligned(1,:)';
Yr = probe_aligned(2,:)';
Zr = probe_aligned(3,:)';
