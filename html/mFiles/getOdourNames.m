%% getOdourNames
% Summarise stimuli used in one experiment
%
% |function [odours,uniqueOdours,oInd]=getOdourNames(data)|
%
%% Purpose
% A time-saving function to report which odour was presented for
% each stimulus, the unique odours presented, and the indecies at
% which each of these odours appear. 
%
%% Outputs
% * |odours| - the presented odour for each stimulus
% * |uniqueOdours| - simply |unique(odours)|
% * |oInd| - the indecies of the data structure containing each
%              odour.
%
%% Note 
% If only one output argument is called then odours will be a
% structure containing this information. This structure will
% potentially be more useful but too much code uses the 3 separate
% arguments so this function will be backwards compatable for
% now. The 3 args are *deprecated* so use the odours structure if
% possible. 
