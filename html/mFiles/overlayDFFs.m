%% overlayDFFs
% Overlay significant dF/F pixels from two recordings and plot
%
% |function overlayDFFs(dataA,dataB)|
%
%% Purpose
% Mean Significant dF/F pixels from structures in dataA are
% overlaid with those from dataB (using different colours) and all
% are plotted on top of the the dataA(1).baselineImage.
%  
% If dataA or dataB have length>1 then the routine will average the
% dF/F in each element of the structure. 
%
%
%% Inputs  
% * data - the product of generateDeltaFoverF
