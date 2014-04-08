function out=odourKmeans(data)
% function out=odourKmeans(data)
%
% Purpose
% Into how many groups do the data naturally partition?
% Run k-means for a range of values of k and calculate the
% silhouette width for each. Is there a peak in this metric?
%
% Inputs
% data - the twoPhoton data object or a data matrix
%
% Outputs
% out - a structure with the results. Can plot this with
%       odourKmeanResults
%    
% Rob Campbell - January 2010
%
% Notes:
% Running this function with random data doesn't produce what we'd
% expect--noise data and original data show a difference at higher
% cluster numbers. This may be over-fitting, but still, need to
% check that this code is ok. 
  
  
if isnumeric(data)
  kd=data;
  else
    kd=kcResponseMatrix(data);
end

%Could run it on the first few PCs. Then again, we could input
%whatever we want to this function so this is probably no the place
%for this code. 
%[eigen,score]=princomp(kd); 
% kd=score(:,1:12);


 
 
reps=5;
clusters=[220,270];
%clusters=7;

if length(clusters)==1
    clusters=[1,clusters];
end

fprintf('Running k-means on raw data: %d clusters, %d reps',...
        clusters(2),reps)
out.kMu=runkMeans(kd,clusters,reps);




for ii=1:size(kd,1)
    kd(ii,:)=kd(ii,randperm(length(kd)));
end
fprintf('Running k-means on noise data: %d clusters, %d reps',...
        clusters(2),reps)

out.kMuNoise=runkMeans(kd,clusters,reps);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tmp=runkMeans(in,clusters,reps)
tmp=ones(abs(diff(clusters))+1,reps);
for r=1:reps
    fprintf('.')
    
    kidx=[];
    S=kidx;

        warning off    
    for ii=clusters(1):clusters(2)

     kidx=[kidx,kmeans(in,ii,...
                    'Distance','cosine',...
                    'EmptyAction','drop',...
                    'Replicates',5)];
     S=[S,mean(silhouette(in,kidx(:,end)))];
   end
   tmp(:,r)=S(:);
   warning on
 end
 
fprintf('\n')
