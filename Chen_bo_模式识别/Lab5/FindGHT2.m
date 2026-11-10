function H=FindGHT2(A,B)
% Appendix 2: GHT with sorted frame gradient directions.
[h,w]=size(A);
H=zeros(h,w);
Ca=edge(A,'Sobel');
Cb=edge(B,'Sobel');
[~,gammaA]=imgradient(A,'Sobel');
[~,gammaB]=imgradient(B,'Sobel');
[y,x]=find(Ca==1);
[y1,x1]=find(Cb==1);
n=length(x);
n1=length(x1);
ga=zeros(size(x));
for i=1:n, ga(i)=mod(gammaA(y(i),x(i))+180,360)-180; end
gb=zeros(size(x1));
for i=1:n1, gb(i)=mod(gammaB(y1(i),x1(i))+180,360)-180; end

if n1>1, QSort(1,n1); end

% Q(k): first point in the k-th one-degree interval.
N=360;
Q=zeros(N+1,1);
j=1;
for k=1:N+1
    q=(k-1)-180;
    while j<=n1 && gb(j)<q
        j=j+1;
    end
    Q(k)=j;
end

for i=1:n
    f=ga(i);
    q=floor(f+180)+1;
    groups=mod((q-5:q+5)-1,N)+1;
    for k=groups
        for j=Q(k):Q(k+1)-1
            % Check only the selected groups, including angle wraparound.
            if abs(mod(gb(j)-f+180,360)-180)<=5
                dx=x(i)-x1(j)+1;
                dy=y(i)-y1(j)+1;
                if dx>=1 && dy>=1 && dx<=w && dy<=h
                    H(dy,dx)=H(dy,dx)+1;
                end
            end
        end
    end
end

    function QSort(a,b)
        L=a; R=b;
        m=gb(round((a+b)/2));
        while L<=R
            while gb(L)<m, L=L+1; end
            while gb(R)>m, R=R-1; end
            if L<=R
                g=gb(L); gb(L)=gb(R); gb(R)=g;
                t=x1(L); x1(L)=x1(R); x1(R)=t;
                t=y1(L); y1(L)=y1(R); y1(R)=t;
                L=L+1;
                R=R-1;
            end
        end
        if a<R, QSort(a,R); end
        if L<b, QSort(L,b); end
    end
end
