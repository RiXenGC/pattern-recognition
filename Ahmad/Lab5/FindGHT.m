function [ H ] = FindGHT( A,B )
    [h,w]=size(A);
    [h1,w1]=size(B);
    H=zeros(h,w);
    Ca=edge(A,'Sobel');
    Cb=edge(B,'Sobel');
    [y,x]=find(Ca==1);
    [y1,x1]=find(Cb==1);
    n=length(x);
    n1=length(x1);
    for i=1:n
        for j=1:n1
            dx=x(i)-x1(j);
            dy=y(i)-y1(j);
            if (dx>=1)&&(dy>=1)&&(dx<=w)&&(dy<=h)
                H(dy,dx)=H(dy,dx)+1;
            end
        end
    end
end
