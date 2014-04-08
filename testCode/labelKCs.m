function labelKCs(data)
%  function labelKCs(data)
%
% Plot the basline image then overlay this with each clicked KC. Label each
% clicked KC with a number to indicate it's row in the KC matrix. 
kcs=data.KCmasks;


clf  
pcolor(double(data.baselineImage))
shading flat
set(gca,'xtick',[],'ytick',[])



axes('position',get(gca,'position'));

plt=kcs;
plt(plt==0)=nan;
plt(~isnan(plt))=1;
pcolor(plt)

box on 
colormap gray
shading flat
set(gca,'xtick',[],'ytick',[],'color','none')

BW=im2bw(plt);
[B,L,N] = bwboundaries(BW);
hold on
for i=1:length(B)
  boundary = B{i};
  plot(boundary(:,2), boundary(:,1), 'g','LineWidth',2);
end
hold off
 

U=unique(kcs(:));
U(U==0)=[];
for i=1:length(U)
  f=find(kcs==U(i));
  
  f=f(1);
  
  [ii,jj]=ind2sub(size(kcs),f);
  
  t=text(jj,ii,num2str(U(i)),'fontweight','bold','fontsize',15,...
         'color','b');
  
  f=find(data.KCstats.sigResponses==U(i));
  if ~isempty(f)
    set(t,'color','r')
  end
  
  
end

  
  
