%% alignRepeats
% Conduct translation correction across trials
%
% |function [data,out]=alignRepeats(data,...)|
%
%% Purpose:
% Attempt to align recordings obtained over many stimulus repeats.
%
% Automatically run in parallel if the user has multiple cores and
% enabled these. Likely you need 4 or more cores to make this
% worthwhile. 

%% Align with default parameters:
% |alignRepeats(data)|
%
%% Inputs:
% * |data| - The twoPhoton data object
% * |alignRepeats(data,'param1',value1)|
%
% Prameter/value pairs:
% 
% * |verbose| - 1 by default. 
% * |reg| - which registration to use. e.g. if the stacks were
% registered with an FFT then elastix b-spline, then data.info.muStack will
% have a 3rd dimension with a length of 3: un-registered,
% translated, then elastix + translation. You can choose which
% level to use. If the registration was "comitted" (see
% <regParams.html |regParams|>)
% then you won't have access to all three. Only the combined
% transform. 
% * |params| - structure containing parameter values (structure
%          fields) and parameter values (structure field values)
%          for the image registation routines. If not specified,
%          defaults are used. See individual files for the defaults
%          and possible options. Only parameters the user wants to
%          alter need to be defined in the structure.
% * |reference| - which mean stack (i.e. stimulus presentation) is to
%             be the target image for alignment. 
% * |reg| - Which set of registered stacks to use? If there are
%       multiple alignments done on the stack (e.g. translation
%       then b-spline), the user gets a choice as to which level of
%       alignment to use. This is only possible if the alignments
%       have not been comitted to disk. e.g. If reg is 0 then the
%       un-aligned stacks are used. The default is to use ALL
%       alignment steps. 
%
% * |algorithm| - The registration algorithm to use (see
% <alignStack.html |alignStack|>)
%
%% Outputs:
% * |out| - a structure containing the before and after results of the
%       correction. 
%
