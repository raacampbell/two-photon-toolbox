function data=addStimParamsSI(data,params)
% Add stimulus parameters to data structure
%
%function data=addStimParamsSI(data,params)
%
% Purpose
% Add stimulus parameters to the twoPhoton object. TEMPORARY FILE
%
% Inputs
% data - the twoPhoton object
% params - a parameter structure of the sort used by Rob's deliver
%          odours routine.
%
% Outputs
% data - the twoPhoton object with a field called "stimuli"
%        containing the stimulus paramsers. 
%
% Rob Campbell 


%Attempt to automatically add stimulus parameters if only one input was provided
if nargin==1
    DIR=data(1).info.rawDataDir;
    FILES=dir([data(1).info.rawDataDir,'/params*']);

    if length(FILES)~=1
        fprintf('Found %d parameter files. Skipping.\n',length(FILES))
        return
    end

    load([DIR,'/',FILES.name])
    addStimParamsSI(data,params);
    return
end

    



%We have a loop here in case in the future we want to particular things with certain fields. 
f=fields(params);
for ii=1:length(data)
    for jj=1:length(f)
        data(ii).stim.(f{jj}) = params.(f{jj});
    end
end
