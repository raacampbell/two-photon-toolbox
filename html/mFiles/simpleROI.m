%% Simple ROI Time-Course Analyses
%
% This example shows how to manually extract data from the
% |twoPhoton| object in order to make simple plots of the evoked
% response in the whole-brain ROI. 
%
% 
%%
% First we load the data
cd ~/work/Matlab_Scripts/ImagingAnalysis/examples/
load KCexample.mat


%% Plotting time-courses 
% We can easily plot a single time course by doing
clf
tc=responseTimeCourse(data(1));

%%
% The above was a smoothed plot. We can show the smoothed response
% and the raw data by using more basic functions:
dff=roiTimeCourse(data(1).dff,data(1).ROI(1).roi);
clf
hold on
plot(tc.x,smooth(dff,3),'-b') %smooth is part of the curve-fitting toolbox
plot(tc.x,dff,'ok','markerfacecolor',[1,1,1]*0.5)
hold off
xlabel('time [s]')
ylabel('dF/F')

%% Overlaying Traces
% However, we probably want to compare several time-courses on one
% plot:
clf, hold on
colours=lines(length(data)+1);
for ii=1:length(data)
    tCourse=responseTimeCourse(data(ii),[],0);
    plot(tCourse.x,tCourse.dff,'-','color',colours(ii,:),...
         'linewidth',2)
end
hold off
xlabel('time [s]')
ylabel('dF/F')
 
%%
% Now we can mark out the stimulus period. In this case each trial
% had the same onset and offset times. 
rp=responsePeriodFrames(data(1),0); %zero=no extra time
t=tCourse.x(rp);

hold on
p(1)=plot([t(1),t(1)],ylim,'--r');
p(2)=plot([t(2),t(2)],ylim,'--r');
hold off

%% Make A Summary Line Plot
% Let's make a line-plot of the mean evoked dF/F. First we need to
% choose all the frames during which there appears to be a
% response. All values between the red dotted bars will be
% counted. 
rp=responsePeriodFrames(data(1));
t=tCourse.x(rp);
delete(p(2))
hold on
p(2)=plot([t(2),t(2)],ylim,'--r');
hold off

%%
% Get the mean values
for ii=1:length(data)    
    dff=roiTimeCourse(data(ii).dff,...
                      data(ii).ROI(1).roi);
    muDFF(ii)=mean(dff(rp(1):rp(2)));
end
clf
plot(muDFF,'o-b','markerfacecolor',[0.5,0.5,1])
xlabel('#trial')
ylabel('mean dF/F')
xlim([0,length(data)+1])
set(gca,'xtick',[1:length(data)])

%% Further Reading
% For more elaborate analyses and functions which will automate
% some of these tasks see  <generateRecordingReport.html
% |generateRecordingReport|> and its sub-functions
% <responseMagByPresentation.html |responseMagByPresentation|> and
% <responseTimeCourseByOdour.html |responseTimeCourseByOdour|>.


