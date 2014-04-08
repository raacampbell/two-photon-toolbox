%% regParams(data,varargin)
% add, remove and modify the registration parameters 
%
% |function regParams(data,'param1',value1,...)|
%
%% Purpose
% This function is the Swiss army knife of image
% registration. It's very useful for exploring and comparing
% different image registration scenarios. 
% 
%% Inputs
% * |data| - the twoPhoton data object
%%
% Remaining arguments are in the form of parameter/value pairs. Note,
% however, that the function is *not* designed to run with more than
% one param/value pair per function call. Its behavior may be
% unpredictable if this is done. If it's called with no arguments then
% it prints the analysis steps for each trial to screen.
%
% * |add| - Append registration parameters to data structure. 
% |regParams(data(1),'add',params)|
% * |remove| - 
% Remove parameters 3 and 4 from all repeats
%
% # |regParams(data,'remove',[3,4])|
% # |regParams(data,'remove','coeff')| removes *all* the coefficients
%     but keeps the parameters used to conduct the analysis. This 
%     means the user can re-compute everything but isn't wasting
%     space with redundant parameters. processing is skipped since
%     no coefficients exist. 
% # |regParams(data,'remove','all')| removes everything. clean slate.
%
% * |regseries| - Set registration series to a different value. This parameter
% allows the user to store different sequences of registrations
% side by side so that they can be compared. The default sequence
% has a value of 1. To change this: |regParams(data,'regseries',2)|
% e.g. now we could:
%
%   %<DO NEW REGISTRATION>
%   imNew=data(1).imageStack;
%   regParams(data,'regseries',1) %switch to original
%   imOld=data(1).imageStack;
%   playMovie({imOld,imNew}) %compare the two
%
% If only one series is available and regSeries is set to "2" then
% no registration is done. 
%
% * |skip| -
% Indecies of registrations in the current series that you want to
% skip. |regParams(data,'skip',[1,4])|
% * |unskip| -
% Indecies of registrations in the current series that you want to
% unskip.  |regParams(data,'unskip',[1,4])|
% * |do_until| -
% Do all registrations up to and including index do_until. 
% * |action| - 
% |regParams(data,'action','commit')|
% save corrected data to disk and remove coefficients. add muStack
% to data.info.
% |regParams(data,'action','revert')|
% re-load raw data and re-calculate coefficients if missing. Return to on-the-fly filtering. 
%
%
%% Examples
%
% * You have already conducted a series of registrations and want
% to over-write the raw data on the disk with the corrected
% image-stacks. To do this you do:
%%
%   regParams(data,'action','commit')
%
% * You decide you want revert the saved image-stacks to the raw data
% and return to performing the image registrations on-the-fly. To do
% this you do: 
%%
%   regParams(data,'action','revert')
%
% * Perform a within-stack registration (i.e. not across repeats)
% and compare the before/after imageStacks using regParams:
%%
%   alignStack(data, [1,5]) %perform registration
%   reg=data(1).imageStack; %The registered image
%   regParams(data,'skip',1) %Ask for the registration to be ignored
%   orig=data(1).imageStack; %get the original image-stack
%   playMovie({orig,reg}) %play them as movies side by side
%   playMovie(orig-reg) %play the difference as a movie
%   regParams(data,'unskip',1) %replace the registration 
%
% * You want to compare two different registration sequences.
% In the first we do a within-trial translation correction, then an
% across-repeat translation correction, then an across-trial demon
% registration. Each image-stack will be passed through all three of
% these transforms before being returned to the user. For the
% across-trial transforms, the first repeat is used as the
% reference. 
%%
%   alignStack(data, [1,5]) %Register images within each trial
%   alignRepeats(data, 'verbose',1) %Register images across repeats
%   alignRepeats(data, 'algorithm','demon','verbose',1) %Register the registered images with demon registration
%
% Ok, now we will do a different series of transforms. First a
% within-trial translation correction. Second an across-trial demon
% registration with the 3rd trial as the reference. 
%
%   regParams(data,'regseries',2)
%   data(1).process.regSeries %this now equals 2
%   data(1).imageStack %and this returns the raw data
%   alignStack(data, [1,5],'verbose',1) %Register images within each trial
%   alignRepeats(data, 'algorithm','demon','verbose',1,'reference',3)
%
% Now we can compare the two:
%
%   regParams(data,'regseries',1) %the first one
%   regParams(data) %confirm we're doing the right thing
%   updateMuStack(data) %replace mean images with this reg series
%   [~,R1]=visualiseDrift(data); %Get the x-corr matrix
%   v1=visualiseDriftMovie(data); %The movie
%   regParams(data,'regseries',2) %the second one
%   updateMuStack(data) %replace mean images with this reg series
%   [~,R2]=visualiseDrift(data); %Get the x-corr matrix
%   v2=visualiseDriftMovie(data); %The movie
%% 
% Now we can compare the two:
%   subplot(1,2,1), imagesc(R1), set(gca,'CLim',[0,1]), colorbar
%   subplot(1,2,2), imagesc(R2), set(gca,'CLim',[0,1]), colorbar
%
%   playMovie({v1,v2})
%   playMovie(v1-v2)
