function [per_keep_recenti, per_keep_storici, exposure, gain, num_img_burst, ...
    desired_mean_major_axis, desired_mean_minor_axis, desired_mean_thickness, ...
    toll_mean_major_axis, toll_mean_minor_axis, toll_mean_thickness, time_wait_save] = acquisisci_parametri_tutti(fileParametriTutti)



filename = fileParametriTutti;
delimiter = ' ';
if nargin<=2
    startRow = [2,4,6,8,10,12,14,16,18,20,22,24];
    endRow = [2,4,6,8,10,12,14,16,18,20,22,24];
end

% Format string for each line of text:
%   column1: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%f%*s%*s%*s%*s%*s%*s%[^\n\r]';

% Open the text file.
fileID = fopen(filename,'r');

% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    dataArray{1} = [dataArray{1};dataArrayBlock{1}];
end

% Close the text file.
fclose(fileID);

% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

% Create output variable
fileParametriTutti1 = [dataArray{1:end-1}];



per_keep_recenti = fileParametriTutti1(1);
per_keep_storici = fileParametriTutti1(2);
exposure = fileParametriTutti1(3);
gain = fileParametriTutti1(4);
num_img_burst = fileParametriTutti1(5);
desired_mean_major_axis = fileParametriTutti1(6);
desired_mean_minor_axis = fileParametriTutti1(7);
toll_mean_major_axis = fileParametriTutti1(8);
toll_mean_minor_axis = fileParametriTutti1(9);
desired_mean_thickness = fileParametriTutti1(10);
toll_mean_thickness = fileParametriTutti1(11);
time_wait_save = fileParametriTutti1(12);


