%% overlayDFFandBaseline
% overlay of significant dF/F onto baseline image and plot
%
% |function overlayDFFandBaseline(data,maxVal,cmap,muInt)|
%
%% Purpose
% makes a plot with significant dF/F pixels overlaid on to top of
% the baseline image with respect to which the dF/F was computed.
% If data has length>1 then the routine will average the dF/F in
% each element of the structure and return a plot showing the
% average dF/F over all repeats.
%
%
%% Inputs
% * |data| - the product of  generateDFFobject (one element) 
% * |maxVal| - scalar defining the maximum value for the colour map
% * |cmap| - a string specifying the name of the colourmap to use
% * |muInt| - optional matrix to overlay 
%
%% Examples
%
% Plotting one response. The |clf| is important since this
% function does not clear the figure. 
cd ~/work/Matlab_Scripts/ImagingAnalysis/examples
load KCexample.mat
clf
overlayDFFandBaseline(data(1))

%%
% |overlayDFFandBaseline| does not clear the figure after it's
% run so to add multiple subplots we just do
clf
subplot(1,2,1)
overlayDFFandBaseline(data(2))
subplot(1,2,2)
overlayDFFandBaseline(data(3))
