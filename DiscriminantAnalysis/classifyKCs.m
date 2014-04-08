function stats=classifyKCs(data,params,fullStats)
%function stats=classifyKCsLDA(data,params,fullStats)
%
% Purpose
% Compute discriminant functions for separating responses from one
% another. We will calculate the functions using leave-one-out
% cross-validation, producing a family of discriminant functions:
% one for each odour presentation.   
% http://en.wikipedia.org/wiki/Cross-validation_(statistics)
%
% The Matlab implementation of LDA/MDA appears to use a centroid-based
% method for assigning group identity. This isn't obvious from the
% docs, you have to look in the code to work it out. The method is
% described a being Basyian and seems to be the same as what's
% outlined in Venables & Ripley 3rd ed. p. 334. Also note that we're
% technically doing MDA since the analysis fits all groups
% simultaneously. The "linear" distance method has one SD for all
% groups. "quadratic" would add parameters to specify SDs indevidually
% for each group.
%
% Note that by default this function uses the mean response for
% each KC. It can easily be changed by passing a different argument
% to kcResponseMatrix (see code below). 
%
% Inputs
% data - The twoPhoton object containing the KCstats field. 
% params.ndims - the number of dimensions to use for the analysis. 
% params.matrixType - the sort of metric to use [binary, mean,...]
% [SEE FUNCTION BODY!]
% fullStats - add all statistics, such as LD directions, to the
% output (see main function body). Optional, 0 by default. 
%
% Outputs
% stats - structure containing analysis results
%
% Rob Campbell, August 2009
%
%
% See also: odourClassConfMat, odourLDaxes[12], calculateLDdirections,
%           calculateLDprojections,kcResponseMatrix, odourDendrogram
%         


if nargin<2 || isempty(params)
    params=struct;
end

if ~isfield(params,'ROIindex'),     params.ROIindex='soma';   end
if ~isfield(params,'ndims'),        params.ndims=12;          end
if ~isfield(params,'matrixType'),   params.matrixType='mean'; end
if ~isfield(params,'noiseType'),    params.noiseType= 'shufflepresentations'; end
if ~isfield(params,'noiseReps'),    params.noiseReps=1;      end
if ~isfield(params,'mdaType'),      params.mdaType='linear';  end
if ~isfield(params,'dimReduction'), params.dimReduction='pca';end
if ~isfield(params,'neuronSubset'), params.neuronSubset=[];end
if ~isfield(params,'extraTime'),    params.extraTime=[];end
if ~isfield(params,'subDivide'),    params.subDivide=1;end
if ~isfield(params,'verbose'),      params.verbose=1;end
if ~isfield(params,'kcMatrix'),     params.kcMatrix=[];end
%Run analysis on a sub-set of stimulus categories. (see main body of function)
%stimuli select is a vector which specifies a sub-set of indecies
%from the unique odours cell array returned by getOdourNames
if ~isfield(params,'stimuliSelect'), params.stimuliSelect=[];end

if ischar(params.ROIindex)
    params.ROIindex=strmatch(params.ROIindex,{data(1).ROI.notes});
end

if nargin<3, fullStats=0; end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP ONE
%You need more observations (stimulus presentations) then variables
%(KCs) otherwise you'll over-fit and the results will be bollocks. 
%We will therfore conduct a dimensionality reduction using PCA
%(could also use MDS) and keep only the first "dims" 

if params.verbose
    disp('Running x-Validated classifier on raw data')
end


%kcMatrix is a matrix of neuronal activity (columns) over different
%stimulus presentations (rows)
if isempty(params.kcMatrix)
    kcMatrix=ROI_responseMatrix(data,params.ROIindex,params.matrixType,...
                              params.extraTime,params.subDivide,0);
else
    kcMatrix=params.kcMatrix;
    params.kcMatrix='user supplied';
end

if ~isempty(params.neuronSubset)
    kcMatrix=kcMatrix(:,params.neuronSubset);
end

if strcmp(params.dimReduction,'none')
    params.ndims=size(kcMatrix,2);
end

    
%Get the identity of the stimuli (odours)
[stimulus,Us]=getOdourNames(data);

if ~isempty(params.stimuliSelect)
    Us=Us(params.stimuliSelect);
    for i=length(stimulus):-1:1
        if isempty(strmatch(stimulus{i},Us,'exact'))
            stimulus(i)=[];
            kcMatrix(i,:)=[];
        end        
    end

    stats.restrictedStimuli=unique(stimulus);
end


%sort it alphabetically so that the cross-validation produces the 
%dicriminant axes in the same order across runs
[stimulus,stimIndex]=sort(stimulus);
kcMatrix=kcMatrix(stimIndex,:);
stats.stimIndex=stimIndex;


%reduce dimensionality
%params.matrixType=params.matrixType;
%params.nDims=params.ndims;

[reducedSpace,params]=reduceDimensionality(kcMatrix,params);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP TWO: fit squillions of discriminant functions 
%

%Run cross-validation on raw data and save to out output struct
stats.xValid=runXValid(reducedSpace,stimulus,params);


%Calculate the mean of the cross-validated data so that we obtain mean
%directions of the LDs over all runs of the algorithm
stats.xValidMu.trueClass=stimulus;
stats.xValidMu.err=stats.xValid.err;
stats.xValidMu.predictedClass=stats.xValid.predictedClass;
stats.xValidMu.params=params;

%now a horrible loop to work out the means. 
coef=stats.xValid.discrim(1).coef;
for i=1:length(coef)
  for j=1:length(coef)
    if i==j, continue, end
    
    const=ones(1,size(kcMatrix,1));
    linear=ones(params.ndims,size(kcMatrix,1));
    for n=1:size(kcMatrix,1)
      const(n)=stats.xValid.discrim(n).coef(i,j).const;
      linear(:,n)=stats.xValid.discrim(n).coef(i,j).linear;
    end
    
    coef(i,j).const=mean(const);
    coef(i,j).linear=mean(linear,2);
  end
end

stats.xValidMu.discrim.coef=coef;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Do one run on the full space to compare to the mean of the
%cross-validated data sets. 
if params.verbose
    disp('Running non-x-Validated classifier on raw data')
end

[class,...
 err,...
 stats.discrimFull.discrim.post,...
 stats.discrimFull.discrim.logp,...
 stats.discrimFull.discrim.coef]=classify(reducedSpace,reducedSpace,...
                                          stimulus,params.mdaType);  

stats.discrimFull.trueClass=stimulus;
stats.discrimFull.err=err;
stats.discrimFull.predictedClass=class;
stats.discrimFull.params=params; %a copy of the
                                           %dimensionality reduction



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Now we will use bootstrapping to estimate the noise in the LDs so
%that we can determine later whether each neuron is contributing
%significantly to the discrimination. 
if params.verbose
    fprintf('Running classifier on "noise" data')
end

reps=params.noiseReps;

stats.noiseType=params.noiseType;

if strcmp('drop',stats.noiseType)
  reps=size(kcMatrix,2);
end

%THE FOLLOWING IS BADLY CODED
switch stats.noiseType
  case 'drop'
    kcMatrix=ROI_responseMatrix(data,params.ROIindex,'mean',params.extraTime,[],0);
    if ~isempty(params.neuronSubset)
        kcMatrix=kcMatrix(:,params.neuronSubset);
    end
    kcMatrix=kcMatrix(stimIndex,:);
    EIG=princomp(kcMatrix);    
end

     
for i=1:reps
    if params.verbose, fprintf('.'), end
  switch lower(stats.noiseType)
   case 'shufflecells'    %Permute cell ID independently for each stimulus
    kcMatrix=ROI_responseMatrix(data,params.ROIindex,'shufflecells',params.extraTime,[],0);
    if ~isempty(params.neuronSubset)
        kcMatrix=kcMatrix(:,params.neuronSubset);
    end
    kcMatrix=kcMatrix(stimIndex,:);
    [reducedSpace,stats.noise(i).params]=...
      reduceDimensionality(kcMatrix,params);
  
   case 'shufflepresentations' %randomize groupIDs
    kcMatrix=ROI_responseMatrix(data,params.ROIindex,'mean',params.extraTime,[],0);
    if ~isempty(params.neuronSubset)
        kcMatrix=kcMatrix(:,params.neuronSubset);
    end
    kcMatrix=kcMatrix(randperm(size(kcMatrix,1)),:);
    kcMatrix=kcMatrix(stimIndex,:);
    [reducedSpace,stats.noise(i).params]=...
      reduceDimensionality(kcMatrix,params);

    
    case 'drop'    %drop a cell at a time 
      tmp=kcMatrix;
      tmp(:,i)=[];
    [reducedSpace,stats.noise(i).params]=...
      reduceDimensionality(tmp,params);

  end
    
  
  noise(i)=runXValid(reducedSpace,stimulus,params);


end
if params.verbose
    fprintf('\n')
end

stats.noise=noise;





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Make an output array with the usful data

%add "raw" data into the array 
for ii=1:length(data)
  stats.raw(ii)=data(ii).ROI(params.ROIindex).stats;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Now calculate the projections of the LDs and various statistics
%for this. 

stats=calculateLDdirections(stats);
if fullStats
    if params.verbose
        disp('Calculating LD stats')
    end
    
    stats=calculateLDstats(stats); 
end

%Add confusion matrix stats
if params.verbose
    fprintf('Adding confusion matrix stats')
end


if params.verbose, fprintf('.'); end
stats.xValid=odourClassConfMat(stats.xValid,0);
if params.verbose, fprintf('.'); end
stats.xValidMu=odourClassConfMat(stats.xValidMu,0);
clear noise
for i=1:length(stats.noise)
    if params.verbose, fprintf('.'); end
    noise(i)=odourClassConfMat(stats.noise(i),0);
end
stats.noise=noise;

if params.verbose
    fprintf('\nDone!\n')
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%For dimensionality reduction
function [reducedSpace,stats]=reduceDimensionality(kcMatrix,stats)
switch stats.dimReduction
  case 'pca'
  [stats.eigenvectors,...
   stats.loadings,...
   stats.eigenvalues]=princomp(kcMatrix);
   reducedSpace=stats.loadings(:,1:stats.ndims);
 case 'mds'
  corrdist = pdist(kcMatrix, 'cosine'); 
  opt=statset('maxiter',7000);
  [stats.loadings,...
   stats.stress,...
  stats.disp]=mdscale(corrdist,stats.ndims,...
                      'criterion', 'metricsstress',...
                      'Options',opt);
  reducedSpace=stats.loadings;
  case 'none'
    reducedSpace=kcMatrix;
    %Next a hack to get other scripts to work
    stats.loadings=kcMatrix;
    stats.eigenvectors=eye(size(kcMatrix,2));
end



%Runs a leave-one-out cross-validation on raw or permuted data
function OUT=runXValid(reducedSpace,stimulus,params)
ind=1:size(reducedSpace,1);
for n=1:size(reducedSpace,1)

  %Choose training and test sets for leave-one-out cross-validation
  sample=reducedSpace(n,:);
  
  training=reducedSpace(ind(ind~=n),:);
  group=stimulus(ind(ind~=n));


  [class,...
   err(n),...
   discrim(n).post,...
   discrim(n).logp,...
   discrim(n).coef]=classify(sample,training,group,params.mdaType);  

  predictedClass{n}=class{1};
end

%Save this stuff into our output structure
OUT.discrim=discrim;
OUT.trueClass=stimulus;
OUT.err=err;
OUT.predictedClass=predictedClass;
OUT.params=params;















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following code is not being used right now because it doesn't
% work. However, in principle it should be better (and possibly
% faster) to run the classifier using the crossval function. 
%Runs a leave-one-out cross-validation on raw or permuted data
function OUT=runXValid2(reducedSpace,stimulus,params)
ind=1:size(reducedSpace,1);
classf = @(xtrain, ytrain,xtest)(classify(xtest,xtrain,ytrain));
C=crossval('mcr',reducedSpace,stimulus,'predfun',classf);

%Save this stuff into our output structure
OUT.discrim=discrim;
OUT.trueClass=stimulus;
OUT.predictedClass=C;
OUT.params=params;
