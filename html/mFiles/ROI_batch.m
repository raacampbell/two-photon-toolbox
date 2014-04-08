%% ROI_batch
% Determine the main ROI for each stimulus presentation
%
% |function data=ROI_batch(data,autoApply)|
%
%% Purpose
% Automatically determine the region of interest
% (ROI). i.e. segregate brain from background. By default we do
% this for the first response only and then copy this ROI to
% all other responses. This is reasonable if the recording was
% fairly stable. 
%  
%% Inputs
% * |data| - the twoPhoton object containing the movement-corrected
% data.  
% * |autoApply| -  [optional, 1 by defualt]. If ==1 it applies the ROI
% from the first recording to all the others. If ==0 the user
% specifies a different ROI for each recording. 
