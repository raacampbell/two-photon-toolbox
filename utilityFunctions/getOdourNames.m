function [odours,uniqueOdours,oInd]=getOdourNames(data,splitConcs)
% Summarise stimuli used in one experiment
%
% function [odours,uniqueOdours,oInd]=getOdourNames(data)
%
% Purpose
% A time-saving function to report which odour was presented for
% each stimulus, the unique odours presented, and the indecies at
% which each of these odours appear. 
%
% Outputs
% odours - the presented odour for each stimulus
% uniqueOdours - simply unique(odours) 
% oInd - the indecies of the data structure containing each
%              odour.
%
% Inputs
% data - the twoPhoton data object
% splitConcs - if 1 (default) then data from different
%              concentrations are treated as different. 
% NOTE: 
% if only one output argument is called then odours will be a
% structure containing this information. This structure will
% potentially be more useful but too much code uses the 3 separate
% arguments so this function will be backwards compatable for
% now. The 3 args are DEPRECATED so use the odours structure if
% possible. 
%
%
% Rob Campbell - November 2009
    

if nargin<2 & isfield(data(1).stim,'totalDilution')
    splitConcs=1;
else
    splitConcs=0;
end

    

%Note to self: At no time sort these neurons here in any way because that
%              will fuck up other functions.
for ii=1:length(data)
    odours{ii}=data(ii).stim.odour;
    if splitConcs & ~isempty(data(ii).stim.totalDilution)
        odours{ii}=[odours{ii},'_',...
                    num2str(round(data(ii).stim.totalDilution))];
    end
end

uniqueOdours=sort(unique(odours)); %To be neat, we sort into alphabetical order


%oInd of each unique odour
for ii=1:length(uniqueOdours)
    oInd{ii}=strmatch(uniqueOdours{ii},odours,'exact');
end






if nargout==1
    tmp.odours=odours;
    tmp.uOdours=uniqueOdours;
    tmp.oInd=oInd;
    odours=tmp;
elseif nargout>2
    calls=dbstack('-completenames');
    fprintf('%s called getOdourNames using old style output. see "help getOdourNames"\n',...
        calls(2).file)
end

   
