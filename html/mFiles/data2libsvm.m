%% data2libsvm
% convert twoPhoton data to libsvm format
%
% |function info=data2libsvm(data,fname)|
%
%% Purpose
% Convert the mean evoked response of each KC to a text file
% suitable for use with <http://www.csie.ntu.edu.tw/~cjlin/libsvm/ libsvm>. 
%
%% Input
% * |data| - Either the twoPhoton object or a structure with the
% followings fields: |data.kc|, output of kcResponseMatrix; |data.S|,
% output of getOdourNames(data). If this is done, you will need to
% specify the file name. The purpose of allowing the second input
% format is to give the user flexibility in modifying the data to be
% classified. e.g. removing neurons. 
% * |fname| - optional name for the svm file. By default, a file name
% based on the data structure is chosen. It will choose the suffix
% "svm".
%
%% Outputs
% * |info| - An optional structure listing the filename of the svm
% file, and the mapping of odour name to cluster number (libsvm
% wants groups numbered as strings)
