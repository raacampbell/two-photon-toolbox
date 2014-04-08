function varargout=ROI_add(data,notes)
% Append a new ROI to the ROI structure of the twoPhoton object
%
% function data=ROI_add(data,notes)
%
% PURPOSE
%   Add a new region of interest to the data structure by allowing
%   the user to select a region of interest
%   manually. Alternatively, this function will add pre-calculated
%   ROIs if the second input argument, notes, is a structure.
%
% INPUTS
%  data - the twoPhoton object
%  notes - an optional text string with which to identify the
%          ROI. If this text string already exists, then this ROI
%          is updated (replaced) with the one the user now selects.
%          Alternatively, notes can be the following the structure,
%          which allows one or more ROIs to be added
%          -notes.roi (dimensions, x, y, roiIndex)
%          -notes.names (optional cell array of names)
%          -notes.ind (optional list of indecies defining which
%           entries of data to recieve the new ROIs. By default they
%           all will receive the new ROIs). 
%     
%          
% 
% OUTPUTS
%  Returns the "data" structure with added ROI. 
%  e.g. 
%  length(data.ROI) goes from 1 to 2 following this function
%
% 
% Rob Campbell, March 2009
  
  
if nargin<2
    notes='';
end


%add pre-calculated ROIs, if those are what we have
if isstruct(notes)
  if length(notes)>1
    for ii=1:length(notes)
      data=ROI_add(data,notes(ii));
    end
    return
  end
  
  n=size(notes.roi,3); %number of ROIs to add

  if ~isfield(notes,'names')
    notes.names=repmat({''},1,n);    
  else
    if n ~= length(notes.names)
      error('number of ROIs and number of names should be equal')
    end    
  end
  
  if ~isfield(notes,'ind')
    notes.ind=1:length(data);
  end
  ind=notes.ind;

  
  %The ROI structure
  ROI.level=nan;
  ROI.roi=[];
  ROI.notes=[];
  ROI.backgroundLevel=nan;
  ROI.stats=[];

  %now add the ROIs, appending as needed
  for ii=1:length(ind)
    
    for jj=1:n
      ROI.roi=notes.roi(:,:,jj);
      ROI.notes=notes.names{jj};
      
      s=strmatch(notes.names{jj}, {data(ind(ii)).ROI(:).notes});
      if isempty(s) || length(notes.names{jj})>0
        data(ind(ii)).ROI(end+1)=ROI;
      else
        data(ind(ii)).ROI(s)=ROI;
      end
    end

  end
  
  return    
end


    
    
%Get user to select region of interest from the average image
clf
if isfield(data(1).info,'muStack')
    img=data(1).info.muStack(:,:,end);
else    
    imageStack=data(1).imageStack;
    img=mean(imageStack,3);
end


colormap gray 

imagesc(img),axis equal, axis off
title('* SELECT ROI *');       
BW=roipoly; 
title('')


%Structure for output
ROI.level=nan;
ROI.roi=BW;
ROI.notes=notes;
ROI.backgroundLevel=nan;
ROI.stats=[];

%Add notes
tmp=data.ROI;
if ~isfield(tmp(1),'notes')
    for ii=1:length(tmp)
        tmp(ii).notes='';
    end
end



%Either append or replace the ROI depending on whether or not it
%already exists (as defined by the "notes" field). 


%Append ROI
for ii=1:length(data)
    if ~isfield(data(ii).ROI(1),'notes')
        data(ii).ROI(1).notes='';
    end
    if ~isfield(data(ii).ROI(1),'backgroundLevel')
        data(ii).ROI(1).backgroundLevel='';
    end
    if ~isfield(data(ii).ROI(1),'stats')
        data(ii).ROI(1).stats=[];
    end

    s=strmatch(notes,{data(ii).ROI(:).notes});
    if isempty(s)
        data(ii).ROI(end+1)=ROI;
    else
        data(ii).ROI(s)=ROI;
    end
    
end


if nargout==1
  varargout{1}=data;
end
