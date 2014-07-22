function varargout=imStacks2Icy(data,ind)
% Send a bunch of image stacks to Icy to view them simultaneously 
%
% function stacks=imStacks2Icy(data,ind)	
%
% Purpose
% It's important that the same cell is in the same location over time. We 
% generally determine this by taking the mean of image stack (one per stim 
% presentation) and making a movie of these. The problem with this, is that
% we're not looking at the quality of the individual movies. 
% A solution to this is to use Icy, http://icy.bioimageanalysis.org and that
% is what this function does. 
%
% Usage/Installation 
% To use this function you must install Icy (see above) and then all the 
% MATLAB communicator plugins. One of these will bring up instructions for
% adding its functions to the path. Do this. Then you can run this function,
% which will send your image stacks to Icy. 
%
%
%
%
% Inputs
% a. data is 2-photon data structure and ind are the indexes of the stim 
%    presentations to send to Icy. If ind is empty then all are loaded 
%    from disk and sent. 
%
% b. data can be a cell array of image stacks. In this case, ind is ignored.
%    Thus input format allows for the image stacks to be loaded from disk
%    by MATLAB and then re-used. The stacks are exported by this function
%    as an optional output argument. Caution, this can use a lot of RAM!
%
% 
% Outputs
% stacks [optional] - a cell array of the image stacks sent to Icy. Caution!
%   this can use a lot of RAM. 
%
%
% Viewing in Icy
% Press shift-g to tile images in a grid. Then shift-1 to lock them. Then 
% play the movies and they are all in sync. Hover the mouse over a movie and
% the cursor position is copied to the others. You can pan and zoom, too. 
%
% Rob Campbell - Basel - July 2014



%Handle cell array
if iscell(data)
	for ii=1:length(data)

		if length(data)>1
			fprintf('Sending stack %d/%d to Icy\n',ii,length(data))
		end

		icy_vidshow(data{ii},['Stack ',num2str(ii)]);
	end

	if nargout==1
		varargout{1}=1;
	end
	return
end



%Handle 2-photon structure
if nargin==1
	ind=1:length(data)
end


for ii=1:length(ind)
	if length(data)>1
		fprintf('Sending stack %d/%d to Icy\n',ii,length(ind))
	end

    im=data(ind(ii)).imageStack;

    icy_vidshow(im,['Stack ',num2str(ind(ii))]);
    
    if nargout==1
    	OUT{ii}=im;
    end
end


if nargout==1
	varargout{1}=OUT;
end



