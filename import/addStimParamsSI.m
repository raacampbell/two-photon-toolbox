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

f=fields(params);
for ii=1:length(data)
    for jj=1:length(f)
        data(ii).stim.(f{jj}) = params.(f{jj});

    end
end
