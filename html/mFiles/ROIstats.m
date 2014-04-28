%% ROIstats
% dF/F for each cell over time
%
% |function OUT = ROIstats(data,ROIindex,doPlot,alpha,doFDR,extraTime)|
% 
%% Purpose
% Calculate dF/F for each ROI over time and determines which cells
% respond significantly. Optionally, plots the results using an
% external function call. The ROI is generally generated by selectROIs.
% 
%% Inputs
% * |data| -  should be the smoothed, motion-corrected, and
% photobleach-corrected structure (e.g. data) produced by functions
% cleanImageStack.m and PhotoBleachCorrection.m
% * |ROIindex| - the index of the ROI structure for which stats should
% be calculated. By default it finds the field named 'soma' and
% calculates stats for that. This variable is optional and can be
% an index or a string (it looks up the ROI names in ROI.notes).
% * |doPlot| - 0 be default. if ==1 then make pretty plots. 
% * |alpha| - the significance level [0.01 by default]
% * |doFDR| - apply the FDR based approach to determine significance:
%         see main body of function. [Optional, zero by default].
% * |extraTime| - [optional, see responsePeriodFrames for default]
% defines for how long after the end of the stimulus we will
% average the dF/F. If it's a vector length 2 then it defines the
% start and end frame we will use for the analysis.
%
%
%% Outputs
% Calculates a matrix of ROI dF/F for each frame and the indecies
% which were significant. 
%
%
%% Note
% Significance test algorithm is:
% # Determine the SD of the baseline period
% # Choose alpha level (e.g. 0.01). Using the baseline, determine
%   number of SDs which correspond to this alpha for a one-sided
%   test. This is the threshold for significance
% # Smooth function and save this 
% # The response is significant if one or more frames during the
%   "response period" (stim period plus 3 seconds) is greater than
%   this threshold. 
% 
% As noted above, it is possible to apply the False Discovery Rate
% (FDR) to this: http://en.wikipedia.org/wiki/False_discovery_rate
%
% This test _does_ assume that the values in the baseline are
% normally distributed. If this is not the case, then p-value will
% be "wrong." The result is that alpha=0.05 may not be a good boundary
% for a significance cut-off. The user should look at the
% distribution of p-values over all experiments, search for an
% elbow in the graph, and use that p-value as the threshold. This
% was the procedure employed in Honegger, Campbell & Turner, 2011
% (J. Neurosci.). 