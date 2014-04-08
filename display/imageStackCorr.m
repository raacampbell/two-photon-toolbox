function out= imageStackCorr(im, ref)
% extracts correlation between 1st and later frames from one trial
%
% function out= imageStackCorr(im)    
%
% Purpose
% plots the correlation between the first frame and later frames
% from one stimulus presentation. 
%
% Inputs
% im - image-stack
% ref - the image with respect to which the xcorr will be
% performed. 
%  * If ref is a scalar then correlate imStack with respect to
%    imStack(:,:,ref).
%  * If ref has length==2 then correlate imStack with respect to
%    imStack(:,:,ref(1):ref(2)).
%  * If ref is a 2-d matrix then correlate imStack with respect to
%    this.   
%
% Outputs
% out - the change in correlation over time (starting from frame 2)
%
% Rob Campbell - January 2010

if nargin<2,
    ref=1;
end

if length(ref)==2
  cImage=mean(im(:,:,ref(1):ref(2)),3);
elseif length(ref)==1
  cImage=im(:,:,ref);
else %assumes a 2-d matrix
  cImage=ref;  
end

one=cImage(:);

for ii=1:size(im,3)
    
    t=im(:,:,ii);
    t=t(:);
    c=corrcoef(t,one);
    
    out(ii)=c(2);
end

    
   
