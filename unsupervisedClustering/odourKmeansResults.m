function odourKmeansResults(in)
% function odourKmeansResults(in)
%
% Purpose
% Plot results of odourKmeans
%
% Inputs
% in - the output of odourKmeans
%    
% Rob Campbell - January 2010
 

 clf


 hold on
 % plot(in.kMu,'-','color',ones(1,3)*0.75)
 H(1)=shadedErrorBar([],in.kMu',{@nanmean,@SEM_calc},...
                  {'or-','markerfacecolor',[1,0.3,0.3]},1);
 H(2)=shadedErrorBar([],in.kMuNoise',{@nanmean,@SEM_calc},...
                  {'ob-','markerfacecolor',[0.3,0.3,1]},1);
 H(2)=shadedErrorBar([],in.kMu'-in.kMuNoise',{@nanmean,@SEM_calc},...
                  {'og-','markerfacecolor',[0.3,1,0.3]},1);

 
hold off
return

 plot(mean(in.kMu,2),'-or','markerfacecolor',[1,0.5,0.5],'linewidth',2)

 
