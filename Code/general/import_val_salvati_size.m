function [Mean, status] = import_val_salvati_size(filename, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as column vectors.
%   MEAN = IMPORTFILE(FILENAME) Reads data from text file FILENAME for the
%   default selection.
%
%   MEAN = IMPORTFILE(FILENAME, STARTROW, ENDROW) Reads data from rows
%   STARTROW through ENDROW of text file FILENAME.
%
% Example:
%   Mean = importfile('2015-06-10 17-13-03 CAM 1_Segm.txt',[3,5,7,9], [3,5,7,9]);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2015/06/10 18:02:01

%% Initialize variables.
delimiter = ' ';
if nargin<=2
    startRow = [2,4];
    endRow = [2,4];
end
status = 1;

%% Format string for each line of text:
%   column1: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%f%*s%*s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');
if fileID == -1
    Mean = -1;
    status = -1;
    return;
end

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    dataArray{1} = [dataArray{1};dataArrayBlock{1}];
end

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
Mean = dataArray{:, 1};

