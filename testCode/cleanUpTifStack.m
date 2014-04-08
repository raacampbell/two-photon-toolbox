function cleanUpTifStack(inputName,outputName,roi,filter)
% function cleanUpTifStack(inputName,outputName,roi,filter)
%
% clean up the tif in inputName by keeping only roi pixels and smoothing
% each frame using filter. saves result as outputname
  
  
frames=tiffFrames(inputName);


for i=1:frames
  if frames>100
    if mod(i,100)==0,fprintf('%d/%d\n',i,frames),end
  end
  
  in=double(imread(inputName,i));

  in=in.*roi;
  in=uint8(imfilter(in,filter));
  
  if i==1
    imwrite(in,outputName,'tif','writemode','overwrite')
  else
    imwrite(in,outputName,'tif','writemode','append')
  end
    
end
