function [ H ] = FindGHT2( A,B )
%FindGHT вычисляет GHT кадра и карты с использованием направления градиента
%А-карта
%В-кадр
%версия с N=360 градусов и сортировкой по кадру
[h,w]=size(A);
H=zeros(h,w);
%находим границы
Ca=edge(A,'Sobel');
Cb=edge(B,'Sobel');
%находим направление градиента
[~,gammaA]=imgradient(A,'Sobel');
[~,gammaB]=imgradient(B,'Sobel');
%строим список координат
[y,x]=find(Ca==1);
[y1,x1]=find(Cb==1);
n=length(x);
n1=length(x1);
%строим список направлений градиента
ga=zeros(size(x));
for i=1:n, ga(i)=gammaA(y(i),x(i));end
gb=zeros(size(x1));
for i=1:n1, gb(i)=gammaB(y1(i),x1(i));end
 %сортируем по возрастанию фазы градиента
 function QSort(a,b)
 L=a;R=b;
 m=gb(round((a+b)/2));
 while(L<=R)
 while (gb(L)<m), L=L+1;end
 while (gb(R)>m), R=R-1;end
 if (L<=R)
 g=gb(L);gb(L)=gb(R);gb(R)=g;
 t=x1(L);x1(L)=x1(R);x1(R)=t;
 t=y1(L);y1(L)=y1(R);y1(R)=t;
 L=L+1;
 R=R-1;
 end
 end
 if (a<R),QSort(a,R);end
 if (L<b),QSort(L,b);end
 end
if (n1>1),QSort(1,n1);end
%формируем закладки через 1 градус
N=360;
Q=zeros(N+1,1);
Q(1)=1;
for i=2:N+1
 Q(i)=Q(i-1);
 q=(i-1)-180;
 for j=Q(i-1)+1:n1
 if gb(j)>q
 Q(i)=j;
 break;
 end
 end
end
Q(N+1)=n1+1;
%Преобр. Хафа
for i=1:n %для каждой точки границ карты
 f=ga(i);
 q=round(f+181);%пересчитаем фазу градиента в № закладки
 q1=q-5; if q1<1, q1=1; end %добавим плюс-минус 5 градусов
 q2=q+5; if q2>360, q2=360; end
 for j=Q(q1):Q(q2)-1 %теперь считаем от одной закладки до другой
 dx=x(i)-x1(j); %строим гипотезу 
 dy=y(i)-y1(j);
 if (dx>=1)&&(dy>=1)&&(dx<=w)&&(dy<=h)
 H(dy,dx)=H(dy,dx)+1; %размечаем ее в ПП
 end
 end
end
end