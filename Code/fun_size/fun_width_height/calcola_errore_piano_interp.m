function [E, maxE, stdE] = calcola_errore_piano_interp(C, X, Y, Z)


num = size(Z,2);
ZE = ones(1,size(Z,2));
for i=1:size(Z,2)
    ZE(i) = C(1)*X(i)+C(2)*Y(i)+C(3); %valore del piano nei punti considerati
end

D = abs(ZE - Z);  %distanza
E = mean(D);  %errore medio
maxE = max(D);   %distanza massima
stdE = std(D);  %deviazione standard  




