%% Kalman_Stack_Filter
% Apply a Kalman filter to the time dimension of an image stack
%
% |function imageStack=Kalman_Stack_Filter(imageStack,percentvar,gain)|
%
%% Purpose
% Implements a predictive Kalman-like filter in the time domain of the image
% stack. Algorithm taken from
% <http://rsb.info.nih.gov/ij/plugins/kalman.html Java code by
% C.P. Mauer>.
%
%% Inputs
% * |imageStack| - a 3d matrix comprising of a noisy image sequence. Time is
%              the 3rd dimension. 
% * |gain| - the strength of the filter [0 to 1]. Larger gain values means more
%        aggressive filtering in time so a smoother function with a lower 
%        peak. Gain values above 0.5 will weight the predicted value of the 
%        pixel higher than the observed value.
% * |percentvar| - the initial estimate for the noise [0 to 1]. Doesn't have
%              much of an effect on the algorithm. 
%
%% Output
% |imageStack| - the filtered image stack
%
%% Note
% The time series will look noisy at first then become smoother as the
% filter accumulates evidence. 
