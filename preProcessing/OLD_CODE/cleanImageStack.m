function data=cleanImageStack(data,PlayOption,mCorrect,verbose,filt)
% Conduct translation correction and 2-D filtering for each trial.
% If there are multiple depths, then the routine treats them
% seperately. i.e. motion correcting them independently, de-noising
% independently. It doesn't assume there to be a volume. Currently
% doesn't know anything about a second channel.
%
%
% function data=cleanImageStack(data,PlayOption,mCorrect,verbose,filt)
%
%
% PURPOSE
% - Linearly corrects lateral motion artifact.
% - Smooths using a selection of different options (see file) such
%   convolving with a 2-D or 3-D Gaussian.
%
% INPUTS
% * data [structure] containing data. Produced, for example, by
% importPrairieViewData. data should have a length of 1. See
% ./import/runBatch.m
% 
%
% * PlayOption [scalar] Determines if raw data movies will be
%   played and if so with what frame rate. If PlayOption>=0 then
%   show movies of the raw data and smoothed data with delay
%   PlayOption seconds added to the inter-frame interval. If <0
%   then no movies are shown. Values between 0 and 0.1 are sensible
%   for viewing movies. [-1 by default]
% * mCorrect -- 
%   'fft'  - fft-based translation correction (same as 1)
%   'symcuda' - 2D symmetric registration (requries CUDA-compatable GPU)
%   If mCorrect is anything else, we don't correct for motion
%
% * filt - optional string ('none','2d','3d'). If data were
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
  
  
  

% ----------------------------------------------------------------------
% Step One: Define key parameters which the user may want to tweak.
if nargin<1, error('Must supply data'), end
if nargin<2 | isempty(PlayOption), PlayOption=-1; end
if nargin<3 | isempty(mCorrect), mCorrect='fft'; end
if nargin<4 | isempty(verbose), verbose=1; end
if nargin<5 | isempty(filt), filt='none'; end


%MOTION CORRECTION
%We will adjust for lateral movement by minimizing the square difference
%from a control frame. This be defined as the mean of frames define
%by cFrame. Try to use some smarts to guess this.
cFrame=[1,ceil(2.25/data(1).info.framePeriod)];
fprintf('Using frames %d to %d as the reference\n',cFrame)

%FILTERING
Hsize=7; %Size of gaussian filter (pixels), should be ~6 x GaussianSigma
GaussianSigma=0.5;%Size of gaussian filter (pixels), should be ~6 x GaussianSigma


%FILTERING
%Choose the filter type: '2d', '3d', or 'none'
%If 3d then we convolve the image stack with a Gaussian
%the averages adjacent frames (i.e. it has size
%[Hsize,Hsize,2]). The best practice is to use light 2-D filtering
%here then apply a filter in the time domain to the dF/F (perhaps a
%Kalman filter) for visualization only.

%don't filter if this has already been done
if strmatch('filt',fieldnames(data)) %isfield and isprop don't work (?)
    if ~strcmp(data.filt,'none') & ~isempty(data.filt)
        filt='none';
    else 
        data.filt=filt;
    end
    
else
    data.filt=filt;    
end

%Get data from disk
imageStack=data.imageStack;

if PlayOption>=0
  orig=imageStack;
end




% ----------------------------------------------------------------------
% Step Two: Adjust for lateral movement.
% Note that smoohing should be done after motion correction!
nDepths=size(imageStack,5);

switch mCorrect
  case 'fft'
    fprintf('translation correction')
    for ii=1:nDepths
        tmp=squeeze(imageStack(:,:,:,1,ii));
        tmp=correctTranslation(tmp,cFrame,verbose);
        imageStack(:,:,:,1,ii)=tmp;
    end
    
  case 'symcuda'
    fprintf('symmetric CUDA registration')    
end

    



% ----------------------------------------------------------------------
% Step Three: Low Pass filter the image. 
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
    case 'none'
        fprintf('; skipping filtering')

end




%Update data object
data.gauss=[Hsize,GaussianSigma];
imageStack=single(imageStack);
data.info.muStack=mean(imageStack,3); 



%Replace the file on the disk 
fprintf('; saving to disk.')
fileStr=[data.info.rawDataDir,'/','rawData', num2str(data.info.stimIndex)]; 
eval(['rawData',num2str(data.info.stimIndex),'=imageStack;'])
save(fileStr,['rawData',num2str(data.info.stimIndex)],'-v6')
clear('raw*')  


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


