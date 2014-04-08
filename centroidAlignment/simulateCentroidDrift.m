function simulateCentroidDrift(n,noise,doPlot)
%  function simulateCentroidDrift(n,noise,doPlot)
%
% Simulates translation and rotation of a volume of cell bodies and
% applies a correction. Optionally add noise, whose range in um is
% defined by the second argument (zero by default). 
%
% Rob Campbell, August 2010
  

  if nargin<2
    noise=0;
  end
  if nargin<3
    doPlot=3;
  end
  
  
  
  r=rand(3,n)*80; %sort of in microns
  r=r-repmat(mean(r,2),1,n); %center
  
  %Translation magnitudes
  x=8;
  y=30;
  z=-30;
  
  %Rotation magnitudes
  Rx=10;
  Ry=-3;
  Rz=0;
  
  
  %shift point cloud
  steps=60;   
  r=repmat(r,[1,1,steps]);
  for ii=2:steps
    
    r(1,:,ii)=r(1,:,ii-1)+x/steps;
    r(2,:,ii)=r(2,:,ii-1)+y/steps;
    r(3,:,ii)=r(3,:,ii-1)+z/steps;
    
    r(:,:,ii)=rotateMatrix(r(:,:,ii), Rx/steps,0,0);
    r(:,:,ii)=rotateMatrix(r(:,:,ii), 0,Ry/steps,0);  

  end

  %add noise
  r=r+rand(size(r))*noise;
  
  
  %Now we try to correct this. 
  corrected=r;
  clf
  if doPlot
    tmp=abs([corrected,r]);
    tmp=max(tmp,[],3);
    tmp=max(tmp,[],2);
    tmp=tmp+tmp*0.33;
  end
  
  for ii=2:steps
      %Align everything with the first frame
    corrected(:,:,ii)=alignCentroids(corrected(:,:,1),...
                                     corrected(:,:,ii),doPlot);

    if doPlot
      chil=get(gcf,'children');
      set(chil,'xlim',[-tmp(1),tmp(1)],...
               'ylim',[-tmp(2),tmp(2)],...
               'zlim',[-tmp(3),tmp(3)])
      drawnow
      pause(0.1), end
  end
  

    
