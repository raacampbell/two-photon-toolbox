function fix_TZ_cycle_issue(DIR)
%Fixes the case where the first cycle in each t-series is repeated
%and the last is blank. The user will need to remove the last
%sequence entry if desired (although this shouldn't be necessary
%if the data-import routine is properly written) and manually
%replace the XML file. This program produces a new file with the
%string ".CORRECTED" appended to the file name. 




if nargin==0
    DIR=pwd;
end


CWD=pwd;
cd(DIR)


%First we get the names of the first entry for each cycle. These
%are present in the tif names. Then we convert them so they are in
%the same format as the information in the XML file.
D=dir('*.tif');
for ii=1:length(D)
    tok=regexp(D(ii).name,'_(Cycle\d+)_','tokens');
    Cycle{ii}=tok{1}{1};
end
C=unique(Cycle);
for ii=1:length(C)
    C{ii}=lower(regexprep(C{ii},'e0*(\d+)','e="$1"'));
end


d=dir('*.xml');

original=fopen(d.name,'r');
if original<0
    error('can''t find xml file')
end

modifiedFname=[d.name,'.CORRECTED'];
modified=fopen(modifiedFname,'w+');




tline=fgetl(original);
if ~ischar(tline)
    error('XML file appears to be empty')
end

L=cellfun(@length,C);
[~,ind]=sort(L);
C=C(ind);

fprintf('Fixing')
while ischar(tline)

    %Subtract one from the cycle number if this the first instance
    %of a repeat
    tok=regexp(tline,'(cycle="\d+")','Tokens');
    if ~isempty(tok) & ~isempty(C)
        tok=tok{1}{1};
        if strcmp(tok,C{1})
            fprintf('\n%s',tok)        
            tline=incrementCycle(tline,-1);
            C(1)=[];
        end        
        fprintf('.')
    end
    
    %Now if we find a cycle line we add 1 to it. 
    r=regexp(tline,'cycle="\d+"');    
    if ~isempty(r)
        tline=incrementCycle(tline,1);
    end
        
    fprintf(modified,'%s\n',tline);
    tline=fgetl(original);
end

fclose(original);
fclose(modified);
fprintf('\n')

cd(CWD)



function tline=incrementCycle(tline,delta)

num=regexp(tline,'cycle="(\d+)"','Tokens');
num=str2double(num{1}{1})+delta;

num=num2str(num);


tline=regexprep(tline,'cycle="\d+"',['cycle="',num,'"']);


