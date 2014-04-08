function correctTranslation3D_batch
% function correctTranslation3D_batch
%
% run from within data dir. loads and corrects all the rawData
% matrices. 




d=dir('raw*.mat');

for ii=1:length(d)


    fprintf('%d/%d\n',ii,length(d))
    load(d(ii).name)

    name=d(ii).name(1:end-4);
    eval(sprintf('%s=correctTranslation3D(%s,1);',name,name))
    eval(sprintf('save %s %s',d(ii).name,name))
    clear raw*    
end
