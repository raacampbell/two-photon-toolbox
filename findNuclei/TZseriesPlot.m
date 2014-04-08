function TZseriesPlot(stats,overlay)
% function TZseriesPlot(stats,overlay)
%
% Animate a TZseries

if nargin<2; overlay=0; end



c=stats(1).centroid;


lim=[1,300];
f=find(c(:,1)<=lim(2) & c(:,1)>=lim(1) & ...
       c(:,2)<=lim(2) & c(:,2)>=lim(1));

P=plot3(stats(1).centroid(f,1),...
        stats(1).centroid(f,2),...
        stats(1).centroid(f,3),...
        'k.');
box on


%fix the axis limits
L=length(stats);
tmp=ones(2,3,L);
for ii=1:L
    tmp(1,:,ii)=min(stats(ii).centroid,[],1);
    tmp(2,:,ii)=max(stats(ii).centroid,[],1);
end


M=[min(tmp(1,:,:),[],3);...
   max(tmp(2,:,:),[],3)];
        
m=0.2;
xlim([M(1,1)-M(1,1)*m, M(2,1)+M(2,1)*m])
ylim([M(1,2)-M(1,2)*m, M(2,2)+M(2,2)*m])
zlim([M(1,3)-M(1,3)*m, M(2,3)+M(2,3)*m])


if overlay, hold on, end

while 1

    
for ii=1:L

    c=stats(ii).centroid;
    f=find(c(:,1)<=lim(2) & c(:,1)>=lim(1) & ...
           c(:,2)<=lim(2) & c(:,2)>=lim(1));

    if overlay  
        P=plot3(c(f,1), c(f,2), c(f,3), 'k.');
        continue
    end
    


    set(P,'xdata',c(f,1),...
        'ydata',c(f,2),...
        'zdata',c(f,3))
        pause(0.1)
end
if overlay & ii==L
    break
end


end

if overlay
    hold off
    xlim(lim)
    ylim(lim)
end
