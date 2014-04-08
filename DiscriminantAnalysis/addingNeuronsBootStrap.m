function out=addingNeuronsBootStrap(data)
% function out=addingNeuronsBootStrap(data,stats)
%
% This function will perform multiple boot-strapped runs of the
% classifier on different numbers of , randomly chosen, subsets of
% cells.
% 
% Inputs
% data - twoPhoton object
% stats - output of classifyKCs    
%
%
% Rob Campbell, Jan 2010
    


params.noiseType='shuffle';
params.nReps=1;


reps=30;

M=60;
N=nNeurons2p(data);
if N.n<M; M=N.n; end
n=[4:2:M];


pc=nan(reps,n);
ndim=nan(size(pc));

j=1;
for i=n
    
    for k=1:reps
        
        %Change dimensionality here. 
        params.ndims=ceil(i*0.3);
      
        if params.ndims>12,params.ndims=12;end
        
        r=randperm(N.n);        
        params.neuronSubset=r(1:i); %randomly choose some cells

        stats=classifyKCs(data,params);
        pc(k,j)=stats.xValid.percentCorrect;
        ndim(k,j)=params.ndims;

    end
    j=j+1;
end

out.ndim=ndim;
out.pc=pc;
out.ncells=n;
