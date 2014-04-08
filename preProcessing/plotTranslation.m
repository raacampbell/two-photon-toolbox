function plotTranslation(out)
%  function plotTranslation(out)
%
% Plots the output of a translation correction
%
%
% Rob Campbell - August 2012

clf


subplot(2,2,1)
imagesc(mean(out.before,3))
axis equal off
title('original mean')

subplot(2,2,2)
imagesc(mean(out.after,3))
axis equal off
title('corrected mean')


if isfield(out.coef,'OffsetPixel')
    subplot(2,2,3)
    offset=reshape([out.coef.OffsetPixel],2,length(out.coef))';
    plot(offset)
    xlabel('Frame')
    ylabel('delta (pixels)')
    title('Estimated translation magnitude')
    legend({'y shift','x shift'})
end
  

subplot(2,2,4)
plot(imageStackCorr(out.before, out.target),'-k')
hold on
plot(imageStackCorr(out.after, out.target),'-r')
hold off
xlabel('Frame')
ylabel('R')
title('correlation wrt to target')
legend({'original','corrected'})
colormap gray

drawnow
