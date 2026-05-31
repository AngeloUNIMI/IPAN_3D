function [matchLf, matchRf, Xf, Yf, Zf] = spikefilter3d_plane(matchL, matchR, X, Y, Z, C)


num = size(Z,2);
ZE = ones(1,size(Z,2));

indexrem = [];
for i=1:numel(Z)
    ZE(i) = C(1)*X(i)+C(2)*Y(i)+C(3); %valore del piano nei punti considerati
      if abs(Z(i) - ZE(i)) > 5
        indexrem = [indexrem i];
    end,
end

Xf = X; Xf(indexrem) = [];
Yf = Y; Yf(indexrem) = [];
Zf = Z; Zf(indexrem) = [];

matchLf = matchL; matchLf(indexrem,:) = [];
matchRf = matchR; matchRf(indexrem,:) = [];