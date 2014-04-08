function varargout=plotROItuningCurves(data,varargin)
% Calculate & display mean response to each odour for each ROI
%
% function out=plotROItuningCurves(data,params,...)
%
% Purpose
% Calculate and display mean response to each stimulus for each
% ROI. Typically an ROI is a single cell. Note that this function
% sorts the tuning curve and unit indecies!
%
% Inputs
% data - twoPhoton data object
% roi - which ROI to use for the calulation. By default
%            ROIindex is the string 'soma' by default. If there is
%            no soma field, the function simply uses the
%            brain/background (first) ROI. Any other ROI in the
%            .ROI structure can also be used.
% sortType - sort rows alphabetically or by response magnitude, or
%            not at all: 'alph','mag', 'none'. 'alph' by default.
% extraTime - modify the response time period (help responsePeriodFrames)
% doPlot - 1 by default. If 0, no plot is made. 
% average - 1 by default and averages all trials of the same
%           stimulus. If 0, plot trials separately. If there is
%           only one ROI (e.g. a buig neuropil region) then average
%           is set to zero and we make a notBoxPlot.
% adaptCorrect - if 1 try to correct for adaptation over reps if
%                the field exists. see ROI_adaptationCorrection
% stimName - By default the function searches for the "odors" field
%            in stim and uses this to sort evoked responses. You
%            can over-ride this here by providing a different
%            string. The string should be the name of a field in
%            the structure data.stim. 
%
% Outputs
% out - a structure containing the data used to make the plot. This includes 
%       plot handles. 
%
% Rob Campbell - October 2009
% updated 06 2012 to allow for all repeats to be shown. handles are
% returned.
%
% 13/05/30  - the function inputs were getting awkward to deal
% with, so switch to a parameter/value pair system. 


%Parse the inputs
IN=inputParser;

addRequired(IN,'data')


addOptional(IN,'extratime',[],@isnumeric);
addOptional(IN,'doplot',1,@isnumeric);
addOptional(IN,'average',1,@isnumeric);
addOptional(IN,'adaptCorrect',0,@isnumeric);
addOptional(IN,'stimName','odours');

roiValid = @(x) isnumeric(x) || isstr(x) ;
addOptional(IN,'roi','soma', roiValid)

defaultSort='alph';
validSort = {'alph','mag','none'};
checkSort = @(x) any(validatestring(x,validSort));
addOptional(IN,'sortType',defaultSort,checkSort);


parse(IN,data,varargin{:})

ROIindex=IN.Results.roi;
sortType=IN.Results.sortType;
extraTime=IN.Results.extratime;
doPlot=IN.Results.doplot;
average=IN.Results.average;
adaptCorrect=IN.Results.adaptCorrect;
stimName=IN.Results.stimName;

%Check that we can find the ROI
doSort=0; %CAN CAUSE PROBELEMS SINCE IT'S NOT REVERSIBLE

if ischar(ROIindex)
    ROIindex=strmatch(ROIindex,{data(1).ROI.notes});
end
    
if isempty(ROIindex)
    if length(data(1).ROI)>0
        ROIindex=1;
    else
        fprintf('Can''t find any ROIs. Exiting')
        if nargout>0
            varargout{1}=[];
        end
        return
    end
    
end

%Find when each odour was presented
if isfield(data(1).stim,'odour') & strmatch(stimName,'odours')
    stim=getOdourNames(data); 
    
    switch lower(sortType)
      case 'alph'
        %sort alphabetically by odour name
        [stim.uStims,ii]=sort(stim.uOdours);
        stim.sInd=stim.oInd(ii);
      case 'none' %make some fake fields 
        stim.sInd{1}=1:length(data);
        stim.uStims{1}='stimuli';
    end

else
    stim=getStimNames(data,stimName);
end




sROI=size(data(1).ROI(ROIindex).stats.dff);
m=max(cellfun(@length,stim.sInd));

%The raw means so that we know the structure of the variance 
rawData = nan(length(stim.uStims),sROI(1),m); 
sigResponses=nan(size(rawData));
pVals=nan(size(rawData));
%Start and end of the "response period
rp=responsePeriodFrames(data(1),extraTime);


n=1;
%are there data on significant responses
if isfield(data(1).ROI(ROIindex).stats,'sigResponses')
    sigRespField=1;
else
    sigRespField=0;
end
if isfield(data(1).ROI(ROIindex).stats,'correction') && adaptCorrect
    corField=1;
else
    corField=0;
end


for i=1:length(stim.sInd) %Loop through different odours
    thisOdour=stim.sInd{i};

    tmp=nan([sROI,length(thisOdour)]); %to work out the mean
    for j=1:size(tmp,3)
        tmp(:,:,j)=data(thisOdour(j)).ROI(ROIindex).stats.dff;
        rawData(i,:,j)=mean(tmp(:,rp(1):rp(2),j),2);
        
        %if exists, incorporate the adaptation correction
        if corField
            rawData(i,:,j)=rawData(i,:,j)+ ...
                data(thisOdour(j)).ROI(ROIindex).stats.correction;
        end
                
        pVals(i,:,j)=data(thisOdour(j)).ROI(ROIindex).stats.pValue;
        if sigRespField
            sig=data(thisOdour(j)).ROI(ROIindex).stats.sigResponses;
            sigResponses(i,sig,j)=1;
        end
            
    end

end




%Now get the mean evoked response for each stimulus
%These are the tuning curves that can be plotted
plotData=nanmean(rawData,3);

%sort columns by the neuron's overall activity across odours
if doSort
    [x,ii]=sort(mean(plotData,1));
    plotData=plotData(:,ii);
    rawData=rawData(:,ii,:);
    if sigRespField, sigResponses=sigResponses(:,ii,:); end
end


switch lower(sortType)
case 'mag'
    %sort rows by the neuron's overall activity by stimulus
    [x,ii]=sort(mean(plotData,2),'descend');
    plotData=plotData(ii,:);
    rawData=rawData(ii,:,:);
    if sigRespField, sigResponses=sigResponses(ii,:,:); end
    stim.uStims=stim.uStims(ii);
    stim.sInd=stim.sInd(ii);
end


%------------------------------------------------------------
nROIs=size(rawData,2);
if ~average || nROIs==1
    s=size(rawData);
    rawData=shiftdim(rawData,2);    
    plotData=reshape(rawData,size(rawData,1)*size(rawData,2),size(rawData,3));
end

if doPlot %make different plots depending on if we have only one
          %ROI or many ROIs
    
    %For >1 ROI
    if nROIs>1
        
        out.handles.colorPlot=imagesc(plotData);
        xlabel('# KCs')
        set(gca,'XTick',[],'tickdir','out')
        
        if average
            set(gca,'YTick',[1:length(stim.uStims)])    
        end
        
        if ~average
            hold on        
            for ii=s(3):s(3):s(1)*s(3)-s(3)
                plot(xlim,[ii,ii]+0.5,'w-')
            end
            hold off
            set(gca,'YTick',0.5+s(3)/2:s(3):s(1)*s(3))
        end
        
        set(gca,'YTickLabel',stim.uStims)
        
        
        out.handles.colorbar=colorbar;
        set(get(out.handles.colorbar,'title'),...
            'string','\mu_{dF/F}')
        
    elseif nROIs==1
        cla        
        H=notBoxPlot(rawData,[],0.5,'orderedpatch');
        set(gca,'XTickLabel',stim.uStims,'YLimMode','Auto')
        y=ylim;
        if y(1)>0
            ylim([0,y(2)])
        end
        ylabel('dF/F')
        xlabel('stimulus')
        out.boxPlotHandles=H;
    end
    
    
end



%------------------------------------------------------------
%Make an output structure
if nargout==1
    out.plotData=plotData;
    out.rawData=rawData;
    out.pVals=pVals;
    out.stims=stim.uStims;
    out.sInd=stim.sInd;
    if sigRespField, out.sigResponses=sigResponses; end
    varargout{1}=out;
end
