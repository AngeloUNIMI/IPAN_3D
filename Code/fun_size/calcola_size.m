function [majAxis, minAxis, thickness, maskboth, retvalue, features_thickness, features_length, features_width] = ...
    calcola_size(imA, imB, stereoParams, H4, screen_size, height_plot)

%init
features_thickness = [];
features_length = [];
features_width = [];

%parametri
plotta = 0;
retvalue = 1;

%valore in base al quale decidiamo se l'immagine è adatta per calcolare lo spessore
thMeanQuantileSpessore = 10;
%valore in base al quale decidiamo se l'immagine è adatta per calcolare le dimensioni
thMeanQuantileDimensioni = 20;
%numero righe da considerare (100)
num_campioni = 100;
%numero di vicini per lo spikefilter 3d
nNeigh3d = 3;
%quantile in base al quale tagliare il picco per lo spessore
quantile_spessore = 0.85;
%range per contrast enhancement
lims = [0.3; 1];

%inizializziamo
majAxis = [];
minAxis = [];
thickness = [];
maskboth = [];



%imA
imA = im2double(imA);

%segmentation
[maskA_orig, retvalue_segm] = segmenta_strand_blue(imA);
if retvalue_segm == -1
    retvalue = -1;
%     majAxis = 0;
%     minAxis = 0;
%     thickness = 0;
    maskboth{1} = maskA_orig;
    maskboth{2} = maskA_orig;
end %end if retvalue_segm == -1
    
%maskA = segmenta_strand_gray(imA);

%estraiamo i componenti connessi
statsA = regionprops(maskA_orig, 'all');
numStrandA = numel(statsA);
[LA, numA] = bwlabel(maskA_orig, 8);

%imB
imB = im2double(imB);

%segmentation
[maskB_orig, retvalue_segm] = segmenta_strand_blue(imB);
if retvalue_segm == -1
    retvalue = -1;
%     majAxis = 0;
%     minAxis = 0;
%     thickness = 0;
    maskboth{1} = maskB_orig;
    maskboth{2} = maskB_orig;
    return;
end %end if retvalue_segm == -1
%maskB = segmenta_strand_gray(imB);


%estraiamo i componenti connessi
statsB = regionprops(maskB_orig, 'all');
numStrandB = numel(statsB);
[LB, numB] = bwlabel(maskB_orig, 8);



maskboth{1} = maskA_orig;
maskboth{2} = maskB_orig;


%controllo che il numero di componenti connessi sia uguale nelle due
%immagini
if (numStrandA ~= numStrandB)
    return
end


% assignin('base', 'maskA_orig', maskA_orig);
% assignin('base', 'maskB_orig', maskB_orig);
% pause




%ciclo sui componenti connessi
for l = 1 : numStrandA
    
    %selezioniamo un componente connesso alla volta
    %bisogna scegliere quello più simile - non sono ordinati uguale
    maskA = (LA == l);
    %gli do la maskA con estratto il solo componente connesso che voglio, e
    %la maskB con tutti i comp connessi, così scelgo
    maskB = associa_comp_conn(maskA, maskB_orig);
    
    
%     figure, imshow(maskA);
%     figure, imshow(maskB);
%     pause
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %CICLO SULLE DUE IMMAGINI (A E B)
    
    %switch che va 1 nel caso la prima immagine non vada bene,
    %così non elabora la seconda
    two_view_image_ok_spessore = 1;
    two_view_image_ok_dimensioni = 1;
    
    
    %ciclo sulle due immagini A e B ed elaboro
    for secondimg = 0 : 1
        
        if secondimg == 0
            %fprintf(1, 'Immagine sinistra...\n');
            %mask = maskA;
            %im = imA;
        else
            %fprintf(1, 'Immagine destra...\n');
            %mask = maskA;
            %im = imB;
        end
        
        if two_view_image_ok_spessore == 0 && two_view_image_ok_dimensioni == 0
            continue
        end
        
        if secondimg == 0
            im = imA;
            mask = maskA;
        else %if secondimg == 0
            im = imB;
            mask = maskB;
        end %if secondimg == 0
        imgray = rgb2gray(im);
        imr = im(:,:,1);
        img = im(:,:,2);
        imb = im(:,:,3);
        
        
        
        
        
        %pause
        %visual img
        if plotta
            figure,
            imshow(im);
            %pause
        end
        
        
        %segmentation
        %mask = segmenta_strand_blue(im);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %mask = segmenta_strand_gray(im);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        
        if 1
            handle{secondimg+1} = figure;
            imshow(mask)
        end 
        if secondimg == 0
            title(['mask del componente n. ' num2str(l) ' - A']);
            set(handle{1},'Position',[screen_size(3)/3+10 (screen_size(4)-height_plot-35) screen_size(3)/3 height_plot]);
        else 
            title(['mask del componente n. ' num2str(l) ' - B']);
            set(handle{2},'Position',[screen_size(3)/3+10 (screen_size(4)-(height_plot+35)*2-0) screen_size(3)/3 height_plot]);
        end
        
        
        
        %enhancement
        im_enh = im_enhance(imr, lims, mask, plotta);
        
        %correggiamo le distorsioni
        [im, ~] = undistortImage(im,stereoParams.CameraParameters1);
        [imgray, ~] = undistortImage(imgray,stereoParams.CameraParameters1);
        [mask, ~] = undistortImage(mask,stereoParams.CameraParameters1);
        [im_enh, ~] = undistortImage(im_enh,stereoParams.CameraParameters1);
        
        
        %rettifichiamo l'immagine A
        if secondimg == 0
            transform_A_in_B = maketform('projective',(H4)');
            
            [im, ~, ~] = imtransform(im, transform_A_in_B, 'bicubic', 'xData', [1, size(im,2)], 'yData', [1, size(im,1)] );
            [imgray, ~, ~] = imtransform(imgray, transform_A_in_B, 'bicubic', 'xData', [1, size(imgray,2)], 'yData', [1, size(imgray,1)] );
            [mask, ~, ~] = imtransform(mask, transform_A_in_B, 'bicubic', 'xData', [1, size(mask,2)], 'yData', [1, size(mask,1)] );
            [im_enh, ~, ~] = imtransform(im_enh, transform_A_in_B, 'bicubic', 'xData', [1, size(im_enh,2)], 'yData', [1, size(im_enh,1)] );
            
            %togliamo eventuali valori negativi dopo la trasformazione
            im_enh(im_enh<0) = 0;
            
            imr = im(:,:,1);
            img = im(:,:,2);
            imb = im(:,:,3);
        end
        
        %può essere che le trasformazioni creino un'altra regione connessa
        mask = connComp2(mask, 1, 1);
        
        
        %pause
        %calcoliamo il valore minimo di Y per allineamento
        minY = calcola_min_Y(mask);
        
        
        
        %calcoliamo se il componente è adatto per essere elaborato
        componente_adatto = calcola_se_componente_adatto(im, mask);
        if componente_adatto == 0
            %fprintf(1, 'Strand sovrapposti... \r\n');
            %fprintf(fid1, 'Strand sovrapposti... \r\n');
            two_view_image_ok_dimensioni = 0;
            two_view_image_ok_spessore = 0;
            %fclose(fid1);
            continue
        end
        
        
        %calcoliamo se l'immagine è adatta per calcolare le dimensioni e lo spessore
        [adatta_dimensioni, adatta_spessore] = ...
            calcola_se_immagine_adatta_dimensioni_spessore(im, im_enh, num_campioni, thMeanQuantileDimensioni, thMeanQuantileSpessore, plotta);
        
        
        
        if two_view_image_ok_spessore == 1 && adatta_spessore == 0 %o è la prima immagine oppure la prima andava bene ma la seconda no
            %fprintf(1, 'Componente non adatto per calcolare lo spessore... \n');
            %fprintf(fid1, 'Componente non adatto per calcolare lo spessore... \r\n');
            two_view_image_ok_spessore = 0;
        end
        
        if two_view_image_ok_dimensioni == 1 && adatta_dimensioni == 0 %o è la prima immagine oppure la prima andava bene ma la seconda no
            %fprintf(1, 'Componente non adatto per calcolare le dimensioni... \n');
            %fprintf(fid1, 'Componente non adatto per calcolare le dimensioni... \r\n');
            two_view_image_ok_dimensioni = 0;
        end
        
        
        %se non si può calcolare nè spessore nè dimensioni saltiamo
        if two_view_image_ok_spessore == 0 && two_view_image_ok_dimensioni == 0
            %fclose(fid1);
            continue
        end
        
        if two_view_image_ok_spessore == 1
            [punti_per_spessore_L, punti_per_spessore_R, j_to_remove] = calcola_punti_per_spessore(num_campioni, im, im_enh, plotta, minY, quantile_spessore);
            %nomi giusti alle variabili in base a immagine A o B
            if secondimg == 0
                punti_per_spessore_A_L = punti_per_spessore_L;
                punti_per_spessore_A_R = punti_per_spessore_R;
                j_to_remove_A = j_to_remove;
            end
            if secondimg == 1
                punti_per_spessore_B_L = punti_per_spessore_L;
                punti_per_spessore_B_R = punti_per_spessore_R;
                j_to_remove_B = j_to_remove;
            end
        end
        
        
        
        if secondimg == 0
            imAgray = imgray;
            imA_enh = im_enh;
            maskA = mask;
            minYA = minY;
        else
            imBgray = imgray;
            imB_enh = im_enh;
            maskB = mask;
            minYB = minY;
        end
        
        
    end %end for secondimg
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %FINE CICLO SULLE DUE IMMAGINI (A E B)
    
%     two_view_image_ok_spessore
%     two_view_image_ok_dimensioni
%     
    %CALCOLO VALORI FINALI IN 3D USANDO LE INFORMAZIONI DI TUTTE E DUE LE IMMAGINI
    %se non si può calcolare nè spessore nè dimensioni saltiamo
    if two_view_image_ok_spessore == 0 && two_view_image_ok_dimensioni == 0
        %fclose(fid1)
        continue
    end %if two_view_image_ok_spessore == 0 && two_view_image_ok_dimensioni == 0
    
    %se è ok spessore calcolo
    if two_view_image_ok_spessore == 1
        %fprintf(1, 'CALCOLO SPESSORE...\n');
        [spess_mean_img_mm, features_thickness] = calcola_spessore_two_view(j_to_remove_A, j_to_remove_B, punti_per_spessore_A_L, punti_per_spessore_A_R, ...
            punti_per_spessore_B_L, punti_per_spessore_B_R, transform_A_in_B, stereoParams, minYA, minYB, plotta, screen_size, height_plot);
        %fprintf(1, 'Spessore in mm: \n');
        %fprintf(1, '%f\n', spess_mean_img_mm);
        %         if savefile
        %             fprintf(fid1, 'Spessore in mm: \r\n');
        %             fprintf(fid1, '%f', spess_mean_img_mm);
        %         end %end if savefile
        thickness = [thickness spess_mean_img_mm];
    end %two_view_image_ok_spessore == 1
    
    %se è ok dimensioni calcolo
    if two_view_image_ok_dimensioni == 1
        %fprintf(1, 'CALCOLO DIMENSIONI...\n');
        %match silhouette
        [match_A, match_B, dist_A_T, dist_B_T, iAt, iBt] = match_punti_silhouette(imA_enh, maskA, imB_enh, maskB, plotta, minYA, minYB);
        %triangolazione e calcolo dimensioni
        [Lunghezza_calcolata, Larghezza_calcolata, features_length, features_width, code] = ...
            calcola_dimensione_strand(maskA, stereoParams, transform_A_in_B, match_A, match_B, imA, imA_enh, imB, imB_enh, nNeigh3d, plotta, screen_size, height_plot);
        if code == 0
            %fprintf(1, 'Impossibile ricostruire modello 3D\n');
            %fprintf(fid1, 'Impossibile ricostruire modello 3D\n');
        else %if code 0
            %fprintf(1, 'Lunghezza calcolata: \n');
            %fprintf(1, '%f\n', Lunghezza_calcolata);
            %fprintf(1, 'Larghezza calcolata: \n');
            %fprintf(1, '%f\n', Larghezza_calcolata);
%             if savefile
%                 fprintf(fid1, 'Lunghezza calcolata: \r\n');
%                 fprintf(fid1, '%f\r\n', Lunghezza_calcolata);
%                 fprintf(fid1, 'Larghezza calcolata: \r\n');
%                 fprintf(fid1, '%f\r\n', Larghezza_calcolata);
%             end %if savefile
            majAxis = [majAxis Lunghezza_calcolata];
            minAxis = [minAxis Larghezza_calcolata];
        end %end if code 0
        
    end %if two_view_image_ok_dimensioni == 1
    
    
    
    
end %for numstrand


%calcolo media sui componenti
if numel(majAxis) > 0
    majAxis = mean(majAxis);
end
if numel(minAxis) > 0
    minAxis = mean(minAxis);
end
if numel(thickness) > 0
    thickness = mean(thickness);
end
