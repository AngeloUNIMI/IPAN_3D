function [spess_mean_img_mm, features_thickness] = calcola_spessore_two_view(j_to_remove_A, j_to_remove_B, points_A_L, ...
    points_A_R, points_B_L, points_B_R, transform_A_in_B, stereoParams, minYA, minYB, plotta, screen_size, height_plot)


fs = 15;


j_to_removeAB = unique([j_to_remove_A j_to_remove_B]);
points_A_L(j_to_removeAB, :) = [];
points_A_R(j_to_removeAB, :) = [];
points_B_L(j_to_removeAB, :) = [];
points_B_R(j_to_removeAB, :) = [];






%invertiamo la trasformazione omografica
[U,V] = tforminv(transform_A_in_B, points_A_L(:,1), points_A_L(:,2));
points_A_L(:,1) = U;
points_A_L(:,2) = V;
[U,V] = tforminv(transform_A_in_B, points_A_R(:,1), points_A_R(:,2));
points_A_R(:,1) = U;
points_A_R(:,2) = V;


%triangoliamo
worldPointsL = triangulate(points_A_L, points_B_L, stereoParams);
X_A_L = worldPointsL(:,1);
Y_A_L = worldPointsL(:,2);
Z_A_L = worldPointsL(:,3);

worldPointsR = triangulate(points_A_R, points_B_R, stereoParams);
X_A_R = worldPointsR(:,1);
Y_A_R = worldPointsR(:,2);
Z_A_R = worldPointsR(:,3);


if plotta
    figure,
    showPointCloud(worldPointsL, 'b', 'MarkerSize', 30);
    hold on
    showPointCloud(worldPointsR, 'r', 'MarkerSize', 30);
    xlabel('X [mm]','FontSize',fs);
    ylabel('Y [mm]','FontSize',fs);
    zlabel('Z [mm]','FontSize',fs);
    title('point cloud non filtrata')
    set(gcf, 'color', 'w');
    legend({'Lower border', 'Upper border'},'FontSize',fs);
    set(gca,'FontSize',fs)
end








%i punti devono avere una coordinata Z molto simile, altrimenti il
%match è sbagliato
%soglia = 1;
%[X_A_L, Y_A_L, Z_A_L, X_A_R, Y_A_R, Z_A_R] = filtraMatchSpessore(X_A_L, Y_A_L, Z_A_L, X_A_R, Y_A_R, Z_A_R, soglia);



%calcoliamo le distanze punto a punto
eudistV = [];
for l = 1 : numel(X_A_L)
    eudist = pdist([X_A_L(l) Y_A_L(l) Z_A_L(l); X_A_R(l) Y_A_R(l) Z_A_R(l)], 'euclidean');
    eudistV = [eudistV eudist];
end




%ELIMINAZIONE IN BASE AI QUANTILI
quantile_low = quantile(eudistV, 0.2);
I_low = find(eudistV < quantile_low);
quantile_high = quantile(eudistV, 0.8);
I_high = find(eudistV > quantile_high);
I_low_plus_high = unique([I_low I_high]);


X_A_L_q = X_A_L;
Y_A_L_q = Y_A_L;
Z_A_L_q = Z_A_L;
X_A_R_q = X_A_R;
Y_A_R_q = Y_A_R;
Z_A_R_q = Z_A_R;

X_A_L_q(I_low_plus_high') = [];
Y_A_L_q(I_low_plus_high') = [];
Z_A_L_q(I_low_plus_high') = [];
X_A_R_q(I_low_plus_high') = [];
Y_A_R_q(I_low_plus_high') = [];
Z_A_R_q(I_low_plus_high') = [];

if plotta
    figure,
    showPointCloud([X_A_L_q, Y_A_L_q, Z_A_L_q], 'b');
    hold on
    showPointCloud([X_A_R_q, Y_A_R_q, Z_A_R_q], 'r');
    xlabel('X [mm]');
    ylabel('Y [mm]');
    zlabel('Z [mm]');
    title('point cloud filtrata quantile')
    set(gcf, 'color', 'w');
end





%INTERPOLAZIONE LINEARE
%come base usiamo il range più esteso tra x e y
if (max(X_A_L_q)-min(X_A_L_q)) > (max(Y_A_L_q)-min(Y_A_L_q))
    [x, is] = sort([X_A_L_q]);
else
    [x, is] = sort([Y_A_L_q]);
end
y = [Z_A_L_q];
y = y(is);
p = polyfit(x, y, 1);

%reverse sorting
if (max(X_A_L_q)-min(X_A_L_q)) > (max(Y_A_L_q)-min(Y_A_L_q))
    x = X_A_L_q;
else
    x = Y_A_L_q;
end
y = Z_A_L_q;

y_val = polyval(p, x);


%distanze
distpol = abs(y_val - y);
idistpol = find(distpol > 7);


if plotta
    figure,
    plot(x, y, 'b-')
    hold on
    plot(x, y_val, 'r-');
    plot(x(idistpol), y(idistpol), 'kx');
end


X_A_L_p = X_A_L_q;
Y_A_L_p = Y_A_L_q;
Z_A_L_p = Z_A_L_q;
X_A_R_p = X_A_R_q;
Y_A_R_p = Y_A_R_q;
Z_A_R_p = Z_A_R_q;

X_A_L_p(idistpol') = [];
Y_A_L_p(idistpol') = [];
Z_A_L_p(idistpol') = [];
X_A_R_p(idistpol') = [];
Y_A_R_p(idistpol') = [];
Z_A_R_p(idistpol') = [];


%whos X_A_L_p X_A_L_q



if 1
    handle_thick = figure;
    showPointCloud([X_A_L_p, Y_A_L_p, Z_A_L_p], 'b', 'MarkerSize', 30);
    hold on
    showPointCloud([X_A_R_p, Y_A_R_p, Z_A_R_p], 'r', 'MarkerSize', 30);
    xlabel('X [mm]','FontSize',fs);
    ylabel('Y [mm]','FontSize',fs);
    zlabel('Z [mm]','FontSize',fs);
    title('point cloud filtrata polinomio')
    set(gcf, 'color', 'w');
    legend({'Lower border', 'Upper border'},'FontSize',fs);
    set(gca,'FontSize',fs)
end
set(handle_thick,'Position',[screen_size(3)/3*2+10 (screen_size(4)-height_plot-35) screen_size(3)/3 height_plot]);




%calcoliamo le distanze punto a punto
eudistV = [];
for l = 1 : numel(X_A_L)
    eudist = pdist([X_A_L(l) Y_A_L(l) Z_A_L(l); X_A_R(l) Y_A_R(l) Z_A_R(l)], 'euclidean');
    eudistV = [eudistV eudist];
end
spess_mean_img_mm = mean(eudistV);

%eudistV




%FEATURES

features_thickness = eudistV;







