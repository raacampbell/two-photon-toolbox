function out=addingNeuronsAnalysis(data,stats)
% function out=addingNeuronsAnalysis(data,stats)
%
% This is run on the output of classifyKCs which has the 'drop'
% noise type. This assess the impact on classification accuracy of
% removing each KC in turn. 
% 
% Inputs
% data - twoPhoton object
% stats - output of classifyKCs    
%
%
% Rob Campbell, October 2009
    
if ~strcmp(stats.noiseType,'drop')
    error('noise type must be of class "drop"')
end


%Get the percent correct following dropping of each unit in turn
for i=1:length(stats.noise)
    pc(i)=stats.noise(i).percentCorrect;
end
pc=pc-stats.xValidMu.percentCorrect;





%How does classification accuracy change as we add the more
%informative neurons
[pcs,ind]=sort(pc);

%so we do it quickly. 
params.noiseType='shuffle';
params.noiseReps=1;

pc=[];

N=nNeurons2p(data);


M=30;
if N.n<M; M=N.n; end

n=5:M; %add this many neurons (dimensionality will scale
       %accordingly). 

ndim=[];
for i=n
    %Change dimensionality here. 
    params.ndims=ceil(i*0.3);
    if params.ndims>12,params.ndims=12;end
    ndim=[ndim,params.ndims];
    params.neuronSubset=ind(1:i);
    stats=classifyKCs(data,params);
    pc=[pc,stats.xValid.percentCorrect];
end




out.addingNeurons=[n;pc];
out.ndim=ndim;
