function [points_L, points_R, j_to_remove] = calcola_punti_per_spessore(num_campioni, im, im_enh, plotta, minY, quantile_spessore)



%le immagini sono rettificate, allineiamo
im_enh = im_enh(minY : end, :);



%analisi dei quantili
spessT = [];
points_L = [];
points_R = [];

j_to_remove = [];


step_riga = size(im_enh,1) / num_campioni;
righe_scelte = round(1 : step_riga : size(im_enh,1));


for j = 1 : numel(righe_scelte)
    %j;
%for j = 14

    %for j = 6
    
    %pause
    
    riga1 = im_enh(righe_scelte(j),:);
   
  
    
    %normalizzazione
    riga1 = riga1 - min(riga1);
    riga1 = riga1 ./ max(riga1);
    
    
    
    %se non c'è almeno un pixel > 128 saltiamo
    idalto = find(riga1 >= 128/255);
    if numel(idalto) < 1
        j_to_remove = [j_to_remove j];
        points_L = [points_L; [-1 -1]];
        points_R = [points_R; [-1 -1]];
        continue
    end
    
    
    
    %cerchiamo il massimo
    maxriga = max(riga1);
    id_maxriga = find(riga1 == maxriga);
    id_maxriga = id_maxriga(1);
    
    %il massimo non può essere troppo lontano dal bordo
    iall = find(riga1 > 0);
    ifirst = iall(1);
    ilast = iall(end); 
    
    if abs(id_maxriga-ifirst) < 5 || abs(id_maxriga-ilast) < 5
        ; %ok
    else
        j_to_remove = [j_to_remove j];
        points_L = [points_L; [-1 -1]];
        points_R = [points_R; [-1 -1]];
        continue
    end
    
    
    
    
    %se ci sono due massimi cerchiamo quello più vicino al bordo
    idriga = find(riga1);
    distmax = 1e6;
    for p = 1 : numel(id_maxriga)
        distc = min(  [ abs(id_maxriga(p) - idriga(1)) abs(id_maxriga(p) - idriga(end)) ] );
        if distc < distmax
            id_maxriga_final = id_maxriga(p);
            distmax = distc;
        end
    end
    id_maxriga = id_maxriga_final;
    
    
    
    %andiamo indietro finchè i valori decrescono
    for h = 0 : 100
        if riga1(id_maxriga-h-1) >= riga1(id_maxriga-h)
            break
        end
    end
    %id_first = id_maxriga - h + 1;
    id_first = id_maxriga - h;
    
    %andiamo avanti finchè i valori decrescono
    for h = 0 : 100
        if riga1(id_maxriga+h+1) >= riga1(id_maxriga+h)
            break
        end
    end
    %id_last = id_maxriga + h - 1;
    id_last = id_maxriga + h;
    
    
    id_new = id_first : 1 : id_last;
    
    
    %se non ci sono punti saltiamo la riga
    if numel(id_new) == 0
        j_to_remove = [j_to_remove j];
        points_L = [points_L; [-1 -1]];
        points_R = [points_R; [-1 -1]];
        continue
    end
    
    

    %riga con picco estratto
    riga1peak = nan(size(riga1));
    riga1peak(id_new) = riga1(id_new);
    %per visualizzazione
    inan = find(isnan(riga1peak));
    riga1plot = riga1peak;
    riga1plot(inan) = 0;
    
    assignin('base','riga1peak',riga1peak);
    assignin('base','riga1plot',riga1plot);
    
    
    %interpolazione subpixel
    upscalefac = 1000;
    xt_interp = 1/upscalefac .* (1:size(riga1plot,2)*upscalefac);
    riga1plot_interp = interp1(1:size(riga1plot,2), riga1plot, xt_interp);
    riga1peak_interp = interp1(1:size(riga1peak,2), riga1peak, xt_interp);
    %normalizzazione
    riga1plot_interp = normalizzaImg(riga1plot_interp);
    
    %whos riga1peak_interp id_new_interp riga1plot_interp
    
    assignin('base','riga1plot_interp',riga1plot_interp);
    assignin('base','riga1peak_interp',riga1peak_interp);
    
    %calcolo il quantile
    q_0_5 = quantile(riga1peak_interp, quantile_spessore);
    
    %divido la riga in due così trovo il massimo sinistro e destro
    max_riga1plot_interp = max(riga1plot_interp);
    imax_riga1plot_interp = find(riga1plot_interp == max_riga1plot_interp);
    iq_0_5_1 = find(riga1plot_interp(1:imax_riga1plot_interp) <= q_0_5);
    iq_0_5_2 = find(riga1plot_interp(imax_riga1plot_interp+1:end) <= q_0_5);
    iq_0_5_2 = iq_0_5_2 + imax_riga1plot_interp;
    
    max1 = max(riga1plot_interp(iq_0_5_1));
    max2 = max(riga1plot_interp(iq_0_5_2));
    
    imax1 = find(riga1plot_interp == max1);
    imax2 = find(riga1plot_interp == max2);
    
    xmax1 = xt_interp(imax1);
    xmax2 = xt_interp(imax2);
    
    
    %iq_0_5_2 = iq_0_5_2 + imax_riga1plot_interp;
    
    
%     iq_0_5 = find(riga1plot_interp <= q_0_5);
%     
%     %%%%%
%     valsq_0_5 = riga1plot_interp(iq_0_5);
%     xvalsq_0_5 = xt_interp(iq_0_5);
%     %%%
%     
%     %estraiamo le coordinate dei due massimi
%     valsq_0_5_sort = sort(valsq_0_5);
%     max1 = valsq_0_5_sort(end);
%     max2 = valsq_0_5_sort(end-1);
%     imax1 = find(valsq_0_5 == max1);
%     xmax1 = xvalsq_0_5(imax1);
%     imax2 = find(valsq_0_5 == max2);
%     xmax2 = xvalsq_0_5(imax2);
    
    
    
    
    if 0
        step = 1;
        figure
        plot(riga1plot, 'r-')
        hold on
        plot(xt_interp(1:step:end), riga1plot_interp(1:step:end))
        hold on
        plot([xmax1 xmax2],[max1 max2], 'bo');
        title([num2str(j) ' - Y: ' num2str(righe_scelte(j)) ' + minY: ' num2str(minY)]);
        pause
    end
    
    
  
   
    
    %aggiungiamo  i punti da matchare
    points_L = [points_L; [xmax1(1) righe_scelte(j)] ]; %(X, Y)
    points_R = [points_R; [xmax2(1) righe_scelte(j)] ]; %(X, Y)
    
    if j == 46 && plotta == 1 && 0
    %if j > 20 && plotta == 1
    %if 0
        limits = 420 : 470;
        %limits = 1 : size(im_enh,2);
        %figure,
        %imshow(im_enh(righe_scelte(j)-100:righe_scelte(j)+100, limits ));
        figure
        plot(limits, riga1(limits), 'LineWidth', 2)
        hold on
        plot([id_new(1) id_new(end)],[riga1(id_new(1)) riga1(id_new(end))], 'ro', 'LineWidth', 3, 'MarkerSize', 10)
        title(['riga n. ' num2str(j)]);
        
        figure
        plot(limits, riga1peak(limits), 'LineWidth', 2)
        hold on
        plot([xmax1 xmax2],[max1 max2], 'ro', 'LineWidth', 3, 'MarkerSize', 10)
        axis([limits(1) limits(end) 0 1])
       
        pause
    end
    
    
end




%invertiamo allineamento
points_L(:,2) = points_L(:,2) + minY;
points_R(:,2) = points_R(:,2) + minY;
im_enh = [zeros(minY-1, size(im_enh,2));  im_enh];




if plotta
    inan = find(points_L(:,1)==-1);
    points_L_plot = points_L;
    points_R_plot = points_R;
    points_L_plot(inan,:) = [];
    points_R_plot(inan,:) = [];
    figure
    %imshow(im_enh)
    imshow(rgb2gray(im))
    hold on
    plot(points_L_plot(:,1),points_L_plot(:,2), 'b-', 'LineWidth', 2)
    hold on
    plot(points_R_plot(:,1),points_R_plot(:,2), 'r-', 'LineWidth', 2)
    pause
end










