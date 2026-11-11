function [ R ] = CentProf( B)
%CentProf строит нормированный центроидальный профиль объекта
%B-бинаризованное изображение
E=bwperim(B);
[y,x]=find(B==1);
xc=mean(x);
yc=mean(y);
[y,x]=find(E==1);
dx=x-xc;
dy=y-yc;
ro=sqrt(dx.^2+dy.^2);
fi=atan2d(dy,dx);
f=floor(fi)+180+1;
n=length(x);
R=zeros(360,1);
for i=1:n
 R(f(i))=max(R(f(i)),ro(i));
end
R=R./mean(R);
end