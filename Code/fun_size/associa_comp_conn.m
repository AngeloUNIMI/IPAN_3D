function [maskB_new] = associa_comp_conn(maskA, maskB)


%funzione che data un'immagine binaria (con 1 solo componente connesso) e un'altra immagine con più comp connessi
%restituisce un'immagine con solo il comp connesso con area più simile


statsA = regionprops(maskA, 'all');
numStrandA = numel(statsA);
[LA, numA] = bwlabel(maskA, 8);


statsB = regionprops(maskB, 'all');
numStrandB = numel(statsB);
[LB, numB] = bwlabel(maskB, 8);




areaRefA = statsA.Area;
distmin = 1e10; %inizializziamo la differenza minima tra le aree
compSceltoB = [];

for j = 1 : numStrandB
    areaB = statsB(j).Area;
    distAree = abs(areaRefA - areaB);
    
    if distAree < distmin
        distmin = distAree;
        compSceltoB = j;
    end %end if distAree < distmin
end %for j = 1 : numStrandB



maskB_new = LB == compSceltoB;



