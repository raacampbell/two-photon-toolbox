function imStack=preProcess(imStack,data)
% function imStack=preProcess(imStack,data)
%
% PURPOSE
% Pre-processes the image stack on disk before being returned to
% the user. The main purpose of this to apply the motion-correction
% code. But it could apply anything, including the photo-bleach
% fit, that we currently aren't implementing here. 
%
% Called by the imageStack method of the twoPhoton object. 
%
%
% Rob Campbell - CSHL - 2012/2013



verbose=1; %Verbosity level



%Should probably move the photo-bleach and background-subtraction
%here. 


if ~isfield(data.process,'registration')
    return
end

if length(data.process.registration)==1 & ...
    isempty(data.process.registration{1})
    return
end

if length(data.process.registration)<data.process.regSeries
    return
end

if verbose>2
    fprintf('pre-processing imageStack: ');
end

reg=data.process.registration{data.process.regSeries};

params.verbose=0;
params.parallel=1; %Will need to put this somewhere more clever

for ii=1:length(reg)


    if isempty(reg(ii).routine), continue, end
    if reg(ii).skip, continue, end
    if ~isfield(reg(ii),'coef'), continue, end

    switch reg(ii).routine
      case 'ffttrans'
        if verbose, fprintf('fftrans '), end
        imStack=apply_ffttrans(imStack,reg(ii).coef,params);
      case 'symmetric'
        if verbose, fprintf('symmetric '), end
        imStack=apply_symmetric(imStack,reg(ii).coef,params);
      case 'elastix'
        if verbose, fprintf('elastix '), end
        imStack=apply_elastix(imStack,reg(ii).coef,params);
      case 'demon'
        if verbose, fprintf('demon '), end
        imStack=apply_demon(imStack,reg(ii).coef,params);
      case 'gkerr'
        if verbose, fprintf('gkerr '), end
        imStack=apply_gkerr(imStack,reg(ii).coef,params);
      otherwise    
        fprintf('Can''t find %s ',reg(ii).routine)
    end
    
    %If less than 0.1% of pixels are >1 we will just set them to 1
    maxLim=1;
    f=find(imStack>1);
    p=(length(f)/length(imStack(:)))*100;
    imStack(f)=1;
    if p>maxLim
        fprintf('preProcess: warning! More than %0.2f%% of pixels were >1 (%0.2f%%)',maxLim,p);
    end

    %If less than 3% of pixels are <0 we will just set them to 0
    minLim=7.5;
    f=find(imStack<0);
    p=(length(f)/length(imStack(:)))*100;    
    imStack(f)=0;
    if p>minLim
        fprintf('preProcess: warning! More than %0.2f%% of pixels were <0 (%0.2f%%)',minLim,p);
    end

    
end




if verbose & isfield(reg(ii),'coef'), fprintf('\n'), end
