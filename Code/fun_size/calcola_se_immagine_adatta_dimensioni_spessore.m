function [adatta_dimensioni, adatta_spessore] = calcola_se_immagine_adatta_dimensioni_spessore(im, im_enh, num_campioni, thMeanQuantileDimensioni, thMeanQuantileSpessore, plotta)




step_riga = size(im,1) / num_campioni;
righe_scelte = round(1 : step_riga : size(im,1));
num_righe = numel(righe_scelte);



%display righe sull'immagine
%imwlines = im;
imwlines = im_enh;
for j = 1 : numel(righe_scelte)
    imwlines(righe_scelte(j), :, :) = 255;
end

%plot immagine
if plotta
    figure,
    imshow(imwlines)
end

%tomografia
num_righe_giuste = 0;
j_giusti = [];
for j = 1 : numel(righe_scelte)
    i_min = find( im_enh(righe_scelte(j),:) > 0);
    if numel(i_min) > 0
        num_righe_giuste = num_righe_giuste + 1;
        j_giusti = [j_giusti j];
    end
end

if 0,
    figure,
    for j = j_giusti
    %for j = j_giusti(1)
        
        i_min = find( im_enh(righe_scelte(j),:) > 0);
        
        riga1 = im_enh(righe_scelte(j),:);
        %normalizzazione
        riga1 = riga1 - min(riga1);
        riga1 = riga1 ./ max(riga1);
        
        subplot(num_righe,1,j)
        plot(riga1);
        
        %plot(im_enh(righe_scelte(j),:));
        
        axis([i_min(1)-100 i_min(end)+100 0 1])
    end
    %pause
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
integraleV = [];
%for j = 1 : numel(righe_scelte)
for j = j_giusti
    
    riga1 = im_enh(righe_scelte(j),:);
    
    %mettiamo a zero elementi negativi
    riga1(riga1 < 0) = 0;
    
    %normalizzazione
    riga1 = riga1 - min(riga1);
    riga1 = riga1 ./ max(riga1);
    
    
    idalto = find(riga1 >= 128/255);
    if numel(idalto) < 1
        continue
    end
    
    %t = quantile(riga1, 0.990);
    
    %integrale per riga
    t = sum(riga1);
    
    %quantile considerando gli elementi diversi da 0
    %t = quantile(riga1(riga1 ~= 0), 0.990)
    
    integraleV = [integraleV t];
    
    %plot(riga1), area(riga1), pause,
    
end

%quantileV

%soglia sulla media dei quantili per scartare le immagini che non vanno
%bene? una soglia 0.5 potrebbe andare bene...
%valore in base al quale decidiamo se l'immagine è adatta per calcolare
%lo spessore
%quantileV(find(quantileV == max(quantileV))) = [];
%quantileV(find(quantileV == min(quantileV))) = [];
%integraleV
meanIntegrale = mean(integraleV);

if meanIntegrale > thMeanQuantileDimensioni
    adatta_dimensioni = 1;
else
    adatta_dimensioni = 0;
end

if meanIntegrale > thMeanQuantileSpessore
    adatta_spessore = 0;
else
    adatta_spessore = 1;
end

%pause
%continue
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%