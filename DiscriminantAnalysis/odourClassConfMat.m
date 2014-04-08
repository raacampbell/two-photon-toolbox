function stats=odourClassConfMat(stats,doPlot,theseStimuli)
% function stats=odourClassConfMat(stats,doPlot,theseStimuli)
%
% Purpose
% Make a confusion matrix of the classification results and
% calculate discriptive statistics such as the bootstraped
% de-biased mututal information.
%
% Inputs
% stats - the output of classifyKCs.
% doPlot [optional] - is 1 by default
% theseStimuli [optional] - a vector defining which stimuli should
%                           be included in the confusion matrix. 
%                           This is slightly dodgy because the LD
%                           was fitted to everything. This option
%                           is useful for viewing the results of
%                           large analyses but probably isn't a
%                           proper reflection of what's going on. 
%
% Outputs
% stats - structure containing analysis results. This function adds
% the information it has calculated as fields to the structure. 
%
% Example
%     stats.xValid=odourClassConfMat(stats.xValid,1)
%
% Rob Campbell, August 2009
%
% See also: classifyKCs

  
if nargin==1,doPlot=1;end  
if nargin<3, theseStimuli=[]; end
  
%Build a confusion matrix and calculate the mutual information   
stimuli=unique(stats.trueClass);
if ~isempty(theseStimuli)
    stimuli=stimuli(theseStimuli);
end

stats.confMat=getConfMat(0);


%Calculate the MI bias using bootstrapping
reps=2;
noise=zeros(1,reps);
for i=1:reps
  noise(i)=confMatrix_MI(getConfMat(1),0);
end

%Observed MI minus bias
stats.MI=confMatrix_MI(stats.confMat,0)-mean(noise);


%Proportion of correct responses
perCor=(sum(diag(stats.confMat))/sum(stats.confMat(:)))*100;
stats.percentCorrect=perCor;



if doPlot==0,return;end


%----------------------------------------------------------------------
%Plot the confusion matrix and summary statistics. 
tmp=stats.confMat;
tmp(end+1,:)=nan;
tmp(:,end+1)=nan;
imagesc(stats.confMat)


set(gca,'xtick',1:length(stimuli)+0.5,...
        'xticklabel','',...
        'ytick',1:length(stimuli)+0.5,...
        'yticklabel',stimuli)


%Add fancy x-tick labels
xl=get(gca,'XTick');
for i=1:length(stimuli)
  text(xl(i),0.3,stimuli{i},'rotation',-20,...
       'fontweight','bold')
end

colormap jet
axis square xy


title(sprintf('MI=%0.2f/%0.2f bits; %2.1f%% Correct',...
              stats.MI,log2(length(stimuli)),perCor),...
      'fontsize',13,'FontWeight','bold')


%Overlay the proportion of correct responses
for i=1:length(stimuli)
  n=sum(stats.confMat(:,i));
  p=stats.confMat(i,i);
  
  text(i-0.195,i-0.095,...
       sprintf('%d/%d',p,n),'fontsize',17,'color','w')
  text(i-0.2,i-0.1,...
       sprintf('%d/%d',p,n),'fontsize',16)
end









%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function confMat=getConfMat(randomize)
  trueClass=stats.trueClass;
  if randomize
    trueClass=trueClass(randperm(length(trueClass)));
  end
  
  confMat=zeros(length(stimuli));
  for cmI=1:length(stats.trueClass)
    column=strmatch(trueClass{cmI},stimuli,'exact');
    row=strmatch(stats.predictedClass{cmI},stimuli,'exact');
    confMat(row,column)=confMat(row,column)+1;
    end
end


end
