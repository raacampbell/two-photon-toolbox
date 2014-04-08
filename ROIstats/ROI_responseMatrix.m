function varargout = ROI_responseMatrix(data,ROIindex,matrixType,extraTime,subDivide,doPlot)
% Calculate response of each cell to each stimulus
%
% function [dataMatrix,dataMatrix3d] = ROI_responseMatrix(data,ROIindex,matrixType,extraTime,subDivide,doPlot)
%
% Purpose
% Produce a 2-D matrix describing the activity of each cell to each
% stimulus. By default this is the mean activation during the response
% period. Assumes that the same KC mask has been applied to each
% recording in the array. 
%
% Inputs
% * data: the twoPhoton data structure. Assumes that the ROI stats
%   field has been added by addROI_stats
% 
% * ROIindex: which ROI to use for the calulation. By default
%   ROIindex is the string 'soma', but it can also be the index of
%   the ROI    
%    
% * matrixType: optional argument defining how activity will be
%   quantified. Options are mean, binary, zscore, and shufflecells;
%   see function body for what these do. 
%
% * extraTime - optional, empty by default. Specifies over how many
%   seconds offset we should average data. An empty value will lead
%   us to use the default in responsePeriodFrames (probably 4 or 5
%   seconds but see that function. If extraTime is a vector of
%   length 2, then this defines the exact frames to use. is used to
%   decide which frames go into the final analysis. 
% 
% * subDivide - into how many bins we should divide the
%   responses. This is useful for cases where we want to see
%   whether we can extract information from the temporal properies
%   of the response. Subdivide is 1 by default, meaning that we
%   will average the data into one bin. A value of 2 will produce 2
%   bins and so forth. We can't have more bins then we have
%   frames. The number of columns in dataMatrix will be equal to
%   nCells*subDivide. So we if subDivide>1 then extra time bins
%   will appear as extra columns. This is the format which will be
%   useful to a classifier. Alternatively, setting subDivide>1 will
%   make it possible to use the second output of this function,
%   where each time slice is returned in the 3rd dimension of the
%   output matrix. 
% * doPlot - if 1 we make the plot (default). zero we make no
%   plot. If 2 we divide the data by stimulus so it's more obvious
%   how repeatable are differnent presentations of the same stimulus.
%
%
% Outputs
% * dataMatrix - 2-d matrix where each row is a different stimulus
%   presentation and each column is a different cell. If
%   subDivide>1 then columns will consist of multiple time-slices
%   from all cells. See above. 
% 
% * dataMatrix3d - 3-d matrix where each row is a different
%   stimulus and each column a different cell. The 3rd dimension
%   contains the time slices which were asked for in subDivide.
%    
%
% Rob Campbell, August 2009
%
% Also see: nNeurons2p, neuronMeanVar
    

if nargin<2 | isempty(ROIindex), ROIindex='soma'; end
if nargin<3 | isempty(matrixType), matrixType='mean'; end
if nargin<4, extraTime=[];      end
if nargin<5 | isempty(subDivide), subDivide=1;       end
if nargin<6, doPlot=1;          end

if ischar(ROIindex)
    ROIindex=strmatch(ROIindex,{data(1).ROI.notes});
end



nStim=length(data);


nCells=size(data(1).ROI(ROIindex).stats.dff,1);



%We will use the same response window size for all stimulus
%responses. 
if length(extraTime)<2
    respP=responsePeriodFrames(data(1),extraTime);
else
    respP=extraTime;    
end

if subDivide>1
    delta=diff(respP);
    dFrames=floor(delta/subDivide);
    if dFrames==0
        fprintf(['kcReponseMatrix: user asked for %d slices but only ' ...
                 '%d frames. Returning %d slices\n'],...
                subDivide,delta,delta)
        dFrames=delta;
        subDivide=delta;
    end

    dataMatrix=zeros([nStim,nCells,subDivide]);    
    rp=[respP(1),respP(1)+dFrames];

    kk=1;
    while 1
        dataMatrix(:,:,kk)=helperFunct;
        rp=rp+dFrames+1; %+1 so windows don't overlap


        if rp(1)>respP(2)
            break
        elseif rp(2)>respP(2)
            rp(2)=respP(2);
        end
        kk=kk+1;
    end
    dataMatrix=dataMatrix(:,:,1:kk);

    dataMatrix3d=dataMatrix;
    dataMatrix=reshape(dataMatrix,size(dataMatrix,1),...
                       size(dataMatrix,2)*size(dataMatrix,3));
elseif subDivide==1
    rp=respP;
    dataMatrix=helperFunct;
else
    error('ROI_responseMatrix: Subdivide has an unknown value')    
end



if doPlot==1
    imagesc(dataMatrix)
elseif doPlot==2
    clf
    O=getOdourNames(data);
    col=lines(length(O.oInd)+1);
    oInd=[];
    for ii=1:length(O.oInd)
        oInd=[oInd;O.oInd{ii}];
        n(ii)=length(oInd);
    end
    imagesc(dataMatrix(oInd,:))

    params={'FontWeight','Bold','FontSize',9,...
            'HorizontalAlignment','right'};

    hold on
    for ii=1:length(O.oInd)
        plot(xlim,0.5+[1,1]*n(ii),'-w')
        odour=strrep(O.uOdours{ii},'_',' ');
        odour=strrep(odour,'-',' ');
        text(-1.35,n(ii)-3,odour,...
             params{:},'Color',col(ii,:))
    end
    
    axis normal
    xlabel('Cells')

    axis square
    set(gca,'YTick',[],'XTick',[1,size(dataMatrix,2)],...
        'XTickLabel',[1,size(dataMatrix,2)],...
        'Color','None')

    hold off

end


if nargout>0 
    varargout{1}=dataMatrix;
end
if nargout>1 & exist('dataMatrix3d','var')
    varargout{2}=dataMatrix3d;
end




%this function returns a particular matrix type
function tmp=helperFunct
    tmp=zeros(nStim,nCells);
    switch lower(matrixType)
      
      case 'mean'    
        meanResp
        
      case 'binary'  
        if ~isfield(data(1).ROI(ROIindex).stats,'sigResponses')
            return
        end
        
        for ii=1:length(data)
            tmp(ii,data(ii).ROI(ROIindex).stats.sigResponses)=1;
        end
      
      case 'shufflecells'    
        meanResp
        for ii=1:length(data)
            tmp(ii,:)=tmp(ii,randperm(nCells));
        end
      
      case 'zscore'  
        meanResp
        for ii=1:length(data)
            tmp(ii,:)=zscore(tmp(ii,:));
        end
      
      case 'threshold'  
        meanResp
        multiplyMatrix=zeros(size(tmp));
        for ii=1:length(data)
            multiplyMatrix(ii,data(ii).ROI(ROIindex).stats.sigResponses)=1;
        end
        tmp=tmp.*multiplyMatrix;
    end

    
    function meanResp
        for jj=1:length(data)
            numFrames = rp(2)-rp(1)+1;
            tmp(jj,:)=nansum(data(jj).ROI(ROIindex).stats.dff(:,rp(1):rp(2)),2)/numFrames;
        end
    end
end


end
