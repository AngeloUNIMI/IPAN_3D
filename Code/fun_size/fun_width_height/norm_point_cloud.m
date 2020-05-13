function [X_norm, Y_norm, Z_norm] = norm_point_cloud(X, Y, Z)


X_temp = X;
Y_temp = Y;
Z_temp = Z;

X_temp = X_temp - mean(X_temp);
Y_temp = Y_temp - mean(Y_temp);
Z_temp = Z_temp - mean(Z_temp);
[Z_temp, Iss] = sort(Z_temp);
Y_temp = Y_temp(Iss);
X_temp = X_temp(Iss);

X_norm = X_temp;
Y_norm = Y_temp;
Z_norm = Z_temp;

