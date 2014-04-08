%% showNeuronTuningCurves
% Find and plot all the "significant" tuning curves 
%
% |function kc=showNeuronTuningCurves(data,oneplot,doPlot)|
%
%% Purpose
% Find all the "significant" tuning curves and plot them with
% asscociated error bars. 
%
%% Inputs
% * |data| - 2 photon data object or it can be the kc struct outputed
%        by this function. In which case, plot this and don't sort
%        or do anything. 
% * |oneplot| - [1 by default] 
%           1: each plot in it's own sub-plot. 
%           0: make a new plot for each significant response
%           if onplot is a vector of neuron indecies then plot each
%           neuron in the list on its own subplot. Does not search
%           for significant neurons in this instance. 
% * |doPlot| - 1 by default. if 0 then we only return the stuff that
%          would have been plotted.     
