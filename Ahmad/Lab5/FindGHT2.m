function [ H ] = FindGHT2( A,B )

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
    
    for i=1:n, ga(i)=gammaA(y(i),x(i));end
        gb=zeros(size(x1));
        for i=1:n1, gb(i)=gammaB(y1(i),x1(i));end
           
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
     
            for i=1:n
                f=ga(i);
                q=round(f+181);
                q1=q-5; if q1<1, q1=1; end 
                q2=q+5; if q2>360, q2=360; end
                for j=Q(q1):Q(q2)-1 
                    dx=x(i)-x1(j);
                    dy=y(i)-y1(j);
                    if (dx>=1)&&(dy>=1)&&(dx<=w)&&(dy<=h)
                    H(dy,dx)=H(dy,dx)+1; 
                    end
                end
            end
end