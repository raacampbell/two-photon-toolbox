function varargout=withinBetweenVar(data,pcdims,doPlot)
% function out=withinBetweenVar(data,pcdims,doPlot)
%
% Purpose
% Calculate the within and between groups variance for each odour
% in the full space.
%
% Inputs
% data - twoPhoton data structure.
% pcdims - if exists and is non-zero then choose this many pcs
% doPlot - optional, zero by default. Also, plot is made if handles
%          are requested. 
%
% Outputs
% out - matrix first col is within and second is between 
% h - plot handles. 
%
% Rob Campbell - January 2010

    
if nargin<3, doPlot=0; end

    
kc=ROI_responseMatrix(data,[],[],[],[],0); 
O=getOdourNames(data);

if nargin<2 | pcdims>0
    [~,kc]=princomp(kc);
    kc=kc(:,1:pcdims);
end

useVar=1;

n=1;
for ii=1:length(O.oInd)
    
    for jj=1:length(O.oInd)

        if ii<=jj, continue, end %Do only the upper triangle

        A=kc(O.oInd{ii},:);
        B=kc(O.oInd{jj},:);

        
        %The within-groups variance is the sum of the variance of
        %the KC responses within the two groups.
        if useVar
            out(n,1)=sum(var([A,B]));
        else
            %out(n,1)=euc(A)+euc(B);
            out(n,1)=euc([A,B]);
        end
        
             
        
        %The between groups variance is the variance between the
        %individual KCs and the grand mean of the two groups. 
        if useVar
            out(n,2)=sum(var([A;B]));
        else
            out(n,2)=euc([A;B]);
        end
        
        n=n+1;
    end
end





% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if doPlot | nargout>1
    
    h(1)=plot(out(:,1),out(:,2),'o','Color',[1,1,1]*0.5,...
              'MarkerFaceColor','k');

    x=xlim;
    y=ylim;
    lim=[x;y];
    lim=[min(lim(:,1)),max(lim(:,2))];
    xlim(lim)
    ylim(lim)
    
    hold on
    h(2)=plot(lim,lim,'--','Color',[1,1,1]*0.5);
    hold off
    
    xlabel('Within')
    ylabel('Between')
    axis equal
end

    
if nargout>0
    varargout{1}=out;
end
if nargout>1
    varargout{2}=h;
end



% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function dp=euc(mat)
mu=mean(mat);
mu=repmat(mu,size(mat,1),1);
dp=(mat-mu).^2;
dp=sqrt(sum(dp(:)));

