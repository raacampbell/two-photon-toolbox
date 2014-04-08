function data=params2data(params)
% 
%
% function data=params2data(params)    
%
% Convert the large olfactometer parameters file into a data file
% of the sort we could analyse with other functions. This is a bit
% of hack and the code will need to be changed as the params file
% changes. 
%
% Rob Campbell
    

for i=1:length(params.isi)


    data(i).info.XMLfile='none';
    data(i).info.date=datestr(params.timestamp(1),21);

    data(i).stim.sr=1e3;
    data(i).stim.PID=params.data{i};
    data(i).stim.odour=params.odourNames(params.odours(i)).odour;

    
end


    
    
