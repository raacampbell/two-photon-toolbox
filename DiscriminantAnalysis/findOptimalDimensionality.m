function opt=findOptimalDimensionality(data)
% function opt=findOptimalDimensionality(data)
%
% Purpose
% Run classifier for a range of different dimensionalities to look
% for the optimal
%
%
%
% Rob Campbell


params.noiseType='shufflepresentations';
params.noiseReps=1;
ndims=3:18;

n=1;
for i=1:length(ndims)
    try
        params.ndims=ndims(i);
        stats=classifyKCs(data,params);
        opt(n,1)=i;
        opt(n,2)=stats.xValidMu.percentCorrect;
        n=n+1;
    catch
        break
    end
    
end

