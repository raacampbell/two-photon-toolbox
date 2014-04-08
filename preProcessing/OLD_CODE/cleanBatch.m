function data=cleanBatch(data)
% Wrapper for applying cleanImageStack across trials
%
% function data=cleanBatch(data,keys)
%
% Purpose: smooth and motion correct a structure with multiple
% elements. 
%
% Inputs:
% data - twoPhoton object. 
% options - see twoPImportBatch
%
% Rob Campbell, April 2009
  
fprintf('* Aligning *\n')  

if nargin==1
    options.parallel=0;
    options.image_filtering='none';
    options.motion_correction='fft';
end

filt=keys.options.image_filtering;
mCor=keys.options.motion_correction;

if keys.options.parallel
    parfor ii=1:length(data)
        fprintf('%d/%d. ',ii,length(data))
        tmp(ii)=cleanImageStack(data(ii),-1,mCor,0,filt);
        fprintf('\n')
    end
else
    for ii=1:length(data)
        fprintf('%d/%d. ',ii,length(data))
        tmp(ii)=cleanImageStack(data(ii),-1,mCor,0,filt);
        fprintf('\n')
    end
end


data=tmp;

