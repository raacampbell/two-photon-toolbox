%%  selectROIs(
% Select neuronal cell bodies with a GUI
%
% |function varargout = selectKCs(varargin)|
%
% |selectKCs| allows the user to select cells in the image by
% interactively clicking on them. 
%
% The zoom may not work, but if it does then the red cross button on
% the toolbar allows you to go out of the zoom or pan modes and back
% into the clicking mode. 
% 
%% Inputs
% * |data| - the twoPhoton data structure we will work o
% * |ROI| - a optional string defining the type of ROI being
% selected. By default this is 'soma'. If this ROI type already
% exists in data.ROI then it will be replaced by the newly clicked
% ROI data. If it does not exist then it will be appended and
% labeled with the supplied name (ROI). 
% depth - if the recording has multiple depths then work only on
% the depth defined by this scalar. depth equal 1 by default.
%    
%   
%% Usage
% |data = selectKCs(data);|
% Where data is the output from generateDFFobject. 
%
%% Output 
% If |data| has length 1 then the function returns the array but adds
% the field KCmasks, which contains the clicked data. This can
% serve as an input to ROIstats.m to calculate dF/F for individual
% cells. 
% If |data| has length>1 then cell clicking is performed on an image
% which is the mean over all stimulus presentations (cells that
% move will look blurry). Following each click the background
% animates to show whether or not the clicked area is stable over
% time. This one set of KC locations is then applied to all
% stimulus presentations. 
%
%% Credits
% Eyal Gruntman 

