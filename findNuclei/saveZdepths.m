function varargout=saveZdepths(data)
% function zStack=saveZdepths(data)
%
% Purpose
% Save the z-stacks so that we can animate through them and be sure
% that we have clicked on cells that haven't moved. This is a
% time-saving function which automatically saves the z-stack in the
% current directory, based upon the XML files name. 
%
%
% Rob Campbell





im=data(1).imageStack;
S=size(im);
reps=S(3);

if length(S)<4
    disp('setting 4th dimension to length 1')
    S(4)=1;
end
if length(S)<5
    disp('setting 5th dimension to length 1')
    S(5)=1;
end

    

zStack=int8(ones([S(1),S(2),length(data),S(5)]));


fprintf(' %d/%d',1,length(data))
for ii=1:length(data)
    if mod(ii,10)==0
        fprintf('\n%d/%d',ii,length(data))
    end
    
    fprintf('.')

    im=squeeze(mean(data(ii).imageStack(:,:,:,1,:),3));
    im=int8(im*8^2);

    for depth=1:S(5)
       zStack(:,:,ii,depth)=im(:,:,depth);
    end
end

fprintf('\n')



fname=strrep(data(1).info.XMLfile,'.xml','_Zstacks');
disp('Saving...')
save(fname,'zStack')
if nargout==1
    varargout{1}=zStack;
end
