function varargout=overlayDFFandBaseline(data,maxVal,cmap,muInt,baseLine)
% overlay of significant dF/F onto baseline image and plot
%
% function H=overlayDFFandBaseline(data,maxVal,cmap,muInt,baseLine)
%
% Purpose
% makes a plot with significant dF/F pixels overlaid on to top of
% the baseline image with respect to which the dF/F was computed.
% If data has length>1 then the routine will average the dF/F in
% each element of the structure and return a plot showing the
% average dF/F over all repeats.
%
%
% Inputs
% * data - the product of  generateDFFobject (one element) 
% * maxVal - scalar defining the maximum value for the colour map
% * cmap - a string specifying the name of the colourmap to use
% * muInt - [optional] mean dF/F to overlay 
% * baseLine - the baseline image to use
%
% Output
% * H - axis handles
%
% Rob Campbell, March 2009
%
% 10/01/09 - for Jen: modified to accept threshold & colour map

if nargin<2 , maxVal=[]; end
if nargin<3 || isempty(cmap), cmap='hot'; end
if nargin<4 || isempty(muInt), muInt=cleanMeanDFF(data,0); end
if nargin<5, baseLine=data.baselineImage; end



%Note: the commented out brighten commands may be needed to get a
%plot which looks good on a projector.

gmap=gray(100);
baseLine=mat2im(baseLine,gmap);
%baseLine=real2rgb(data.baselineImage,gmap);

climits=[min(muInt(:)),max(muInt(:))];
if ~isempty(maxVal), climits(2)=maxVal; end

%Small changes in flouresence aren't interesting so we want to get rid
%of these. Either we can get rid of the bottom %P of max or we can
%take an absolute number (e.g. everying below 10% is removed).

thresh='relative';
switch lower(thresh)
    case 'relative'
        %make the bottom P% of max vanish
        P=10;
        DF=[zeros(P,3);eval([cmap,'(100-P)'])];
    case 'abs'
        tmp=climits(1):diff(climits)/100:climits(2);
        f= tmp<=0.1;
        DF=eval([cmap,'(100)']);
        DF(f,:)=0;
    case 'middle' %works well with redblue colormap
        %keep only the outer P% tails
        P=45;
        DF=eval([cmap,'(100)']);        
        DF=[DF(1:P,:); zeros(100-P*2,3); DF(end-P+1:end,:)];
end


if isempty(maxVal)
    muInt=mat2im(muInt,DF);
else
    muInt=mat2im(muInt,DF,[nan,maxVal]);
end

%Use first ROI only
%Just in case:
for i=1:3
    muInt(:,:,i)=muInt(:,:,i).*data.ROI(1).roi;
end


%Combine the two images.
im=(muInt+baseLine); %this regulates the relative intensity of
                          %the background and evoked response


%im=im/max(im(:)); %This doesn't seem to be needed


%subimage(im);
subimage(im);
H.main=gca;
axis off, box on

border=bwboundaries(data.ROI(1).roi);
hold on
for ii=1:length(border)
    H.border(ii)=plot(border{ii}(:,2),border{ii}(:,1),'g-');
end
hold off




%Make a customized colorbar for the dF/F
pos=get(gca,'position'); % L B W H
H.colorbar=axes('position',[pos(1)+pos(3)*0.99,...
                    pos(2)+pos(4)*0.1,...
                    pos(3)*0.1,...
                    pos(4)*0.8]);


colBar=ones(length(DF),1,3);
colBar(:,1,:)=DF;
colBarWidth=round(length(colBar)*0.08);
colBar=repmat(colBar,[1,colBarWidth,1]);

subimage(colBar)
axis xy

L=length(colBar);
ticks=1:L/8:L;
ticks=round(ticks);

scale=climits(1):climits(2)/L:climits(2);

tickLabels=round((scale(ticks)*1E2))/1E2;

set(gca,'YAxisLocation','right',...
    'XTick',[],...
    'YTick',ticks,...
    'YTickLabel',tickLabels)
title('dF/F')


drawnow


if nargout==1
    varargout{1}=H;
end
