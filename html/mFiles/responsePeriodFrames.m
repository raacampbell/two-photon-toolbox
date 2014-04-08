%% responsePeriodFrames
% Determine which frames fall into the response period
%
% |function rp=responsePeriodFrames(data,extraTime)|
%
%% Purpose
% Calculate the frames which we will call our response period.
%
%% Inputs
% * |data| - one element of the twoPhoton data object    
% * |extraTime| - home many seconds to add to the response period
%             following the end of the odour offset frame. [optional]
%
%
%% Outputs
% * |rp| - a two-element vector defining the first and last frame of
% the response period.

    
