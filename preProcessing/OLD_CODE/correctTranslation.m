function [registered,OffsetPixel,diffPhase]=correctTranslation(imStack,varargin)
% Apply 2-D translation correction to image-stack
%
% function [registered,OffsetPixel,diffPhase]=correctTranslation(imStack,...)
%
% Purpose
% Usually called by cleanImageStack but also can be used to attempt
% motion correction across presentations. Uses an FFT-based method
% which provides 2-D rigid translation correction at sub-pixel
% accuracy and high speed. 
%
% Usage
% correctTranslation(imStack) uses the first frame as a reference
% for all subsequent frames. imStack is a 3-d matrix of images to
% be motion corrected.
%
% correctTranslation(imStack, 'PARAM1', val1, 'PARAM2', val2)
% conducts correction with optional paramater value pairs as
% defined below.
%
%
% 'cFrame' - the image with respect to which the xcorr will be
%            performed. Equals 1 by default. 
%             a. If cCframe is a scalar then correct imStack with
%                respect to imStack(:,:,cFrame).
%             b.  If cFrame has length==2 then correct imStack with
%                 respect to imStack(:,:,cFrame(1):cFrame(2)).
%             c.  If cFrame is a 2-d matrix then correct imStack
%                 with respect to this.   
%
%  'verbose' -  [optional, 0 by default] - if 1 then it plots the
%               performance of the registration. 
%
%  'parallel' - run correction in parallel (requires multiple cores
%               and parallel computing toolbox)
%
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

IN=inputParser;


addRequired(IN,'imStack',@isnumeric);
addOptional(IN,'verbose',0,@isnumeric);
addOptional(IN,'cFrame',1,@isnumeric);
addOptional(IN,'parallel',0,@isnumeric);

parse(IN,imStack,varargin{:})
verbose=IN.Results.verbose;
cFrame=IN.Results.cFrame;
parallel=IN.Results.parallel;


imSize=size(imStack);


%2-D motion will be corrected with respect to the control
%image. This is either >1 frames from the imStack or a different
%image (e.g. to motion correct across stimulus presentations).
if length(cFrame)==2
  cImage=mean(imStack(:,:,cFrame(1):cFrame(2)),3);
elseif length(cFrame)==1
  cImage=imStack(:,:,cFrame);
else %assumes a 2-matrix
  cImage=cFrame;  
end





OffsetPixel=nan(imSize(3),2);
cFFT=fft2(cImage);
registered=nan(imSize);
diffPhase=ones(1,imSize(3));

% We now use the image registration code to register each frame
% with the baseline image to within 0.1  pixels by specifying an
% upsampling parameter of 10. Setting this to <2 will screw up
% the align over reps. Very little speed gain will be achieved by
% changing this value.
usfac=10; %upsampling factor
if parallel
    parfor ii=1:imSize(3)
        thisFFT=fft2(imStack(:,:,ii));
        [output Greg phase] = dftregistration(cFFT,thisFFT,usfac);
        OffsetPixel(ii,:)=output([3,4]);
        registered(:,:,ii)=abs(ifft2(Greg));
        diffPhase(ii)=phase;
    end
else
    for ii=1:imSize(3)
        thisFFT=fft2(imStack(:,:,ii));
        [output Greg phase] = dftregistration(cFFT,thisFFT,usfac);
        OffsetPixel(ii,:)=output([3,4]);
        registered(:,:,ii)=abs(ifft2(Greg));
        diffPhase(ii)=phase;
    end
end


if verbose
    out.cFrame=cFrame;
    out.before=imStack;
    out.after=registered;
    out.offset=OffsetPixel;
    plotTranslation(out)
end
