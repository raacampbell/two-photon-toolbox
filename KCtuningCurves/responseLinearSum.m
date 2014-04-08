function varargout=responseLinearSum(data,blend,components,ROIindex)
% Fit response to a blend with linear sum of component odours
%
% function stats=responseLinearSum(data,blend,components,ROIindex)
%
% Purpose
% We have recorded neural activity to a blend and also to
% components of that blend. Is the response to the blend simply a
% sum of its constituent odours? This function obtains the mean
% evoked KC activation pattern for each odour. Then fits a linear
% model to the odours defined by components to see how well it can
% be used to re-constitute the blend. The model is:
% blend = b_0 + b_1*component_1 + b_1*component_2 ... + b_n*component_n
%
% Inputs
% * data - the twoPhoton data object from one experiment
% * blend - a string specifying the name of the odour blend. 
% * components - a cell array of strings specifying the names of
% the components to which we will fit the model. 
% * ROIindex - the index of the ROI structure for which stats should
%   be calculated. By default it finds the field named 'soma' and
%   calculates stats for that. This variable is optional and can be
%   an index or a string (it looks up the ROI names in ROI.notes).
%
% Outputs
% * stats - [optional] structure containing parameter fit
%
% Rob Campbell - July 2010


error(nargchk(3,4,nargin))
if nargin<4, ROIindex='soma'; end
if ischar(ROIindex)
    ROIindex=strmatch(ROIindex,{data(1).ROI.notes});
end

if ~ischar(blend)
    error('blend should be a string')
end

if ~iscell(components)
    error('components should be a cell array of strings')
end
if length(components)<2
    %    error('components should have a length of at least 2')
end

    

%Get the odour names
out=plotROItuningCurves(data,'roi',ROIindex);


%Pull out the blend and component odours
indBlend=findOdours(out,blend);
indCompn=findOdours(out,components);

%Fit a linear model
data=out.plotData';
y=mean(data(:,indBlend),2); %in case we specified more than one "blend"
x=[ones(length(data),1),data(:,indCompn)];

[stats.b,stats.bint,stats.r,stats.rint,s] = regress(y,x);
stats.Rsq=s(1);
stats.F=s(2);
stats.p=s(3);


%Plot the results of the model
prediction=zeros(size(y));
for ii=1:length(stats.b)
    prediction = prediction + x(:,ii)*stats.b(ii);
end

[sortedY,ii]=sort(y);
sortedPrediction=prediction(ii);

stats.blend=y;
stats.sortedPrediction=sortedPrediction;

clf
subplot(1,3,1)
hold on
plot(sortedY,'-ok','MarkerFaceColor',ones(1,3)*0.5)
plot(sortedPrediction,'-o','Color',[1,0.2,0.2],'MarkerFaceColor',[1,0.6,0.6])
hold off

xlabel('#KC')
ylabel('mean evoked dF/F')
xlim([0,length(y)+1])

box on
set(gca,'TickDir','Out')

legend({'blend','prediction'},'Location','Northwest')

title(sprintf('R^2 = %0.3f',stats.Rsq))


subplot(1,3,2)
hold on
%plot(y,y-prediction,'k.')
plot(prediction,stats.r,'r.')
hold off
axis equal 


subplot(1,3,3)
Z=y;
Y=x(:,3);
X=x(:,2);
plot3(X,Y,Z,'ok')
[X,Y]=meshgrid(0.9*min(X):0.05:max(X)*1.1,...
               0.9*min(Y):0.05:max(Y)*1.1);
Z=stats.b(1)+X*stats.b(2)+Y*stats.b(3);
hold on
m=mesh(X,Y,Z);
set(m,'facecolor','r','facealpha',0.5)
hold off         
box

if nargout>1
    varargout{1}=stats;
    varargout{2}=x;
    varargout{3}=y
end


%----------------------------------------
function ind=findOdours(out,odourName)
if ~iscell(odourName)
    odourName={odourName};
end

n=1;
for ii=1:length(odourName)
    tmp=strmatch(odourName{ii},out.odors);
    if isempty(tmp)
        error('Can''t find %s',odourName{ii})
    else
        for jj=1:length(tmp)
            ind(n)=tmp(jj);
            n=n+1;
        end       
    end
end
