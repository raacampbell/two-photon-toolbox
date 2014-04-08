%% filterImageStack
%
% |function data=filterImageStack(data,PlayOption,verbose,filt)|
%
%% PURPOSE
% - Smooths using a selection of different options (see file) such
%   convolving with a 2-D or 3-D Gaussian. Only works on one channel. 
%
%% INPUTS
% * data [structure] containing data. Produced, for example, by
% importPrairieViewData. data can have length >1. 
% 
%
% * |PlayOption| -  [scalar] Determines if raw data movies will be
%   played and if so with what frame rate. If PlayOption>=0 then
%   show movies of the raw data and smoothed data with delay
%   PlayOption seconds added to the inter-frame interval. If <0
%   then no movies are shown. Values between 0 and 0.1 are sensible
%   for viewing movies. [-1 by default]
% * |filt| - optional string ('2d','3d'). 2d is default. If data were
%   already filtered then no filtering is done. The 2-D filtering
%   makes no difference to the final results (e.g. a KC's dF/F over
%   time) but the image stacks do look substantially better and
%   with a half pixel SD there is negligable chance of introducing
%   significant correlations between neighbouring cells. The 3D
%   filtering will both  filter in time and this is almost
%   certainly a bad idea at this point. Nonetheless, the option is
%   here for those who want it. 
%
%  
%% Outputs
% Returns a structured array containing the the imported image stack and
% other useful information. This is passed to subsequent functions
% and more information is appended to the structure. For details on
% the structure see the end of this function. 


  
