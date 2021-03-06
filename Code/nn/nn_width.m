function [y1] = nn_width(x1)
%MYNEURALNETWORKFUNCTION neural network simulation function.
%
% Generated by Neural Network Toolbox function genFunction, 16-Jun-2016 12:45:47.
%
% [y1] = myNeuralNetworkFunction(x1) takes these arguments:
%   x = Qx8 matrix, input #1
% and returns:
%   y = Qx1 matrix, output #1
% where Q is the number of samples.

%#ok<*RPMT0>

% ===== NEURAL NETWORK CONSTANTS =====

% Input 1
x1_step1.xoffset = [24;28.0294141583538;3144;317.895;9.89005803803143;3.80795463509266;-9.93781077893583e-05;-5.81819398197894e-05];
x1_step1.gain = [0.133333333333333;0.112738898047696;0.00073909830007391;0.0351345653854262;0.327865726618733;0.911127959254476;5429.56849758427;8149.65422816111];
x1_step1.ymin = -1;

% Layer 1
b1 = [-3.1797661408459459;3.6595276062709958;0.28855756258713561];
IW1_1 = [0.94019903896429258 2.0161168556957798 -1.1092896187743797 -2.1815308976381589 -0.1932941548460507 -1.0675754359246812 2.3346592387089316 3.463759468000847;4.4783566655553786 3.7818251914926186 -1.1502756700493149 2.3966576631953624 -0.68170516221200927 0.52764246065813425 1.4203090856308651 1.5689028412254808;-1.8477228018911913 1.3789958813129159 1.3773663375730969 0.90715123373594964 1.3208398527516136 0.54533574533117912 -0.79919390443808547 0.82450065845528409];

% Layer 2
b2 = -0.044912854288567138;
LW2_1 = [0.12056089901909813 1.2767416543094439 -0.41683331490012115];

% Output 1
y1_step1.ymin = -1;
y1_step1.gain = 0.4;
y1_step1.xoffset = 16;

% ===== SIMULATION ========

% Dimensions
Q = size(x1,1); % samples

% Input 1
x1 = x1';
xp1 = mapminmax_apply(x1,x1_step1);

% Layer 1
a1 = tansig_apply(repmat(b1,1,Q) + IW1_1*xp1);

% Layer 2
a2 = repmat(b2,1,Q) + LW2_1*a1;

% Output 1
y1 = mapminmax_reverse(a2,y1_step1);
y1 = y1';
end

% ===== MODULE FUNCTIONS ========

% Map Minimum and Maximum Input Processing Function
function y = mapminmax_apply(x,settings)
y = bsxfun(@minus,x,settings.xoffset);
y = bsxfun(@times,y,settings.gain);
y = bsxfun(@plus,y,settings.ymin);
end

% Sigmoid Symmetric Transfer Function
function a = tansig_apply(n,~)
a = 2 ./ (1 + exp(-2*n)) - 1;
end

% Map Minimum and Maximum Output Reverse-Processing Function
function x = mapminmax_reverse(y,settings)
x = bsxfun(@minus,y,settings.ymin);
x = bsxfun(@rdivide,x,settings.gain);
x = bsxfun(@plus,x,settings.xoffset);
end
