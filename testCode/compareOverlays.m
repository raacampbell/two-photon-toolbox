function compareOverlays(dataA,dataB)
% function compareOverlays(dataA,dataB)
%
% Make two overlay plots side by side showing two sets of responses
%
% 
  
clf
subplot(1,2,1)
overlayDFFandBaseline(dataA)


subplot(1,2,2)
overlayDFFandBaseline(dataB)
