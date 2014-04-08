function varargout=createBlobTSeriesMovie(data,delta,showMovie)
% function im=createVolumeTSeriesMovie(data,delta,showMovie)
%
% Plot sequential depth volumes next to each other so that we can
% animate the depth dimension and see how it changes over time. 
%
% Inputs
% data - e.g. data(1)
% delta - if ==1 (default) calculate the delta
% showMovie - if ==1 (default) show the movie
%
% Outputs
% If the movie isn't shown, we can optionally get the image stack
% back to pass it to commands such as colorDepth or write to disk.
%
% Rob Campbell 


if nargin<2, delta=1; end
if nargin<3, showMovie=1; end


kc=data.KCstats.kcDFF;

centroids=data.centroids;


clf
colormap jet

if delta
    for ii=2:size(kc,2)
        kc(:,ii)=kc(:,ii)-kc(:,1);
    end
    kc(:,1)=1;
end
kc=(kc+1)+2;

while 1
for ii=1:size(kc,2)
    scatter3(centroids(:,1),centroids(:,2),centroids(:,3),...
             kc(:,ii).^3,kc(:,ii),'filled')
axis square
title(sprintf('%d/%d',ii,size(kc,2)))
drawnow
pause(0.4)

end
end
return




im(:,:,1,:)=[];

im=permute(im,[4,1,2,3]);
im=reshape(im,[size(im,1),size(im,2),size(im,3)*size(im,4)]);
im=permute(im,[2,3,1]);

im(im<0)=0;

if showMovie
    playMovie(im)
end



if nargout==1
    varargout{1}=im;
end
