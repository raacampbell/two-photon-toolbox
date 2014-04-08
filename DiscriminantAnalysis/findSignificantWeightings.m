function nSig=findSignificantWeightings(stats)
% function nSig=findSignificantWeightings(stats)
%
% Purpose
% Uses the scambled bootstrapped (noise) LDAs to estimate which
% neurons have significant weightings for the LDA on the full data
% set. Note that classifyKCs should be run with params.noiseType
% being 'shufflepresentations' for this function to be meaningful.
%
% Inputs
% stats - classifyKCs output
%
% 
% Rob Campbell, September 2009


%This function isn't really correct :/


%Build matrix of LD axes 
r=length(stats.noise);                      %number of bootstrapped replicates
n=length(stats.noise(1).LDspace(1).ldAxis); %number of neurons
s=length(stats.noise(1).LDspace);           %number of stimuli

disp(sprintf('Estimating noise based on %d replicates',r))

noise=ones([s,n,r]);
for i=1:r
  noise(:,:,i)=[stats.noise(i).LDspace.ldAxis]';
end

%%Uncomment to see what is being discriminanted by each row
%for i=1:length(stats.noise(1).LDspace)
%    disp([stats.noise(1).LDspace(i).id1,' / ',...
%          stats.noise(1).LDspace(i).id2])
%end


%The observed loading magnitude for each neuron
observed=[stats.xValidMu.LDspace.ldAxis]';

clf

subplot(1,3,1)
obsAbs=abs(mean(observed));
%imagesc(obsAbs), colorbar
plot(obsAbs)
title('Observed weighting')
xlabel('neuron')


subplot(1,3,2)

%We still need the error on the observed values. Can work this out
%using the x-validated numbers which I don't have right now....
p=5.5;
noise=squeeze(abs(mean(noise,1)));
noiseSD=std(noise,[],2);
noiseMU=squeeze(mean(noise,2));

testMatrix=(p*noiseSD)+noiseMU;
plot(testMatrix)
title('Threshold matrix')
ylabel('discriminant')
xlabel('neuron')


subplot(1,3,3)
tmp=obsAbs(:)-testMatrix(:);
sig=tmp>0;
plot(sig)
title(sum(sig))

