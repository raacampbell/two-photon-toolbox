function [data,out]=alignOverReps3D(data,out)
% Conduct translation correction across trials
%
% function [data,imageStack]=alignOverReps3D(data,rotationCor,correctionType)
%
% Purpose:
% Attempt to align recordings obtained over many stimulus repeats
% of a TZ series. Works on the 5-D image stacks
%
% Inputs:
% * data - the twoPhoton data object
% * correctionType: [optional] fftSlow by default, can also be
%   fftQuick. 
%
% Method:
% The mean of each image stack (trial) is obtained and the
% translation shifts are calculated. The fftQuick approach (the
% default) applies this shift to all frames from each
% trial. Alternatively, the slower, fftSlow approach allows
% individual frames within a trial to have different translation
% shifts. This is usually not required. 
%
% Rob Campbell, June 2009

if length(data)==1
    return
end

if nargin<2
%First we load the RFP from each image stack at a time. We take the
%mean over time for each, allowing us to calculate the x/y shift
%for each slice over over time
im=squeeze(mean(data(1).imageStack(:,:,:,1,:),3));
mu=ones([size(im),length(data)]);
mu(:,:,:,1)=im;
fprintf('Building mean image stack')
for ii=2:length(data)
    fprintf('.')
    mu(:,:,:,ii)=squeeze(mean(data(ii).imageStack(:,:,:,1,:),3));   
end
fprintf('\n')


%We now want to loop through the depths and for each perform a
%translation correction;
fprintf('Translation correction')
for ii=1:size(mu,3)
    fprintf('.')
    [~,op,dp]=correctTranslation(squeeze(mu(:,:,ii,:)),1);
    OffsetPixel(:,:,ii)=op;
    diffPhase(:,ii)=dp;
    
end
fprintf('\n')


out.OffsetPixel=OffsetPixel;
out.diffPhase=diffPhase;
end


if nargin==2
    OffsetPixel=out.OffsetPixel;
    diffPhase=out.diffPhase;
end


%now this needs to be applied to all the image stacks
OffsetPixel=permute(OffsetPixel,[3,2,1]);
diffPhase=diffPhase';
clear out
n=1;
out=[];

%this may well be wrong. The last depth in particular is way out..
fprintf('Applying correction')
for jj=1:length(data)
    imageStack=data(jj).imageStack(:,:,:,:,:);
    fprintf('.')
    for ii=1:size(imageStack,5)
        tmp=squeeze(imageStack(:,:,:,1,ii));
        reg=translateSlices(tmp,squeeze(OffsetPixel(:,:,ii)),...
                            diffPhase(jj,ii));
        imageStack(:,:,:,1,ii)=reg;

        tmp=squeeze(imageStack(:,:,:,2,ii));
        reg=translateSlices(tmp,squeeze(OffsetPixel(:,:,ii)),...
                            diffPhase(jj,ii));
        imageStack(:,:,:,2,ii)=reg;        
        
    end
    eval([data(ii).info.rawDataFile,'=imageStack;'])
    fileStr=[data(ii).info.rawDataDir,'/',data(ii).info.rawDataFile];
    save(fileStr,data(ii).info.rawDataFile)
    clear('raw*')
end

fprintf('\n')
