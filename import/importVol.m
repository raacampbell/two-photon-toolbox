function importVol(directory)


cd(directory)

data=prairieXML_2_Matlab;
data=formatZTseriesHack(data);

p=dir('params*.mat');
  if ~isempty(p) 
      if length(p)==1
          
          load(p.name)
          data=addStimParamsVol(data,params);
      end
  end
cd('..')



saveZdepths(data)


save(directory,'data')



