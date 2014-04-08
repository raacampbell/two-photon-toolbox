function data=addKC_stats(data)
% populate twoPhoton object with cell statistics
%
% function data=addKC_stats(data)
%
% Purpose
% Loops through the twoPhoton object, data, and adds to it a makes
% a "KCstats" structure which describes the responses of each
% KC. This requires one to have already run selectKCs, which
% creates a set of neuron masks in data.KCmasks.  
%
% Inputs
% data - the twoPhoton object with data.KCmasks present. 
%
% Outputs
% Function updates data without explicitly requiring one to state:
% data=addKC_stats(data);
%
%
% Rob Campbell, August 2009
  
  
fprintf('Calculating KC stats ')

warning off

for ii=1:length(data)
  fprintf('.')
  if isempty( strmatch('KCstats',properties(data(ii))) )
    addprop(data(ii),'KCstats');
  end
  data(ii).KCstats=KCdFF(data(ii));
end

warning on

fprintf('\n')
