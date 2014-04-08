function [imStack,out]=correctTranslation3D(imStack,cFrame,verbose)
% Apply 2-D translation correction to a 3-d image-stack volume
%
% function [registered,OffsetPixel,diffPhase]=correctTranslation3D(imStack,cFrame,verbose)
%
% Purpose
% Usually called by cleanImageStack but also can be used to attempt
% motion correction across presentations. Uses an FFT-based method
% which provides 2-D rigid translation correction at sub-pixel
% accuracy and high speed. 
%
% Inputs
% imStack - a 4-d or 5-d matrix of images to be motion corrected by
% 2-d cross-correlation. If 5-d, it conducts the correction on the
% first (RFP) channel and copies it over to the second (GFP)
% channel. 
% cFrame - the image with respect to which the xcorr will be
% performed. 
%  * If cCframe is a scalar then correct imStack with respect to
%    imStack(:,:,cFrame).
%  * If cFrame has length==2 then correct imStack with respect to
%    imStack(:,:,cFrame(1):cFrame(2)).
%  * If cFrame is a 2-d matrix then correct imStack with respect to
%    this.   
%  * verbose [optional, 0 by default] - if 1 then it plots the
%    performance of the registration. 
%
% Outputs
% * registered is the motion-corrected image stack. 
% * OffsetPixel is a matrix of optimal x/y offset positions over all frames. 
% * diffPhase - the diffPhase output from the FFT-based translation correction.
%
% Rob Campbell, March 2010
%
%
% registration code obtained from the file exchange:
% http://www.mathworks.com/matlabcentral/fileexchange/18401
  

imStack=squeeze(imStack);
imSize=size(imStack);

%Pad depth 1 with two copies at the start in order to remove the
%weird artefacts. 
pad=2;
for ii=1:pad
    imStack(:,:,:,1,end+1)=imStack(:,:,:,1,1);
    imStack(:,:,:,2,end)=imStack(:,:,:,2,1);
end
imStack=circshift(imStack,[0,0,0,0,pad]);

% Generally, motion will be corrected with respect to the first volume
% (since not many volumes are taken) by default. This is either >1
% frames from the imStack or a different image (e.g. to motion correct
% across stimulus presentations).
if nargin<2, cFrame=1; end
if length(cFrame)==2
  cImage=mean(imStack(:,:,cFrame(1):cFrame(2),:),3);
elseif length(cFrame)==1
  cImage=imStack(:,:,cFrame,:);
else %assumes a 2-matrix
  cImage=cFrame;  
end

if nargin<3, verbose=0; end



%Alignment will proceed along 3 dimensions. We have the option to
%either average along each or conduct the alignment seperately on
%each slice along each dimension. 

average=0;
[out,imStack]=alignAlongDimension(imStack,5,cFrame,average);
[out,imStack]=alignAlongDimension(imStack,1,cFrame,average);
[out,imStack]=alignAlongDimension(imStack,2,cFrame,average);
[out,imStack]=alignAlongDimension(imStack,5,cFrame,average);
%[out,imStack]=alignAlongDimension(imStack,2,cFrame,average);

imStack(:,:,:,:,1:pad)=[];

if verbose
  clf
  subplot(2,2,1)
  imagesc(mean(imStack,3))
  axis equal off
  title('original mean')
  
  subplot(2,2,2)
  imagesc(mean(registered,3))
  axis equal off
  title('corrected mean mean')
  
  subplot(2,2,3)
  plot(OffsetPixel)
  xlabel('Frame')
  ylabel('delta (pixels)')
  title('Estimated translation magnitude')
  legend({'y shift','x shift'})
  
  subplot(2,2,4)
  plot(imageStackCorr(imStack, cFrame),'-k')
  hold on
  plot(imageStackCorr(registered, cFrame),'-r')
  hold off
  xlabel('Frame')
  ylabel('R')
  title('correlation wrt to baseline')
  legend({'original','corrected'})
  colormap gray
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out,imageStack]=alignAlongDimension(imageStack,dim,cFrame,average)
%imStack - the 5-D stack (4th dimension is channel);
%dim - the dimension along which we will work
%average - if 1 we average along this dimension first. If 0 we work
%          out the correction for each time slice. 

fprintf('Aligning along dimension %d',dim)
[imageStack,ind]=permuteStack(imageStack,dim);

if average
    mu=squeeze(mean(imStack,4));    


    %Calculate the motion and correct
    [registered,OffsetPixel,diffPhase]=...
        correctTranslation(mu,cFrame);
    out.registered=registered;
    out.OffsetPixel=OffsetPixel;
    out.diffPhase=diffPhase;

    %But now the "registered" stack contains the mean image. This
    %is no good! So we apply it to all planes of the original. 
    for ii=1:size(imageStack,3)
        tmp=squeeze(imageStack(:,:,ii,:));        
        reg=translateSlices(tmp,out.OffsetPixel, out.diffPhase(ii));
        imageStack(:,:,ii,:)=permute(reg,[1,2,4,3]);
    end
    
else
    
    for ii=1:size(imageStack,5)
        fprintf('.')
        tmp=squeeze(imageStack(:,:,:,1,ii));
        
        %Calculate the motion and correct
        [registered,OffsetPixel,diffPhase]=...
            correctTranslation(tmp,cFrame);
        out(ii).OffsetPixel=OffsetPixel;
        out(ii).diffPhase=diffPhase;        
        imageStack(:,:,:,1,ii)=registered;
        
        %do for channel 2
        %The following seems to run correctly but I'm only 90% sure
        %that it's doing what it's supposed to do. 
        tmp=squeeze(imageStack(:,:,:,2,ii));        
        tmp=permute(tmp,[1,2,4,3]);
        for jj=1:size(tmp,4)
            reg=translateSlices(squeeze(tmp(:,:,:,jj)),...
                                out(ii).OffsetPixel,...
                                out(ii).diffPhase(jj));
            reg=permute(reg,[1,2,4,5,3]);
            imageStack(:,:,jj,2,ii)=reg; 
        end
    end

    
    
end
fprintf('\n')


%Now we return the image-stack to the original organisation
[~,ind]=sort(ind);
imageStack=permute(imageStack,ind);




%permute imagestack for alignment. This function will set the 4th
%dimension is that over which we collapse the data to align and set
%the 3rd dimension to be time.
function [imStack,ind]=permuteStack(imStack,dim)
    ind=1:5; ind(dim)=[];
    ind=[ind,dim];
    if dim<3
        ind=[ind(1),ind(3),ind(2),ind(4),ind(5)];
    end
    imStack=permute(imStack,ind);
