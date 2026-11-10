function H=FindGHT(A,B)
% Appendix 1: GHT without gradient directions.
[h,w]=size(A);
H=zeros(h,w);
Ca=edge(A,'Sobel');
Cb=edge(B,'Sobel');
[y,x]=find(Ca==1);
[y1,x1]=find(Cb==1);
n=length(x);
n1=length(x1);
for i=1:n
    for j=1:n1
        dx=x(i)-x1(j)+1;
        dy=y(i)-y1(j)+1;
        if dx>=1 && dy>=1 && dx<=w && dy<=h
            H(dy,dx)=H(dy,dx)+1;
        end
    end
end
end
