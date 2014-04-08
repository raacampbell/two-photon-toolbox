function [rec,res,dff]=filteredMovie(im,comp)

thresh=0.02;  

s=size(im);
im=reshape(im,prod(s(1:2)), s(3));

%[coef,score]=pca(im');

[res,rec]=pcares(im',comp);

rec=reshape(rec',[s(1),s(2:3)]);
res=reshape(res',[s(1),s(2:3)]);


dff=doDFF(rec,thresh);




function dff=doDFF(IN,thresh)

F=mean(IN(:,:,2:25),3);
F=repmat(F,[1,1,size(IN,3)]);
F(F<thresh)=1;

im(F<thresh)=1;
df=IN-F;
dff=df./F;
dff(dff==inf)==0;

