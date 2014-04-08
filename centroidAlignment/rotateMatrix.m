function B=rotateMatrix(mat,x,y,z)
  

x=deg2rad(x);
y=deg2rad(y);
z=deg2rad(z);

Rx=[      0,       0,      0;...
          0,       x,     -x;...
          0,       x,      x];

Ry=[      y,       0,      y;...
          0,       0,      0;...
         -y,       0,      y];

Rz=[      z,      -z,        0;...
          z,       z,        0;...
          0,       0,        0];


R=applyTrig(Rx+Ry+Rz);


% Rotation equation
%     Bi = sR*mat+T
%     s           The scale factor
%     R           The 3x3 rotation matrix
%     T           The 3x1 translation vector
s=1;
T=0;

B=s*R*mat+T;

return
clf
subplot(1,2,1), plotSets(mat,B)
%B=s*reverseRotation(R)*B+T;
subplot(1,2,2), plotSets(mat,B)




function y = deg2rad(x)
y = x * pi/180;


function R=reverseRotation(R)
for ii=1:size(R,1)
    for jj=1:size(R,2)
        
        if ii==jj
            R(ii,jj)=cos(-acos(R(ii,jj)));
        else
            R(ii,jj)=sin(-asin(R(ii,jj)));
        end
        
    end
end

function R=applyTrig(R)
for ii=1:size(R,1)
    for jj=1:size(R,2)
        
        if ii==jj
            R(ii,jj)=cos(R(ii,jj));
        else
            R(ii,jj)=sin(R(ii,jj));
        end
        
    end
end


function plotSets(A,B)
hold on
plot3(A(1,:),A(2,:),A(3,:),'ok'), view(3)
plot3(B(1,:),B(2,:),B(3,:),'.r'), view(3)
hold off
axis equal 
box on
