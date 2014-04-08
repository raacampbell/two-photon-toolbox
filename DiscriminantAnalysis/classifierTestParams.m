function stats=classifierTestParams(data)
% function classifierTestParams(data)  
%
% Run the classifier using a load of different parameters so as to
% test how well it works under different conditions. 
%
% data: if twoPhoton object then function calculates and prints
% results. if data is the output of classiferTestParams then this
% is plotted and nothing is calculated.
  
  
if ~isstruct(data)
  
  matrixType={'mean','binary','zscore','shufflecells'};
  ndims=[1:30];
  
  params.noiseReps=1;
  params.noiseType='shufflepresentations1';
  
  
  for i=1:length(matrixType)
    params.matrixType=matrixType{i};
    fprintf('doing %s (%d/%d)\n',matrixType{i},i,length(matrixType))
    for j=1:length(ndims)    
      fprintf('** %d/%d: doing %s [%d/%d] \n',...
              i,length(matrixType),matrixType{i},...
              j,length(ndims))
      params.ndims=ndims(j);
      tmp=classifyKCs(data,params); %This can produce very large
                                    %structures!
      tmp.raw=[];
      tmp.noise=[];
      
      stats(i,j)=tmp;
      end
  end
else
  stats=data;
end





for i=1:size(stats,1)
  L{i}=stats(i).xValid.statsParams.matrixType;
  for j=1:size(stats,2)
    tmp=odourClassConfMat(stats(i,j).xValidMu,0);
    correct(i,j)=tmp.percentCorrect;
  end
end


%plot the results
clf

plot(correct','-o')
legend(L)

C=get(gca,'Children');
for i=1:length(C)

  set(C(i),'markerfacecolor',get(C(i),'color'))

end

