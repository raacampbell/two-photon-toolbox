function [dataMatrix,dataMatrix3d] = kcResponseMatrix(data,matrixType,extraTime,subDivide,doPlot)
% Calculate response of each cell to each stimulus
%
% function [dataMatrix,dataMatrix3d] = kcResponseMatrix(data,matrixType,extraTime,subDivide,doPlot)
%
% Purpose
% Produce a 2-D matrix describing the activity of each cell to each
% stimulus. By default this is the mean activation during the response
% period. Assumes that the same KC mask has been applied to each
% recording in the array. 
%
% Inputs
% * data: the twoPhoton data structure. Assumes that the KC stats
%   field has been added by addKC_stats
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
    


if nargin<2 | isempty(matrixType), matrixType='mean'; end
if nargin<3, extraTime=[];      end
if nargin<4 | isempty(subDivide), subDivide=1;       end
if nargin<5, doPlot=1;          end
nStim=length(data);
nCells=size(data(1).KCstats.kcDFF,1);



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
    error('kcResponseMatrix: Subdivide has an unknown value')    
end


%Check for stupidly high dF/F
thresh=3;
f=find(dataMatrix>thresh);
if ~isempty(f)
    fprintf(['Warning! kcResponseMatrix has found %d points with ' ...
             'dF/F >%d. These have been zeroed.\n'], length(f),thresh)
    dataMatrix(f)=0;
end

if doPlot
    imagesc(dataMatrix)
end



%this function returns a particular matrix type
function tmp=helperFunct
    tmp=zeros(nStim,nCells);

    switch lower(matrixType)
      
      case 'mean'    
        meanResp
      
      case 'binary'  
        for ii=1:length(data)
            tmp(ii,data(ii).KCstats.sigResponses)=1;
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
            multiplyMatrix(ii,data(ii).KCstats.sigResponses)=1;
        end
        tmp=tmp.*multiplyMatrix;
    end

    
    function meanResp
        for jj=1:length(data)
            numFrames = rp(2)-rp(1)+1;
            tmp(jj,:)=nansum(data(jj).KCstats.kcDFF(:,rp(1):rp(2)),2)/numFrames;
        end
    end
end


end
