function varargout=params2dataset(data,verbose)

% Extract the stimulus parameters and convert to dataset
%
% function stimParams=params2dataset(data,verbose)
%
% Inputs
% data - twoPhoton data object
% verbose [optional bool] - 1 by default. If 1 we display the parameter 
%  dataset to screen. You can visualise the output in an interactive 
%  way with the openvar command. 
%
%
% Outputs
% stimParams [optional] - the data set is optionally returned to the user. 
%
% 
%
% Rob Campbell - Basel - July 2014


if nargin==0
	error('One input argument needed')
end

if nargin<2
	verbose=1;
end

tempStimStruct=data(1).stim;
tempStimStruct.index=1;
for ii=2:length(data)
	tmp=data(ii).stim;
	tmp.index=ii;
	tempStimStruct(ii,1)=tmp;
end
clear tmp


%Structures within the structure are unlikely to be interesting and will 
%screw up the visualisation, so we will remove these
f=fieldnames(tempStimStruct);
for ii=1:length(f)
	if isstruct(tempStimStruct(1).(f{ii}))
		tempStimStruct = rmfield(tempStimStruct,f{ii});
	end

	%The odourList isn't useful. So remove if it's there
	if strcmp('odourList',f{ii})
		tempStimStruct = rmfield(tempStimStruct,f{ii});
	end

end



stimParams = struct2dataset(tempStimStruct);

if verbose
	disp(stimParams)
end


if nargout>0
	varargout{1} = stimParams;
end
