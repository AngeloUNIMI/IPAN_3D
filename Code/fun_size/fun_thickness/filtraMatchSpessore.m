function [X_A_L, Y_A_L, Z_A_L, X_A_R, Y_A_R, Z_A_R] = filtraMatchSpessore(X_A_L, Y_A_L, Z_A_L, X_A_R, Y_A_R, Z_A_R, soglia)

diffZ = abs(Z_A_L - Z_A_R);

irem = find(diffZ > soglia);

X_A_L(irem) = [];
Y_A_L(irem) = [];
Z_A_L(irem) = [];
X_A_R(irem) = [];
Y_A_R(irem) = [];
Z_A_R(irem) = [];
