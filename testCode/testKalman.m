

function testKalman(imageStack)
%
% what are the best params for the Kalman Filter??
  

clf  


subplot(1,2,1)    
gain=[0.2,0.4,0.6,0.8,0.9];
plot(getMean(imageStack),'.k-')
hold on
drawnow
J=jet(length(gain));
for i=1:length(gain)
  kal=Kalman_Stack_Filter(imageStack,0.05,gain(i));
  plot(getMean(kal),'.k-','color',J(i,:))
  drawnow
end
legend(num2str([0,gain]))


subplot(1,2,2)  

percentvar=[0.05,0.1,0.2,0.4,0.8];
plot(getMean(imageStack),'.k-')
hold on
drawnow
J=jet(length(percentvar));
for i=1:length(percentvar)
  kal=Kalman_Stack_Filter(imageStack,percentvar(i),0.8);
  plot(getMean(kal),'.k-','color',J(i,:))
  drawnow
end
legend(num2str([0,percentvar]))


  
function mu=getMean(data)
  
  mu=squeeze(mean(mean(data)));
  
