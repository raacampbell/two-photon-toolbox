%% Analysing neurons
% This tutorial describes how to manually select neuronal cell bodies,
% extract data from the cell body ROIs, and make simple plots of
% the results. 
%
%% Selecting Cell Bodies
% Run |selectROIs(myDataStructure)| and use the GUI to select
% cell bodies. Each time you click, a circle with a defined diameter
% is placed onto the image. The image then animates through each
% trial (each displayed frame is the mean of a different trial) so
% you can check that your cell body remains in the ROI on all
% trials. Click "undo" if you're not happy with your selection. You
% can change the size of the circle and it is recommended that you
% keep it small enough to avoid it overlapping with adjacent
% cells. Leaving a margin to avoid overlap is more important than
% striving to get every pixel from each cell. When you're finished,
% click "done" and you will find a new |ROI| field has been added
% to your data object. This contains a mask (|ROI.roi|) that defines where each
% cell is located. You can go back and modify the mask (adding and
% removing cells) by re-running <selectROIs.html |selectROIs|>.
%
% We will use an existing data structure with selected cells. 
cd ~/work/Matlab_Scripts/ImagingAnalysis/examples
load KCexample.mat

%% Mean evoked response 
% Let's look at the mean evoked dF/F during the response window:

clf
overlayDFFandBaseline(data(1))

%%
% This is a slice through the _Drosophila_ mushroom body. The
% background flourescence is shown in gray. The line that divides
% brain from backgrond is in green. Some evidence of the
% motion-correction can be seen on the top right corner. The somata of
% the Kenyon Cells, which make up the mushroom body, are scattered
% along the diagonal region of the image. There are many strong evoked
% responses in this trial. On the colour-scale, a value of 1.0
% indicates a 100% change in dF/F. The more indistinct-looking region
% in the top right is the calyx, where the Kenyon cells recieve input
% from olfactory projection neurons of the antennal lobe.


%% Viewing Selected Cells
% We have already selected the locations of the KC somata. These
% are stored in:
data(1).ROI(2)

%%
% The |roi| matrix is the mask that defines the locations of the
% cell bodies. So we can do:
clf
imagesc(data(1).ROI(2).roi)
axis equal off

%% Extracting Neuronal Data
% The <addROIstats.html |addROIstats|> function creates the
% |.stats| field which contains:
data(1).ROI(2).stats

%%
% The fields in |.stats| contain the following information. 
%
% * |sigResponses| - Indecies of rows containing neurons which responded
% significantly to the stimulus. 
% * |dff| - the dF/F time course of each selected neuron. Rows
% are neurons and columns are frames. Neuronal traces are smoothed
% in the time domain. 
% * |alpha| - The significance threshold employed to determine
% |sigResponses|. 
% * |sigRank| - For each neuron, the number of frames in the
% response period in which the signal is significantly greater than
%  the baseline. 
% * |pValue| - The associated significance p-value for each neuron.
% * |doFDR| - Whether a correction for multiple comparisons (the
% False Discovery Rate, FDR) was applied. 
%
%% Determining Significance 
% The <addROI_stats.html |addROI_stats|> function calls another
% function called <ROIstats.html |ROIstats|> to produce the |.stats|
% field. It is this function which conducts the significance test
% according to the following algorithm:
%
% * Determine the standard deviation of the baseline period.
% * Choose alpha level (default is 0.01). Determine number of SDs which
%   correspond to this alpha for a one-sided test. This is the
%   threshold for significance
% * Smooth the response time course
% * A neuron is said to respond significantly if one or more frames during the
%   "response period" (stim period plus 3 seconds) is greater than
%   the above threshold. 
% 
% The optionally applied
% <http://en.wikipedia.org/wiki/False_discovery_rate False
% Discovery Rate (FDR)> controls for the fact that there
% are multiple frames in the response period. 
%
% This test _does_ assume that the values in the baseline are
% normally distributed. If this is not the case, then p-value will
% be "wrong." The result is that alpha=0.05 may not be a good boundary
% for a significance cut-off. The user should look at the
% distribution of p-values over all experiments, search for an
% elbow in the graph, and use that p-value as the threshold. This
% was the procedure employed in Honegger, Campbell & Turner, 2011
% (J. Neurosci.). 

%% Viewing The Results
% The most informative plot of neuronal activity from a single
% trial is obtained using <plotROIstats.html |plotROIstats|>
clf
set(gcf, 'InvertHardCopy', 'off'); %To get the gray background
plotROIstats(data(1))
%%
% This plot provides the following information
%
% * The surface plot on the left shows the dF/F of each KC sorted
% according to significance rank. The neurons with the largest number
% of significant bins are at the bottom of the trace. The ordering of
% the cells is, therefore, not strictly according to response
% magnitude.  
% * Neurons below the horizontal red line have at least
% one significant bin, which is taken to mean that they responded
% significantly. Neurons above the red line did not respond
% significantly. By default we set alpha to 0.01 and do not use the
% FDR. The significance test passes the sanity check: In most cases,
% the location of the red line is where one would place it by
% eye. Note that the distribution of response significance is naturally
% smooth and an imposed threshold is arbitrary. Occasionally some
% apparently insignificant neurons are be deemed significant and
% some apparently significant ones are rejected. This is nothing to
% loose sleep over. 
% * The dashed vertical lines indicate the time over which the
% stimulus was presented. 
% * The top right plot shows the response time courses of all the
% insignificant cells. 
% * The bottom right plot shows the response time courses of all the
% significant cells. 
%
%%
% We can also plot the mean evoked response of each neuron over all
% stimuli
clf
plotROItuningCurves(data)

%%
% This can be broken down by stimulus repeat:
clf
plotROItuningCurves(data,'average',0)

%%
% Now each row is one trail. Stimuli were presented in a random
% order, but this function groups them for display purposes. The
% presence of the vertical structure in the plot is important: it
% indicates that repeated presentations of the same stimulus (same
% odor in this case) evoke similar responses in the same
% cell. i.e. this plot provides evidence that the responses are
% reproducible and that likely there are few motion artefacts and
% that the prep is stable. 

%% Further Analyses And Summary Statistics
% The similarities in the patterns of active cells between trials
% can be visualised using <odour3Dplot.html |odour3Dplot|> and
% <odourDendrogram.html |odourDendrogram|>. 
