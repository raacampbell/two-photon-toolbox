%% plotROIstats
% Summary plot of the data produced by KCdFF. 
%
% |function plotROIstats(data,sortType,stats)|
%
%% Purpose
% Makes pretty summary plot of the data produced by ROIstats.
% 
%% Inputs  
% * |data| - one instance of the twoPhoton object
% * |sortType| [optional, 'sigRank' by default] - 
%    how to sort the KC responses in the colour plot. 
% # 'sigRank' - by the number of frames significantly above baseline.
% # 'pattern' - by response pattern.
% # 'none'    - no sorting.     
% * |stats| - The stats field to plot can be specified here. Either
%           as an index number (data.ROI(stats)) or as a name (see
%           the notes field in .ROI). By default stats is the
%           string "soma". Finally, stats can be the actual stats
%           structure itself, e.g. data(1).ROI(2).stats
%
%
%% Example

cd ~/work/Matlab_Scripts/ImagingAnalysis/examples/
load KCexample.mat
plotROIstats(data(2))
