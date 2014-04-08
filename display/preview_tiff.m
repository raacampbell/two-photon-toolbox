function preview_tiff(fname,framePeriod,clipVal)
% function preview_tiff(fname,framePeriod,clipVal)
%
% Purpose
% Previews a tiff produced by, say, ScanImage. Plays a movie and shows the intensity
% histogram in case one wants to view a sub-set of the pixel values. 
%
% Inputs
% * framePeriod [OPTIONAL, empty by default] if empty or a nan then the display 
% period of each frame is 0.05s. Otherwise, if this is a scalar, the user can define
% their own frame period.
%
% * clipVal [OPTIONAL] if this exists and is a scalar than set this as the maximum value of
% of the image stack. If it's a vector then it is treated as [min,max] and only values within
% that range are kept
%
% Rob Campbell - May 2012


if nargin<2, framePeriod=[]; end
if nargin<3, clipVal=nan; end

if ~strcmp(fname(end-3:end),'.tif')
	fname=[fname,'.tif'];
end
TIFF=load3Dtiff(fname);


clf
set(gcf,'name',fname)
axes('Position',[0.1,0.73,0.8,0.22])
deciBy=10;
[n,x]=hist(TIFF(1:10:end),250);
h=plot(x,n,'-b','LineWidth',2);
set(gca,'YScale','log')


xlim([0,max(TIFF(:))])
title(sprintf('Pixel intensity (every %d^{th} pixel)',deciBy))

if ~isnan(clipVal)
	if length(clipVal)==1
		clipVal=[0,clipVal];
	end

	hold on
	plot([clipVal(1),clipVal(1)],ylim,'r--')
	plot([clipVal(2),clipVal(2)],ylim,'r--')
	hold off
	TIFF(TIFF>clipVal(2))=clipVal(2);
	TIFF(TIFF<clipVal(1))=clipVal(1);
end


axes('Position',[0.20,0.03,0.6,0.6])
playMovie(TIFF,0.05,1,1)
