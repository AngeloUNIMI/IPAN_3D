function [Lunghezza_calcolata, Larghezza_calcolata, features_length, features_width, code] = ...
    calcola_dimensione_strand(mask1, stereoParams, t1, matchL, matchR, im1, im1gray, im2, im2gray, nNeigh3d, plotta, screen_size, height_plot)

%inizializziamo
code = 1;
features_length = [];
features_width = [];

fs = 13;







%invertiamo la trasformazione omografica dell'immagine A
[U,V] = tforminv(t1, matchL(:,1), matchL(:,2));
matchL(:,1) = U;
matchL(:,2) = V;
t1_inv = fliptform(t1);
[im1, ~, ~] = imtransform(im1, t1_inv, 'bicubic', 'xData', [1, size(im1,2)], 'yData', [1, size(im1,1)] );
[mask1, ~, ~] = imtransform(mask1, t1_inv, 'bicubic', 'xData', [1, size(mask1,2)], 'yData', [1, size(mask1,1)] );
[im1gray, ~, ~] = imtransform(im1gray, t1_inv, 'bicubic', 'xData', [1, size(im1gray,2)], 'yData', [1, size(im1gray,1)] );







whos CCCLr CCCLm





%----------------------------------------------------SPIKEFILTER 2D
matchL_ref2d = matchL;
matchR_ref2d = matchR;
%[matchL_ref2d, matchR_ref2d] = spikefilter2d(matchL, matchR, 2, 2);





%plotta punti 3D
worldPoints = triangulate(matchL_ref2d,matchR_ref2d,stereoParams);
XL_sf2d = worldPoints(:,1);
YL_sf2d = worldPoints(:,2);
ZL_sf2d = worldPoints(:,3);

x2q=quantile( XL_sf2d, 0.01 );
x1q=quantile( XL_sf2d, 0.99 );

y2q=quantile( YL_sf2d, 0.01 );
y1q=quantile( YL_sf2d, 0.99 );

z2q=quantile( ZL_sf2d, 0.01 );
z1q=quantile( ZL_sf2d, 0.99 );

%%%
%puntiLungh3D = triangulate([pp1_start; pp1_end], [pp2_start; pp2_end], stereoParams);
%puntiLargh3D = triangulate(pp1_m, pp2_m, stereoParams);

%pause,

if plotta
    figure, showPointCloud(worldPoints);
    %title('Unfiltered point cloud');
    title('Point cloud non filtrata');
    %title(['DeltaX: ' num2str(abs(x1-x2)) ' DeltaY: ' num2str(abs(y1-y2)) ' DeltaZ: ' num2str(abs(z1-z2))]);
    xlabel('X [mm]','FontSize',fs);
    ylabel('Y [mm]','FontSize',fs);
    zlabel('Z [mm]','FontSize',fs);
    set(gcf,'color','w');
end


% Xf = XL_sf2d;
% Yf = YL_sf2d;
% Zf = ZL_sf2d;


%
%-----------------------------------------------------------------------------SPIKE FILTER 3D
%fprintf(1,'Spike filter 3D.....\n');
[matchL_ref3d, matchR_ref3d, XL_sf3d, YL_sf3d, ZL_sf3d, dT] = spikefilter3d(matchL_ref2d, matchR_ref2d, XL_sf2d, YL_sf2d, ZL_sf2d, nNeigh3d);
worldPoints_f = zeros(size(matchL_ref3d,1), 3);
worldPoints_f(:,1) = XL_sf3d;
worldPoints_f(:,2) = YL_sf3d;
worldPoints_f(:,3) = ZL_sf3d;

if plotta
    figure, showPointCloud(worldPoints_f, 'MarkerSize', 100);
    title('Point cloud dopo filtraggio vicini');
    xlabel('X [mm]','FontSize',fs);
    ylabel('Y [mm]','FontSize',fs);
    zlabel('Z [mm]','FontSize',fs);
    set(gcf,'color','w');
    set(gca,'FontSize',14)
    set(gca,'FontWeight','bold')
    view(-36, 30)
    %pause
end


if numel(XL_sf3d) < 4
    code = 0;
    Lunghezza_calcolata = 0;
    Larghezza_calcolata = 0;
    return ;
end 


%INTERPOLATING PLANE
passo1L = (max(XL_sf3d) - min(XL_sf3d)) / 20;
passo2L = (max(YL_sf3d) - min(YL_sf3d)) / 20;
C1 = [XL_sf3d(:) YL_sf3d(:) ones(numel(ZL_sf3d),1)] \ ZL_sf3d(:);
[x1,y1]=meshgrid(min(XL_sf3d):passo1L:max(XL_sf3d),min(YL_sf3d):passo2L:max(YL_sf3d));
[errore_mean, errore_max, errore_std] = calcola_errore_piano_interp(C1, XL_sf3d, YL_sf3d, ZL_sf3d);


if plotta
    figure, showPointCloud(worldPoints_f, 'MarkerSize', 100);
    hold on
    hs = surf(x1,y1,C1(1)*x1+C1(2)*y1+C1(3));
    xlabel('X [mm]','FontSize',fs);
    ylabel('Y [mm]','FontSize',fs);
    zlabel('Z [mm]','FontSize',fs);
    alpha(hs, 0);
    set(gcf,'color','w');
    title({'Point cloud dopo filtraggio vicini - Piano interpolante', ['Mean distance from interpolating plane: ' num2str(errore_mean) ' [mm]']});
    view(-36, 30)
    set(gca,'FontSize',14)
    set(gca,'FontWeight','bold')
    %set(gca,'ydir','reverse')
end







%---------------------SPIKE FILTER INTERPOLATING PLANE
[matchL_ref3d_p, matchR_ref3d_p, XL_sf3d_p, YL_sf3d_p, ZL_sf3d_p] = spikefilter3d_plane(matchL_ref3d, matchR_ref3d, XL_sf3d, YL_sf3d, ZL_sf3d, C1);

Xf = XL_sf3d_p;
Yf = YL_sf3d_p;
Zf = ZL_sf3d_p;
worldPoints_p = zeros(size(matchL_ref3d_p,1), 3);
worldPoints_p(:,1) = Xf;
worldPoints_p(:,2) = Yf;
worldPoints_p(:,3) = Zf;

if numel(Xf) < 4
    code = 0;
    Lunghezza_calcolata = 0;
    Larghezza_calcolata = 0;
    return ;
end


%SECOND INTERPOLATING PLANE
passo1L = (max(Xf) - min(Xf)) / 20;
passo2L = (max(Yf) - min(Yf)) / 20;
C1 = [Xf(:) Yf(:) ones(numel(Zf),1)] \ Zf(:);
[x1,y1]=meshgrid(min(Xf):passo1L:max(Xf),min(Yf):passo2L:max(Yf));
[errore_mean, errore_max, errore_std] = calcola_errore_piano_interp(C1, Xf, Yf, Zf);


if 1
    handle_norot = figure;
    showPointCloud(worldPoints_p, 'MarkerSize', 100);
    hold on
    hs = surf(x1,y1,C1(1)*x1+C1(2)*y1+C1(3));
    xlabel('X [mm]','FontSize',fs);
    ylabel('Y [mm]','FontSize',fs);
    zlabel('Z [mm]','FontSize',fs);
    alpha(hs, 0);
    view(-36, 30)
    title({'Point cloud dopo filtraggio vicini e filtraggio piano', ['Mean distance from interpolating plane: ' num2str(errore_mean) ' [mm]']});
    set(gcf,'color','w');
    set(gca,'FontSize',14)
    set(gca,'FontWeight','bold')
    %set(gca,'ydir','reverse')
end
set(handle_norot,'Position',[screen_size(3)/3*2+10 (screen_size(4)-height_plot-35) screen_size(3)/3 height_plot]);








%normalizziamo le rotazioni
%più volte così è più preciso
for nn = 1 : 3
    
    %normalizziamo
    [X_norm, Y_norm, Z_norm] = norm_point_cloud(Xf, Yf, Zf);
    
    
    if numel(X_norm) < 4 || numel(Y_norm) < 4 || numel(Z_norm) < 4
        code = 0;
        Lunghezza_calcolata = 0;
        Larghezza_calcolata = 0;
        return ;
    end
    %numel(X_norm)
    
    %calcoliamo piano interpolante
    [fitresult, X_plane, Y_plane, Z_plane] = comp_fitplane(X_norm, Y_norm, Z_norm);
    
    %compensazione rotazione asse X
    [Xf, Yf, Zf, angle_roll] = comp_rot_x(Xf, Yf, Zf, X_plane, Y_plane, Z_plane, fitresult);
    
    %compensazione rotazione asse Y
    [Xf, Yf, Zf, angle_pitch] = comp_rot_y(Xf, Yf, Zf, X_plane, Y_plane, Z_plane, fitresult);
    
end


% figure
% surf(X_plane, Y_plane, Z_plane)
% title('boh')
% assignin('base', 'X_plane', X_plane)
% assignin('base', 'Y_plane', Y_plane)
% assignin('base', 'Z_plane', Z_plane)
% pause


Xrxy = Xf;
Yrxy = Yf;
Zrxy = Zf;


if 1
    handle_rot = figure;
    showPointCloud([Xrxy, Yrxy, Zrxy], 'MarkerSize', 100);
    xlabel('X [mm]','FontSize',fs);
    ylabel('Y [mm]','FontSize',fs);
    zlabel('Z [mm]','FontSize',fs);
    title('Point cloud dopo normalizzazione rotazioni');
    set(gcf,'color','w');
    %set(gca,'ydir','reverse')
    view(-36, 30);
    set(gca,'FontSize',14)
    set(gca,'FontWeight','bold')
end
set(handle_rot,'Position',[screen_size(3)/3*2+10 (screen_size(4)-(height_plot+35)*2-0) screen_size(3)/3 height_plot]);












%POINT CLOUD TO IMAGE
xi = Xrxy - min(Xrxy); %facciamo partire da 0
yi = Yrxy - min(Yrxy);
im = zeros(round(max(yi) - min(yi)) + 10,   round(max(xi) - min (xi)) +10 ); %+10 così abbiamo un po' di bordo
for j = 1 : numel(xi)
    im(  round(yi(j))+5  , round(xi(j))+5  ) = 1;
end


[y, x] = find(im);
K = convhull(x, y);
bw = poly2mask(x(K), y(K), size(im,1), size(im,2));


[L, num] = bwlabel(bw, 8);
stats = regionprops(bw, 'all');

stats = stats(1);

maj_axis = stats.MajorAxisLength;
min_axis = stats.MinorAxisLength;


%plot con assi originali
if plotta
    figure,
    deltax = maj_axis * cosd(180-stats.Orientation);
    deltay = maj_axis * sind(180-stats.Orientation);
    xVals_maj = [stats.Centroid(1)-deltax/2 stats.Centroid(1)+deltax/2];
    yVals_maj = [stats.Centroid(2)-deltay/2 stats.Centroid(2)+deltay/2];
    deltax = min_axis * cosd(180-stats.Orientation-90);
    deltay = min_axis * sind(180-stats.Orientation-90);
    xVals_min = [stats.Centroid(1)-deltax/2 stats.Centroid(1)+deltax/2];
    yVals_min = [stats.Centroid(2)-deltay/2 stats.Centroid(2)+deltay/2];
    imshow(bw)
    hold on
    line(xVals_maj , yVals_maj, 'LineWidth', 5)
    hold on
    line(xVals_min , yVals_min, 'LineWidth', 5)
    title('Convex hull e assi maggiore e minore - lunghezza  originale');
end




%AGGIUSTIAMO LA LUNGHEZZA DEGLI ASSI IN MODO CHE CADANO DENTRO LO
%STRAND
%asse maggiore
while 1
    
    deltax = maj_axis * cosd(180-stats.Orientation);
    deltay = maj_axis * sind(180-stats.Orientation);
    xVals_maj = [stats.Centroid(1)-deltax/2 stats.Centroid(1)+deltax/2];
    yVals_maj = [stats.Centroid(2)-deltay/2 stats.Centroid(2)+deltay/2];
    
    if round(xVals_maj(1)) <= 0  || round(xVals_maj(1)) > size(bw,2)
        maj_axis = maj_axis - 1;
        continue;
    end
    
    if round(xVals_maj(2)) <= 0  || round(xVals_maj(2)) > size(bw,2)
        maj_axis = maj_axis - 1;
        continue;
    end
    
    if round(yVals_maj(1)) <= 0  || round(yVals_maj(1)) > size(bw,1)
        maj_axis = maj_axis - 1;
        continue;
    end
    
    if round(yVals_maj(2)) <= 0  || round(yVals_maj(2)) > size(bw,1)
        maj_axis = maj_axis - 1;
        continue;
    end
    
    if bw(   round(yVals_maj(1)), round(xVals_maj(1))   ) == 0
        maj_axis = maj_axis - 1;
        continue;
    end
    
    if bw(   round(yVals_maj(2)), round(xVals_maj(2))   ) == 0
        maj_axis = maj_axis - 1;
        continue;
    end
    
    if bw(   round(yVals_maj(1)), round(xVals_maj(1))   ) == 1  && bw(   round(yVals_maj(2)), round(xVals_maj(2))   ) == 1
        break;
    end
    
end
%maj_axis, min_axis,

%asse minore
while 1
    
    deltax = min_axis * cosd(180-stats.Orientation-90);
    deltay = min_axis * sind(180-stats.Orientation-90);
    xVals_min = [stats.Centroid(1)-deltax/2 stats.Centroid(1)+deltax/2];
    yVals_min = [stats.Centroid(2)-deltay/2 stats.Centroid(2)+deltay/2];
    
    if round(xVals_min(1)) <= 0  || round(xVals_min(2)) > size(bw,2)
        min_axis = min_axis - 1;
        continue;
    end
    
    if round(yVals_min(1)) <= 0  || round(yVals_min(2)) > size(bw,1)
        min_axis = min_axis - 1;
        continue;
    end
    
    if bw(   round(yVals_min(1)), round(xVals_min(1))   ) == 0
        min_axis = min_axis - 1;
        continue;
    end
    
    if bw(   round(yVals_min(2)), round(xVals_min(2))   ) == 0
        min_axis = min_axis - 1;
        continue;
    end
    
    if bw(   round(yVals_min(1)), round(xVals_min(1))   ) == 1  && bw(   round(yVals_min(2)), round(xVals_min(2))   ) == 1
        break;
    end
    
end


maj_axis = round(maj_axis);
min_axis = round(min_axis);


Lunghezza_calcolata = max([maj_axis min_axis]);
Larghezza_calcolata = min([maj_axis min_axis]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Lunghezza_calcolata = round(Lunghezza_calcolata / 1.06);
%Larghezza_calcolata = round(Larghezza_calcolata / 1.4);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if plotta
    fsfigure(),
    subplot(2,2,1), imshow(im2double(im1gray) + edge(mask1), []);
    title('Point cloud normalizzata proiettata sull''immagine');
    subplot(2,2,2), imshow(im, []);
    title('Point cloud normalizzata proiettata sull''immagine');
    subplot(2,2,3), imshow(bw, []);
    title('maschera corrispondente');
    subplot(2,2,4),
    imshow(bw);
    title({'Convex hull e assi maggiore e minore' , ...
        ['Lunghezza calcolata ' num2str(Lunghezza_calcolata) ' [mm]'], ...
        ['Larghezza calcolata ' num2str(Larghezza_calcolata) ' [mm]']});
    hold on
    line(xVals_maj , yVals_maj, 'LineWidth', 5)
    hold on
    line(xVals_min , yVals_min, 'LineWidth', 5)
    pause(1)
end


if plotta
    figure
    imshow(bw);
    title({'Convex hull e assi maggiore e minore' , ...
        ['Lunghezza calcolata ' num2str(Lunghezza_calcolata) ' [mm]'], ...
        ['Larghezza calcolata ' num2str(Larghezza_calcolata) ' [mm]']});
    hold on
    line(xVals_maj , yVals_maj, 'LineWidth', 5)
    hold on
    line(xVals_min , yVals_min, 'LineWidth', 5)
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ESTRAZIONE FEATURE
%LENGTH

%lunghezza calcolata
features_length(1) = Lunghezza_calcolata;
%asse maggiore originale
features_length(2) = stats.MajorAxisLength;
%area
features_length(3) =  Lunghezza_calcolata * Larghezza_calcolata;
%perimetro
features_length(4) = stats.Perimeter;
%rapporto area/perimetro
features_length(5) =  (Lunghezza_calcolata * Larghezza_calcolata) / stats.Perimeter;
%rapporto tra gli assi
features_length(6) =  stats.MajorAxisLength / stats.MinorAxisLength;
%angolo roll
features_length(7) =  angle_roll;
%angolo pitch
features_length(8) =  angle_pitch;


%WIDTH

%lunghezza calcolata
features_width(1) = Larghezza_calcolata;
%asse maggiore originale
features_width(2) = stats.MinorAxisLength;
%area
features_width(3) =  Lunghezza_calcolata * Larghezza_calcolata;
%perimetro
features_width(4) = stats.Perimeter;
%rapporto area/perimetro
features_width(5) =  (Lunghezza_calcolata * Larghezza_calcolata) / stats.Perimeter;
%rapporto tra gli assi
features_width(6) =  stats.MajorAxisLength / stats.MinorAxisLength;
%angolo roll
features_width(7) =  angle_roll;
%angolo pitch
features_width(8) =  angle_pitch;












