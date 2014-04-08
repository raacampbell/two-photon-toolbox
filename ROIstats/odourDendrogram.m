function odourDendrogram(data,linkageLevel)
% dendrogram showing response relatedness
%
% function odourDendrogram(data,linkageLevel)  
%
% How are responses to different odours/stimuli related? Visualise this
% using a dendrogram and MDS. 
%
% Inputs: 
%  * data - the twoPhoton object once we have run addKC_stats on it. 
%  * ROIindex - which ROI to use for the calulation. By default
%    ROIindex is the string 'soma', but it can also be the index of
%    the ROI    
%  * linkageLevel - The level below which to color the dendrogram bars.
%
% e.g. odourDendrogram(data)
%
% Rob Campbell, 29th July 2009
  

ROIindex='soma';
if nargin<2,linkageLevel=0.4;end

if ischar(ROIindex)
    ROIindex=strmatch(ROIindex,{data(1).ROI.notes});
end

dataMatrix=ROI_responseMatrix(data,ROIindex);




%what happens if we throw out all of the neurons which didn't respond
%significantly?

%dataMatrix=dataMatrix(:,unique([data.KCstats.sigResponses]));
%dataMatrix(:,unique([data.KCstats.sigResponses]))=[];

clf
subplot(1,2,1)

corrdist = pdist(dataMatrix, 'euclidean'); 
corrlink = linkage(corrdist,'weighted');
%corrlink = linkage(corrdist,'median');
[H,b,perm] = dendrogram(corrlink,0,'orientation','left',...
                        'colorthreshold',linkageLevel);

set(H,'linewidth',2)

%Add odour names
ind=str2num(get(gca,'YTickLabel'));
title('Odour Dendrogram','fontweight','bold')


for ii=1:length(data)
    %odourString is the odour name followed by the number of responsive
    %neurons.    
    odourString=sprintf('%s[%d]',...
        data(ind(ii)).stim.odour,length(data(ind(ii)).ROI(ROIindex).stats.sigResponses));
    odours{ii}=odourString;
end
set(gca,'YTickLabel',odours);

box on
xlabel('Linkage')
set(gca,'color',ones(1,3)*0.5)



%------------------------------------------------------
%SHOW THE MDS


%Work out the linkage-related colour for each odour
n=1;
clear tmp
odourColors=[];
for i=1:length(H)
    
    x=get(H(i),'xdata');
    if min(x)==0 %if zero then it's one of the final branches
        y=unique(get(H(i),'ydata'));        
        y=y((y-round(y))==0);%remove non-integers
        
        for j=1:length(y)
            odourIndex(n)=perm(y(j));
            odourColors=[odourColors;get(H(i),'color')];
            n=n+1;
        end
    end
    
end

subplot(1,2,2)
odour3Dplot(data,ROIindex,corrdist,odourColors,odourIndex)
