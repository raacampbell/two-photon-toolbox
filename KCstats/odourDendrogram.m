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
%
% e.g. odourDendrogram(data)
%
% Rob Campbell, 29th July 2009
  

dataMatrix=kcResponseMatrix(data);

if nargin<2,linkageLevel=0.4;end


%what happens if we throw out all of the neurons which didn't respond
%significantly?

%dataMatrix=dataMatrix(:,unique([data.KCstats.sigResponses]));
%dataMatrix(:,unique([data.KCstats.sigResponses]))=[];

clf
subplot(1,2,1)

corrdist = pdist(dataMatrix, 'cosine'); 
corrlink = linkage(corrdist,'complete');
%corrlink = linkage(corrdist,'median');
[H,b,perm] = dendrogram(corrlink,0,'orientation','left',...
                        'colorthreshold',linkageLevel);

set(H,'linewidth',2)

%Add odour names
ind=str2num(get(gca,'YTickLabel'));
title('Odour Dendrogram','fontweight','bold')


for i=1:length(data)
    %odourString is the odour name followed by the number of responsive
    %neurons.    
    odourString=sprintf('%s[%d]',...
        data(ind(i)).stim.odour,length(data(ind(i)).KCstats.sigResponses));
    odours{i}=odourString;
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
odour3Dplot(data,corrdist,odourColors,odourIndex)
