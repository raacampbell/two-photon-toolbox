function out=nNeurons2p(data,ROIindex)
% Return neural summary statistics 
%
% function out=nNeurons2p(data,ROIindex)
%
% PURPOSE
% Return summary statistics for the number of neurons, etc, from
% the data array. NOTE: This function simple statistics, such as the total
% number of significant respones, etc. It also works from individual
% elements of the structure. To obtain more elaborate results one might
% want to use neuronMeanVar, which attempts to gauge neuron significance based
% upon the number of significant responses to the same odour, etc. 
%
% This is a very simple-minded function. A more elaborate version
% of the same thing can be found in neuronMeanVar. 
%
% INPUTS
% data - 2-photon data structure.
% ROIindex - which ROI to use for the calulation. By default
% ROIindex is the string 'soma', but it can also be the index of
% the ROI.
%
% OUTPUTS
% out - structure containing relevant information
%       See function body for details
%
%
% Rob Campbell - January 2010
%
% Also see: kcResponseMatrix, neuronMeanVar


if nargin<2, ROIindex='soma'; end   
if ischar(ROIindex)
    ROIindex=strmatch(ROIindex,{data(1).ROI.notes});
end


% out.n - Number of neurons
out.n=size(data(1).ROI(ROIindex).stats.dff,1);


% out.sigNeurons - indecies of significantly responding neurons
%These are neurons which responded significantly at least once. 
out.sig=[];
for ii=1:length(data)
    out.sig=[out.sig,data(ii).ROI(ROIindex).stats.sigResponses];
end
out.sigInd=unique(out.sig);
out.nSig=length(out.sigInd);

% out.pSig - proportion of neurons to respond significantly 
out.pSig=out.nSig/out.n;
