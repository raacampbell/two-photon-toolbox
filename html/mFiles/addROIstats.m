%% addROIstats
%
% populate twoPhoton object with ROI stats
%
% |function data=addROIstats(data,parallel)|
%
%% Purpose
% Loops through the twoPhoton object, data, and adds a statistics
% field to any relevant structures in data.ROI. This can be used,
% for instance, to the responses of each KC. This requires one to
% have already run selectROIs. Automatically works in parallel if
% multiple cores are attached.
%
%% Inputs
% * |data| - the twoPhoton object which contains an appropriate ROI
% filed in data.ROI. i.e. we should have run selectKCs. 
%
%% Outputs
% The twoPhoton object. So do: |data=addROI_stats(data)|
%
