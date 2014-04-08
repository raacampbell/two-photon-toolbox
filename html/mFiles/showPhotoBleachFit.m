%% showPhotoBleachFit
% Plot time-series before and after photo-bleach correction
% 
% |function showPhotoBleachFit(data)|
%
%% Purpose
% Make a nice plot showing the time-course of the mean intensity of
% the raw data and the photo-bleach fit we have applied to
% this. Show also the before and after fits. Note that the
% bleach-corrected data are actually the residuals about the fit
% line and so are normalised to the fit. 
%
%% Inputs
% |data| - the twoPhoton object
%
%% Example
%
cd ~/work/Matlab_Scripts/ImagingAnalysis/examples/
load KCexample.mat
showPhotoBleachFit(data(5))

%% Notes
% Photo-bleaching is not always evident but it is not uncommon to see
% other non-stationarities. For instance, it is often the case that
% fluorescence intensity the first few frames is low due to the
% Pockels cell ramping up. This function removes effects such as
% these.
%
% The fit doesn't always make sense so some caution should be employed
% when using this function. For the fitting to work well you will
% need a reasonably long period before and after the stimulus in
% order for the response to return to baseline. For this reason,
% there are certainly instances when not correcting for bleaching
% is a good idea. 
