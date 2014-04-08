function stats=calculateLDdirections(stats)
% function  stats=calculateLDprojections(stats)
%
% Purpose
% The discriminant analysis conducted in clasifyKCs defines the
% discriminant directions as vectors in PC space. So an
% n-dimensional space will produce a family of discriminant vectors
% each of which has length n. This function calculates two things:
% 1. The position of each response along the LD. 
% 2. The direction of the LD in terms of the neurons underlying the
%    PC space. 
%
% Inputs
% stats - the output of classifyKCs.
%
% Outputs
% The stats structure with fields added to describe the
% data along the LDs. 
%
%
% Rob Campbell, August 2009
%
% See also: classifyKCs, odourClassConfMat, odourLDaxes

  

  
% classifyKCs does various discriminant analyses. It does a
% leave-one-out cross-validation, it fits LDs to the full data set,
% and it fits LDs to scarambled data to estimate noise. We want to
% calculate discriminant directions for all of these. 

  
%Remove any previously-calculated data if it exists  
if isfield(stats.discrimFull,'LDspace'); 
  stats.discrimFull=rmfield(stats.discrimFull,'LDspace');
end
if isfield(stats.xValid,'LDspace'); 
  stats.xValid=rmfield(stats.xValid,'LDspace');
end
if isfield(stats.xValidMu,'LDspace'); 
  stats.xValidMu=rmfield(stats.xValidMu,'LDspace');
end
if isfield(stats.noise,'LDspace'); 
  stats.noise=rmfield(stats.noise,'LDspace');
end
  


%Work out LD directions for each set of analyses
stats.discrimFull=doLDcalc(stats.discrimFull,1);
stats.xValidMu=doLDcalc(stats.xValidMu,1);
for i=1:length(stats.xValid.discrim)
  stats.xValid=doLDcalc(stats.xValid,i);
end

for i=1:length(stats.noise)
  tmp(i)=doLDcalc(stats.noise(i),1);
end
stats.noise=tmp;





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=doLDcalc(data,index)

  

N=size(data.discrim(index).coef,1); %number of different classes
S=length(data.trueClass); %numer of different stimuli

axN=1;
%SHOULD HAVE THIS IS A GENERAL PURPOSE FUNCTION IN MY STATS FOLDER!
for i=1:N
  for j=1:N


    if i<=j, continue, end

    coef=data.discrim(index).coef(i,j);
    loadings=data.params.loadings(:,1:data.params.ndims);

    %The linear discriminant defines the weights of the eignevectors
    %describing this direction in PC space of dimensionality
    %stats.ndims. Here we multiply the loadings for each response
    %along each eigenvector with the LD weights to yeild the position
    %of each point.
    ld=loadings.*repmat(coef.linear',S,1); %There is also a constant, but I'm not sure what to do with that
    data.LDspace(axN,index).ld=sum(ld,2);  %They're orthogonal so add them up (I think that's right --Rob)
                              

    %Calculate LD direction in neuron space
    eigs=data.params.eigenvectors(:,1:data.params.ndims);
    data.LDspace(axN,index).ldAxis=eigs.*repmat(coef.linear',length(eigs),1);
    data.LDspace(axN,index).ldAxis=sum(data.LDspace(axN,index).ldAxis,2);
  
    %These groups are separated along this LD
    data.LDspace(axN,index).id1=coef.name1{1};
    data.LDspace(axN,index).id2=coef.name2{1};

    %The indecies for the groups 
    data.LDspace(axN,index).ind1=strmatch(coef.name1,data.trueClass,'exact');    
    data.LDspace(axN,index).ind2=strmatch(coef.name2,data.trueClass,'exact');        
        
    
    axN=axN+1;    
  end
end








  
