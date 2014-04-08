function varargout=showSelectedKCs(data,ROIindex,label,frames,flip)
% Overlay h=selected KCs onto a mean image of the stack
%
% function showSelectedKCs(data,ROIindex,label,frames,flip)  
%
% Purpose
% Overlay selected KCs onto a mean image of the stack
%
% Inputs
% data - twoPhoton object following processing with selectKCs
%
% ROIindex - which ROI to use for the calulation. By default
% ROIindex is the string 'soma', but it can also be the index of
% the ROI    
%
% label - optional [zero by default]. If 1 then add numeric labels
%         to each circled KC/ROI. 
% frames - optionally specify which go into making the mean image. 
% flip - rotate the plot
%
% Outputs
% h - optionally return plot handles to the cell ROIs
%
% Rob Campbell, Sept. 2009
  
if nargin<2 | isempty(ROIindex), ROIindex='soma'; end
if nargin<3, label=0; end


if ischar(ROIindex)
    ROIindex=strmatch(ROIindex,{data(1).ROI.notes});
end

N=neuronMeanVar(data,[],0);

if length(data)>1
    disp('selecting first rep for background image')
    data=data(1);
end
if nargin<4 | isempty(frames)
    frames=1:length(data.relativeFrameTimes); 
end

if nargin<5, flip=0; end


imageStack=data.imageStack(:,:,frames);

%Check if there are multiple depths
if length(size(imageStack))==5
    depths=1;
else
    depths=0;
end


if depths
    sp=numSubplots(size(imageStack,5));
    for PP=1:size(imageStack,5)
        subplot(sp(1),sp(2),PP)
        plotHelper
    end
    
end



function plotHelper

mu=squeeze(double(mean(imageStack,3)));
%mu=conv2(mu,ones(2),'same');
mu=mu(:,:,PP);

G=mat2im(mu,gray(100));
if flip, G=rot90(G); end

H.I=imshow(G);


thisROI=data.ROI(ROIindex).roi(:,:,PP);

KCs=thisROI;
if flip, KCs=rot90(KCs); end
KCs(KCs==0)=nan;
KCs(KCs>0)=1;
KCs=im2bw(KCs);
B=bwboundaries(KCs);

hold on

sig=find(N.sigInd);


c=ROI2centroid(thisROI);

for ii=1:length(B)
  boundary=B{ii};

  
  %Identify which cells are significant responders. 
  mu=mean(boundary);
  nr=findNearest(c,fliplr(mu),'rows');

  H.p(nr)=plot(boundary(:,2), boundary(:,1), 'b','LineWidth',0.5);
  H.centroid(nr,1)=mean(boundary(:,2));
  H.centroid(nr,2)=mean(boundary(:,1));
  H.sig(nr)=0;
  if ~isempty(find(sig==nr))
      set(H.p(nr),'color','r')
      H.sig(nr)=1;
  end

  
  if label
      text(mean(boundary(:,2)), mean(boundary(:,1)), num2str(nr),...
           'color', 'g')
  end
  
end

[B,L] = bwboundaries(data(1).ROI(1).roi,'noholes');
hold on
for i=1:1%length(B)
    H.bound(i)=plot(B{i}(:,2),B{i}(:,1),'k-','linewidth',2);
end
    

hold off

if nargout==1
    varargout{1}=H;
end

end %ENDS SUB FUNCTION



end %ENDS MAIN FUNCTION BODY
