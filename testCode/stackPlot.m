function stackPlot(data,slice)
% function mbVolumePlot(data,slice)
%
%
% Plots 3-D volume in data.imageStack. 
% If slice exists and is an integer between 1 and size(data.imageStack,3) then
% draw this on the volume plot. 
%
%

if nargin==1, slice=0; end

imageStack=data.imageStack;
if slice>size(imageStack,3), slice=0; end

%Work out the values for the x,y,z axes

x=ones(size(imageStack,1),1) * [1:size(imageStack,2)];
y=[1:size(imageStack,1)]' * ones(1,size(imageStack,2));


z=ones(1,1,size(imageStack,3));
z(:,:,1:size(imageStack,3))=data.info.positionCurrent_ZAxis;




%Decimate image stack to save memory
decimateBy=3;
imageStack=imageStack(1:decimateBy:end,1:decimateBy:end,:);

x=x(1:decimateBy:end,1:decimateBy:end);
y=y(1:decimateBy:end,1:decimateBy:end);

z=repmat(z,[size(x),1]); %this is in micrometers
x=repmat(x,[1,1,size(imageStack,3)]);
y=repmat(y,[1,1,size(imageStack,3)]);

%convert x and y to micrometers
x=x.*data.info.micronsPerPixel_XAxis;
y=y.*data.info.micronsPerPixel_YAxis;


%Smooth data
imageStack=smooth3(imageStack);

%Plot 3D surface
clf
thresh = 0.045;             %Define empirically
contourSlice(imageStack,[],[],1:3:20)


if slice
  X=xlim;
  Y=ylim;
  Z=[data.info.positionCurrent_ZAxis(slice-1),...
     data.info.positionCurrent_ZAxis(slice+1)];
  sp=patch([X(1),X(2),X(2),X(1), X(1),X(1),X(1), X(2),X(2),X(1)],...
           [Y(1),Y(1),Y(2),Y(2), Y(2),Y(1),Y(1), Y(1),Y(2),Y(2)],...
           [Z(1),Z(1),Z(1),Z(1), Z(2),Z(2),Z(2), Z(2),Z(2),Z(2)],...
           1);
  
  set(sp,'edgecolor','none','facecolor','r','facealpha',0.5,...
         'specularexponent',100)


end

%Render nicely

set(gcf,'Color','white','renderer','OpenGL')

lighting gouraud
box on, grid off, axis equal

set(gca,'XTick',[],'YTick',[],'ZTick',[])
camlight(0,45)
camlight(180,125)
view(3)


% To import surface into a 3D renderer, we extract vertices and faces and
% construct an OBJ file:
%
% [f,v]=isosurface(zstack,thresh);
% patch2blender(v,f,'fname.obj')
