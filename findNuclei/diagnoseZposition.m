function diagnoseZposition(stats)
% function diagnoseZposition(stats)
% overlay some z position stuff


if length(stats)==1
    
    c=stats.centroid;
    lim=[150,180];
    
    
    f=find(c(:,1)<=lim(2) & c(:,1)>=lim(1) & ...
           c(:,2)<=lim(2) & c(:,2)>=lim(1));
    c(:,1)=c(:,1)-lim(1);
    c(:,2)=c(:,2)-lim(1);
    
    clf
    p3(c(f,:),{'or','markerfacecolor',[0.5,0,0]})
    vol=stats.vol(lim(1):lim(2),lim(1):lim(2),:);
    isosurface(vol,1)


else
    
    clf
    for ii=1:length(stats)
        z{ii}=stats(ii).centroid(:,3);
    end
    L=cellfun(@length,z);

    data=nan(max(L),length(stats));

    for ii=1:length(stats)
        data(ii,1:length(z{ii}))=z{ii};
    end
    %    boxplot(data)



    %try to correct the depth
    clf
    subplot(1,2,1)
    TZseriesPlot(stats,1)

    mu=cellfun(@mean,z);
    mu=mu-mu(1);

    for ii=1:length(mu)
        stats(ii).centroid(:,3)=stats(ii).centroid(:,3)+mu(ii);
    end
    subplot(1,2,2)
    TZseriesPlot(stats,1)

  
end



