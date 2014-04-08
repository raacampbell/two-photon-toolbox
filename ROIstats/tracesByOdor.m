function varargout=tracesByOdor(data,ROI)
% Plot one trace per stimulus presentation for a large, single, ROI
%
% function H=tracesByOdor(data,ROI)
%
% Purpose
% The idea is that one has selected on large ROI and we want to
% overlay all traces from the same odor as the same colour. 
%
% Inputs
% data - twoPhoton data object
% ROI - integer defining the ROI to plot. defaults to 1. 
%
% Outputs
% H - structure of handles and data relating to the plot
%
%
% Rob Campbell - May 2013, CSHL




%----------------------------------------------------------------------
%  - ROI Selection -
if nargin<2
    ROI=1;
end

if isstr(ROI)
    for ii=1:length(data(1).ROI)
        if strmatch(data(1).ROI(ii).notes,ROI)
            ROI=ii;
            break
        end
    end

    if isstr(ROI)
        fprintf('Can''t find ROI %s. Plotting whole ROI\n',ROI)
        ROI=1;
    end
end

if ROI>1
    notes=data(1).ROI(ROI).notes;
elseif ROI==1
    notes='whole brain';
end




%----------------------------------------------------------------------
O=getOdourNames(data); %Get stimulus details

%Set up a colour scale. Different line colour for each stimulus
if length(O.uOdours)>2
    C=lines(length(O.uOdours));
else
    %Red and black if there are only two stimuli 
    C=[1,0,0;...
       0,0,0];
end


cla
hold on

%The response and baseline frames
fp=data(1).info.framePeriod;     %The frame period in seconds
rf=responsePeriodFrames(data(1)); %The frames that constitute the response period
bl=data(1).preFrames; 

%H is the optional output handle that will store the handles of the
%plot objects as well as various plot-related data that we want to
%deliver to external functions.
H.fname=data(1).info.Filename; 



for ii=1:length(O.uOdours)    
    ind=O.oInd{ii};
    
    for jj=1:length(ind)
        y=data(ind(jj)).ROI(ROI).stats.dff;
        
        %let's zero by the period right before the stimulus
        y=y-mean( y(rf-diff(rf)-1) );
        
        x=0:length(y)-1;
        x=x*fp;


        H.line(ii,jj)=plot(x,y,'-',...
                           'color',C(ii,:),...
                           'LineWidth',2);

        
        %Calculate the mean evoked dF/F using the pre-frames and
        %response period. 
        mu=mean(y(rf(1):rf(2)));
        mu=mu-mean(y(bl));


        
        thisX=max(x)*1.05 + rand*max(x)*0.02;  %The point position plus a little jitter
        H.point(ii,jj)=plot(thisX,mu,'o',...
                            'Color',[1,1,1]*0.5,...
                            'MarkerFaceColor',C(ii,:));
        H.mu(ii,jj)=mu;        

        H.odor{ii}=O.uOdours{ii};
    end

end

set(H.point,'Clipping','Off')




H.odourNames=data(1).stim.odourNames;
H.dir=data(1).info.rawDataDir;

Y=ylim;
rt=rf*fp; %The response times
X=[0,max(x)];
xlim(X)



%Overlay the response period and baseline period that are used to
%calculate the mean evoked data
ptchResp=patch([rt(1),rt(2),rt(2),rt(1)],...
               [Y(1),Y(1),Y(2),Y(2)],1);
set(ptchResp,'FaceColor',[1,0.8,0.8],'EdgeColor','none')

bl=bl*fp;
ptchBase=patch([bl(1),bl(end),bl(end),bl(1)],...
               [Y(1),Y(1),Y(2),Y(2)],1);
set(ptchBase,'FaceColor',[0.8,1,0.8],'EdgeColor','none')


hold off

c=get(gca,'Children');
set(gca,'Children',flipud(c));


%Now add coloured text labels for the odor names
for ii=1:length(O.uOdours)
    H.odor_text(ii)=text(1, Y(2)-diff(Y)*0.04*ii, O.uOdours{ii},...
               'Color',C(ii,:), 'FontWeight','Bold');
end



%Sort the plot order of the lines by peak height to maximise ease
%of viewing
[~,ind]=sort(H.mu(:),'ascend');
theseLines=H.line(:);


C=get(gca,'Children');
L=[theseLines(ind);H.point(:);ptchBase;ptchResp;H.odor_text(:)];

if length(L) == length(C)
    set(gca,'children',L)
end






%Add titles and related stuff
H.title=title(notes);
H.ylabel=ylabel('dF/F');
H.xlabel=xlabel('time [s]');
box on



drawnow





%----------------------------------------------------------------------
if nargout>0
    varargout{1}=H;
end
