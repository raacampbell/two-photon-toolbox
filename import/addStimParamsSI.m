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
% Rob Campbell - Basel - 2014


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

    

%Loop through the parameters structure 
%We take into account params structures with multiple levels
n=1;
for ii=1:length(params)
	p=params(ii);
  	f=fields(p);
  	%There's bound to be an ISI field, so let's use this to determine the number of stimuli
  	for s=1:length(p.isi)
  		%add all fields
  		for jj=1:length(f)
  			thisParameter=params.(f{jj});
  			if length(thisParameter)>1 & (isnumeric(thisParameter) | iscell(thisParameter))
  				thisParameter=thisParameter(s);
  			end
  			data(n).stim.(f{jj})=thisParameter;
  		end
  		n=n+1;
  	end
end




%If there are odors here, we will try to add a stim.odor field as some subsequent commands
%expect it. This is rather ugly and non-flexible because not all experiments will have odors. 
%Some will have tastes. It would be nicer if the field was called "stimName" or similar. 
%Let's go with the field name "odor" for now, however. [23/06/2104]
for ii=1:length(data)
	if ~isfield(data(ii).stim,'odourNames')
		%If this structure doesn't exist then we can't add an odor name
		%since we won't know what to call the odor (even if one was there)
		continue
	end
   data(ii).stim.odour=data(ii).stim.odourNames(data(ii).stim.odours).odour;
end
