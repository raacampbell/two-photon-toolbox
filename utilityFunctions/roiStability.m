function [stability,groups]=roiStability(data,ROIindex)
% function [stability,groups]=roiStability(data,ROIindex)
%
% Purpose
% Are the ROIs in index "roiIndex" the same in all recordings?
% 
% Inputs
% data - twoPhoton data structure.
% roiIndex - the index to analyse. By default (or if empty) this is
% the soma field. 
%
% Outputs
% stability - returns 1 if the ROIs are the same in all recordings 
% groups - vector indicating which indecies share the same ROIs. 
%
% Rob Campbell - January 2011


%Check arguments
if nargin<2 | isempty(ROIindex), ROIindex='soma'; end   
if ischar(ROIindex)
    ROIindex=strmatch(ROIindex,{data(1).ROI.notes});
end


%Extract ROI profiles
tmp=ones(length(data),size(data(1).ROI(ROIindex).roi,1));
for ii=1:length(data)
    s=sum(data(ii).ROI(ROIindex).roi,3);
    tmp(ii,:)=sum(s,2);
end


%Check whether ROIs are stable across recordings
[~,stability,groups]=unique(tmp,'rows');
stability=length(stability);
if stability>1, stability=0; end

    
