function stim=getStimNames(data,stimName)
% Summarise stimuli used in one experiment
%
% function stim=getStimNames(data,stimName)
%
% Purpose
% The is a generalised version of the function "getOdourNames". It
% summarises stimulus information based upon the field "stimName"
% in data.stim. The purpose of this is to allow plotting and
% analysis programs to group data obtained with the same
% stimulus. By default, "stimName" is the string "odour" and so
% this function will work in much the same was getOdourNames (which
% we retain for legacy purposes). 
%
%
% Inputs
% data - the twoPhoton data object
% stimName - a string defining the name of the field to treat as
%            the stimulus. 
%
%
% Outputs
% odours - the presented odour for each stimulus
% uniqueOdours - simply unique(odours) 
% oInd - the indecies of the data structure containing each
%              odour.
%
%
% Rob Campbell - June 2013
    

    

%Note to self: At no time sort these neurons here in any way because that
%              will fuck up other functions.

if nargin < 2
    stimName='odour';
end

%Attempt to find the stimulus, then fail 
if ~isfield(data(1).stim,stimName)
    stimName='stimulus';
    if ~isfield(data(1).stim,stimName)
        stim=[];
        return
    end
    fprintf('Changing stimName to %s\n', stimName)
end

    
for ii=1:length(data)
    stims{ii}=data(ii).stim.(stimName);
end

%To be neat, we sort (e.g. into alphabetical order)
if isstr(stims{1})
    uniqueStims=sort(unique(stims));
else
    tmp=sort(unique([stims{:}]));
    for ii=1:length(tmp)
        uniqueStims{ii}=tmp(ii);
    end
end


%sInd of each unique stimulus
for ii=1:length(uniqueStims)
    if isstr(uniqueStims{1}) %We assume the user isn't mixing data types
        sInd{ii}=strmatch(uniqueStims{ii},stims,'exact');
    else
        sInd{ii}=find([stims{:}]==uniqueStims{ii});
    end
    
end






if nargout==1
    stim.stims=stims;
    stim.uStims=uniqueStims;
    stim.sInd=sInd;
end

   
