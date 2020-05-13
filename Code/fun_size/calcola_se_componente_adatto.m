function [adatto] = calcola_se_componente_adatto(im, mask_in)


%inizializziamo
adatto = 1;

%numero componenti connessi
stats = regionprops(mask_in, 'all');

diffConvexArea = stats.ConvexArea - stats.Area;
if diffConvexArea > 10000
    %fprintf(fidr, 'Strand sovrapposti\r\n');
    %fprintf(1, 'Strand sovrapposti\r\n');
    %fclose(fidr);
    adatto = 0;
end



