function centroids=find2dRFP(imstack,cellDiameter,thresh)


S=30;
g=fspecial('gaussian',S,cellDiameter);
%g=fspecial('disk',cellDiameter);



chop=cellDiameter*2;


subplot(1,2,1)
filt=normxcorr2(g,imstack);
filt=filt(chop:end-chop,chop:end-chop);
imagesc(filt)
axis equal off
title('filtered')
colorbar


subplot(1,2,2)
bw=im2bw(filt,thresh);
[boundaries,~,n]=bwboundaries(bw);

%calculate centroids
centroids=ones(length(boundaries),2);
for ii=1:length(boundaries)
    centroids(ii,:)=[mean(boundaries{ii}(:,2))+cellDiameter,...
                     mean(boundaries{ii}(:,1))+cellDiameter];
end


imagesc(mat2im(imstack,gray(100)))
imagesc(mat2im(imstack,jet(100)))
axis off equal
hold on
plot(centroids(:,1),centroids(:,2),'.r')
hold off
title(sprintf('%d cells',length(centroids)))



%Work out distances
dist=squareform(pdist(centroids));
dist=triu(dist);
dist(dist==0)=nan;
%pcolor(dist),shading flat
hist(dist(:),200)
