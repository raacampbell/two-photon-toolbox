%% Pre-Processing
%
% This guide continues from the <imagingAnalysis_importing.html
% importing> tutorial. The following steps should work correctly
% regardless of which software was used to generate the data and record the
% stimulus parameters. The following are covered here:
%
%
%% De-noising
% You might want to de-noise your data and replace the .mat files from
% the import with the de-noised (i.e. smoothed) versions. There are
% various ways of de-noising 2-photon data. Some are quite
% advanced. As an example, the <twoPImportBatch.html
% |twoPImportBatch|> function provides the option of running a simply
% smoothing filter on each frame independently. It does this by an
% optional call to the <filterImageStack.html |filterImageStack|>
% function during import-time. The filtering performed by this
% function is rather simplistic and is not recommended for most
% purposes. It simply serves as an example of what's possible. In
% general, such smoothing only serves to produce response movies that
% look nicer. The smoothing doesn't improve the quality if the data
% which you actually analyse (and it may even make it worse). This is
% because what's actually analysed is the mean evoked response of each
% ROI or neuron. Conducting your analyses with the goal of producing
% movies that look good is not something you want to be doing in most
% circumstances. The reader interested in de-noising could consult:
% <http://www.plosone.org/article/info:doi/10.1371/journal.pone.0020490
% |http://www.plosone.org/article/info:doi/10.1371/journal.pone.0020490|>
%
%
%% Motion correction
% For _in vivo_ recordings, motion correction is often critical since
% most data analyses require the same bit of brain to be in
% the same location across trials. This allows the user to draw an
% ROI around a brain region in one trial and know that the same bit
% of brain is within that fixed ROI in all other trials. Thus, the
% stimulus-evoked dF/F of the ROI can be calculated on each trial
% and so a tuning curve can be drawn. 
%
% Unfortunately, it is common for the brain to drift over the course
% of an experiment. If the brain has drifted in _z_ then obviously no
% correction is possible off-line. Recordings with a lot of _z_-motion should
% be excluded. Lateral drift, however, can be corrected as can
% moderate non-linear deformations (which we find to be quite
% common our mushroom body recordings). 
%
% Image sequences are aligned in two steps. First of all,
% <alignStack.html |alignStack|> corrects all frames within one
% stimulus repeat. Then  <alignRepeats.html |alignRepeats|> aligns
% all frames across different trials. 
%
% See <alignStack.html |alignStack|> for a list of the various
% different motion-correction algorithms available. The |fftquick|
% is a quick, 2-D, sub-pixel translation correction. In many cases
% it is sufficient. If a brain exhibits significant _z_-motion then
% chances are you can't correct it. If, on the other hand, what
% you're seeing is motion in the _x_/_y_ plane, then some
% degree of correction is often possible. Sometimes the results are
% quite dramatic. The key to getting a good motion correction is
% identify what sort of motion you're seeing and then apply the
% right algorithm to fix this. The wrong aglorithm can make things
% worse. Examaine the image stack before and after correction to
% decide how to proceed. This is best achieved by
% experience. See the Examples section of this Help to read through
% a worked example. Also, there are examples in the help sections
% of <alignStack.html |alignStack|> and  <regParams.html |regParams|>.
%
%% Finding the Region Of Interest (ROI)
% In our recordings the flourescent brain tissue is surrounded by
% non-flourescent background. This step uses the <ROI_batch.html
% ROI_batch> function to separate brain from background:
% |ROI_batch(exampleObject)|. By default we have the same ROI for
% each trial, but this is optional. This function adds a field
% called |ROI| to each trial. The first ROI contains:
cd ~/work/Matlab_Scripts/ImagingAnalysis/examples/TSeries-02032010-1558-002
load exampleData
ROI_batch(exampleData);

%%
exampleData(1).ROI     

%%
% This ROI segragates brain from background and *should not be
% deleted*, as it is used in later analysis steps. The |ROI.roi| mask
% itself is a matrix of ones and zeros. Here, the region inside the
% ROI is shown in white and outside in black:
clf
imagesc(exampleData(1).ROI.roi)
axis equal tight, colormap gray 

%%
% We can now show the baseline image minus the background by doing:
clf
imagesc(exampleData(1).baselineImage .* exampleData(1).ROI.roi)
axis equal off

%%
% The region outside the ROI is considered to be "background" and
% its mean is subtracted from all pixel values when calculating the
% dF/F. It is worth noting that if some brain is present in the
% background then this could significantly bias the calculation. If
% you are recording from, say, cortex then you probably don't want
% to separate brain from background since everywhere is
% brain. However, you will need to create suitable data in ROI(1)
% so that analysis functions have an estimate of the background
% intensity. 
        
%% Photo-Bleach Correction
% Laser scanning bleaches the flourescent indicator and so pixel
% intensity will tend to decrease over the recording period. This
% decrease isn't interesting and so we try to correct for it if it's
% significant. This process is known as photo-bleach correction and is
% achieved by running: |doPhotoBleachCorrection(exampleData)|
%
%%
% The correction is fitted to the response time course (i.e. the mean
% of each frame over time). First the frames which may contain a
% significant response are removed (for this reason we need the
% stimulus onset and offset times in the |.stim| field of the object)
% and replaced by a linear interpolation. The trace is then heavily
% smoothed (i.e. low-pass filtered). This smoothed trace is considered
% to contain only non-stimulus-related features and is subtracted from
% the original time series. The correction procedure does not replace
% the data on the disk, instead it stores the correction curve in the
% |twoPhoton| object and applies it each time the data are
% loaded. This makes it easy to change the correction at a future time
% if needed, perhaps because the above correction algorithm doesn't
% work for you. 

%%
% Usually one has to scan for long periods (e.g. over a minute) to
% see significant bleaching. If trials are shorter than this, the
% bleaching may well be insignificant and so it makes little sense
% to try to correct for it. Because evoked dF/F is calculated
% independently on each trial, photo-bleaching across trials is
% automaticaly taken care of. 

%%
% It is easy to examine the result of the photo-bleach correction
% using the following function call. 
showPhotoBleachFit(exampleData(1)) 

%% 
% Here we have chosen not to apply a correction because the response
% massively outweighs any possible bleaching that might occur. Note
% that signal intensity rises over the first 2 or 3 frames. This is
% due to the Pockels cell. 


%% Now What?
% The data are now saved and pre-processed (motion-corrected and
% photo-bleach-corrected) and you can move on to the real
% analysis. You will now want to do one or more of the following:
%
% * Work with the whole-brain ROI to produce summary statistics,
% images, and movies. 
% * Use <ROI_add.html |ROI_add|> to define one or more ROIs, which
% can then be compared.
% * Manually identify neuronal cell bodies to
% <imagingAnalysis_neurons.html explore patterns of neuronal activation>.


