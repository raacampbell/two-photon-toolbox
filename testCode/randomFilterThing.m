function randomFilterThing(im)
%
% Playing with photoshop we found that filter Z may help to
% highlight edges in the quest for automated KC identification. 

Z=[0,-1,0,-1,0;...
    -1,1,1,1,-1;...
    -1,1,1,1,-1;...
    -1,1,1,1,-1;...
     0,0,0,-1,0];
im=im(50:end,50:end);
wow=conv2(double(im),Z,'same');
colorbar
se=strel('disk',1);

wow=imclose(wow,se);
colormap gray

imagesc(wow)

BW=~im2bw(wow,0.6);

%BW=imdilate(imerode(BW,strel('disk',1)),strel('disk',1));

subplot(1,2,1)
imagesc(BW)
 
 [BOUND,MAP]=bwboundaries(BW,8);  
 
 U=unique(MAP(:));
 subplot(1,2,2)
image(MAP), colormap jet
 for i=1:length(U)
 
     f=find(MAP==U(i));
     if length(f)<2 | length(f)>500       
         MAP(f)=nan;
     end
     
 end
 
return
subplot(1,2,2)
image(MAP), colormap jet
