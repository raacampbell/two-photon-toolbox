%% addStimParams
% Add stimulus parameters to data structure
%
% |function data=addStimParams(data,params)|
%
%% Purpose
% Add stimulus parameters to the twoPhoton object. This function is
% very specific to the odor delivery system used in the Turner
% Lab. This adds a field called "stim" to the twoPhoton
% object. The field "stim" is a structure that contains all the
% relevant information for our experiments: e.g. the odor name, the
% onset time, and the stimulus duration. For different experiments,
% you will need to write an equivilent function to this and add
% your own information. The only critical thing is that you will
% need to include the fields stim.stimLatency and
% stim.stimDuration, as subsequent analysis functions employ these to
% figure out the response window.     
%
%% Inputs
% |data| - the twoPhoton object
% |params| - a parameter structure of the sort used by Rob's deliver
%          odours routine.
%
%% Outputs
% |data| - the |twoPhoton| object with a field called "stimuli"
%        containing the stimulus paramsers. 
