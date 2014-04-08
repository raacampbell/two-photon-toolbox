function data=filterImageStack(data,PlayOption,verbose,filt)

% function data=filterImageStack(data,PlayOption,verbose,filt)
%
%
% PURPOSE
% - Smooths using a selection of different options (see file) such
%   convolving with a 2-D or 3-D Gaussian. Only works on one channel. 
%
% INPUTS
% * data [structure] containing data. Produced, for example, by
% importPrairieViewData. data can have length >1. 
% 
%
% * PlayOption [scalar] Determines if raw data movies will be
%   played and if so with what frame rate. If PlayOption>=0 then
%   show movies of the raw data and smoothed data with delay
%   PlayOption seconds added to the inter-frame interval. If <0
%   then no movies are shown. Values between 0 and 0.1 are sensible
%   for viewing movies. [-1 by default]
% * filt - optional string ('2d','3d'). 2d is default. If data were
%   already filtered then no filtering is done. The 2-D filtering
%   makes no difference to the final results (e.g. a KC's dF/F over
%   time) but the image stacks do look substantially better and
%   with a half pixel SD there is negligable chance of introducing
%   significant correlations between neighbouring cells. The 3D
%   filtering will both  filter in time and this is almost
%   certainly a bad idea at this point. Nonetheless, the option is
%   here for those who want it. 
%
%  
% OUTPUTS
% Returns a structured array containing the the imported image stack and
% other useful information. This is passed to subsequent functions
% and more information is appended to the structure. For details on
% the structure see the end of this function. 
%
%
% Rob Campbell, 2009
  
  
%Recursive function call if needed  
if length(data)>1
  for ii=1:length(data)
    data(ii)=filterImageStack(data(ii));
  end
  return
end


% ----------------------------------------------------------------------
% Step One: Define key parameters which the user may want to tweak.
if nargin<1, error('Must supply data'), end
if nargin<2 | isempty(PlayOption), PlayOption=-1; end
if nargin<3 | isempty(verbose), verbose=0; end
if nargin<4 | isempty(filt), filt='2d'; end


%FILTERING
Hsize=7; %Size of gaussian filter (pixels), should be ~6 x GaussianSigma
GaussianSigma=0.5;%Size of gaussian filter (pixels), should be ~6 x GaussianSigma


%FILTERING
%Choose the filter type: '2d' or '3d'
%If 3d then we convolve the image stack with a Gaussian
%the averages adjacent frames (i.e. it has size
%[Hsize,Hsize,2]). The best practice is to use light 2-D filtering
%here then apply a filter in the time domain to the dF/F (perhaps a
%Kalman filter) for visualization only.

%Don't filter if this has already been done
if strmatch('filter',fieldnames(data(1).process)) %isfield and isprop don't work (?)
    if ~strcmp(data.process.filter.filt,'none') & ~isempty(data.process.filter)
        filt='none';
    else 
        data.process.filter.filt=filt;
    end
    
else
    data.process.filter.filt=filt;    
end

%Get data from disk
imageStack=data.imageStack;

if PlayOption>=0
  orig=imageStack;
end



% ----------------------------------------------------------------------
% Step Two: Low Pass filter the image. 
%
% Here we have the option for creating a 3-D filter and averaging
% over time. Not a good idea because it's not reversible and
% smooths the data quite heavily in time. 3-D filtering must be
% done after the motion correction!

switch lower(filt)

    case '2d'
        fprintf('; 2-D filtering')
        H=fspecial('gaussian',Hsize,GaussianSigma);
        
        for ii=1:nDepths
            for jj=1:size(imageStack,3)
                imageStack(:,:,jj,1,ii)=imfilter(imageStack(:,:,jj,1,ii),H);
            end            
        end

    case '3d' %Not recomended
        fprintf('; 3-D filtering')
        H=fspecial('gaussian',Hsize,GaussianSigma);
        
        ave=2; %number of frames to average over
        filt3D=repmat(H,[1,1,ave]);
        filt3D=filt3D/sum(filt3D(:));
        imageStack(:,:,end+1)=imageStack(:,:,end); %avoid edge artifacts
        
        imageStack=convn(imageStack,filt3D,'same');
        imageStack(:,:,end)=[];
end




%Update data object
data.process.filter.gauss=[Hsize,GaussianSigma];
imageStack=single(imageStack);



%Replace the file on the disk. Filtering is slow, so yet another reason
%not to do this is that it takes too long to implement on the fly.
saveRawData(data,imageStack,0)



%Now play the new movie if requested. 
if PlayOption>=0
  clf
  subplot(1,2,1)
  imagesc(orig(:,:,1))
  axis off, axis equal
  
  subplot(1,2,2)
  imagesc(imageStack(:,:,1))
  axis off, axis equal
  
  
  S=size(imageStack,3);
  for n=1:1    
    for frame=1:S
        
      subplot(1,2,1)
      chil=get(gca,'children');
      set(chil(end),'CData',orig(:,:,frame))
      title(sprintf('Original %d/%d',frame,S))
      drawnow

      subplot(1,2,2)
      chil=get(gca,'children');
      set(chil(end),'CData',imageStack(:,:,frame))
      title(sprintf('Corrected %d/%d',frame,S))
      drawnow
      pause(PlayOption)
    end

  end
  
end


