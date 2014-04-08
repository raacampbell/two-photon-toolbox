function varargout=playMovie(imageStack,framePeriod,loop,noClear)
% Play a movie of an imageStack
% 
% function playMovie(imageStack,framePeriod,loop,noClear)
%
% Purpose
% Plays a movie of the image data in the 3-d matrix 'imageStack' image
% stack where 3rd dimension may be time or z.
%
% Inputs
% * imageStack - a 3-D matrix 
%   if a cell array of equally sized matrices then these are joined
%   together and displayed simultaneously
% * framePeriod - [OPTIONAL, 0.05 by default] how fast to attempt to
% play the movie.  (if framePeriod is a string then save the movie in the
% current directory).
% * loop - [OPTIONAL, 1 by default]. if loop is true then play
% movie continuously.
% * noClear [OPTIONAL, 0 by default] - don't clear the figure window
%
%
% Rob Campbell, CSHL


narginchk(1,4);
if nargin<2 | isempty(framePeriod) | isnan(framePeriod)
    framePeriod=0.05;
end

if nargin<3
    loop=1;
end
if nargin<4 
    noClear=0;
end

if ischar(framePeriod)
    loop=0;
    makeMovie=1;
    fname=framePeriod;
else
    makeMovie=0;
end


if iscell(imageStack)
    s=cellfun(@size,imageStack,'UniformOutput',0);
    s=unique(cell2mat(s'),'rows');
    if size(s,1)>1playMovie.m
        error('matrix sizes are different')
    end
    im=nan(size(imageStack{1}));
    
    im=repmat(im,[size(imageStack),1]);
    if size(imageStack,1)==1
        N=1:s(2);
        for ii=1:length(imageStack)
            im(:,N,:)=imageStack{ii};
            N=N+s(2);
        end
    else
        N=1:s(1);
        for ii=1:length(imageStack)
            im(N,:,:)=imageStack{ii};
            N=N+s(1);
        end
    end
    
    imageStack=im;
end


if ~noClear
    clf
    %    set(gcf,'Color','k')
end

imagesc(imageStack(:,:,1))
axis off, axis equal
colormap gray


%tmp=convn(imageStack(:),ones([2,2,1])/2^2,'same');
%scale=[min(imageStack(:)),max(tmp(:))];
scale=[min(imageStack(:)),max(imageStack(:))];
S=size(imageStack,3);

if makeMovie
    f=getframe(gcf);    
    [im,map]=rgb2ind(f.cdata,256,'nodither');

    im(1,1,1,S)=0;
    for frame=1:S
        chil=get(gca,'children');
        set(chil(end),'CData',imageStack(:,:,frame))
        set(gca,'CLim',scale)
        %drawnow
        f=getframe(gcf);
        im(:,:,1,frame) = rgb2ind(f.cdata,map,'nodither');
    end
    
    imwrite(im,map,fname,'DelayTime',0.035,'LoopCount',inf) 
else
    while 1
        for frame=1:S
            chil=get(gca,'children');
            set(chil(end),'CData',imageStack(:,:,frame))
            set(gca,'CLim',scale)
            title(sprintf('Frame %d/%d',frame,S))
            drawnow
            pause(framePeriod)
        end
        if ~loop, 
            if nargout==1
                varargout{1}=imageStack;                
            end
            break
        end
    end
end
