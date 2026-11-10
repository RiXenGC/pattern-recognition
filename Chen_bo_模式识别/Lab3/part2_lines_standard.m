clear;
close all;
A=imread('pentagon.bmp');

[h,w,p]=size(A);
if p==3, A=rgb2gray(A); end

E=edge(A);

KMAX=1000;
BMAX=1000;

kmax=5;
bmax=1000;

[h,w]=size(A);

for mode=1:2
    H=zeros(KMAX,BMAX);
    tic;
    if mode==2
        dk=2*kmax/(KMAX-1);
        sb=(BMAX-1)/(2*bmax);
        kt=(0:KMAX-1)*dk-kmax;
    end
    for x=1:w
        for y=1:h
            if E(y,x)==1
                for KI=1:KMAX
                    if mode==1
                        k=(KI-1)*(2*kmax)/(KMAX-1)-kmax;
                        b=-x*k+y;
                        BI=round((b+bmax)*(BMAX-1)/(2*bmax)+1);
                    else
                        b=-x*kt(KI)+y;
                        BI=round((b+bmax)*sb+1);
                    end
                    if BI>=1 && BI<=BMAX
                        H(KI,BI)=H(KI,BI)+1;
                    end
                end
            end
        end
    end
    elapsed(mode)=toc;
end
fprintf('Original: %.6f s; optimized: %.6f s; speedup: %.3fx\n', ...
    elapsed(1),elapsed(2),elapsed(1)/elapsed(2));

figure,imshow(-H,[]),title('Hough space (k,b)');

for Pass=1:4
    [Hbest,index]=max(H(:));
    [KIbest,BIbest]=ind2sub(size(H),index);
    kbest=(KIbest-1)*(2*kmax)/(KMAX-1)-kmax;
    bbest=(BIbest-1)*(2*bmax)/(BMAX-1)-bmax;
    for x=1:w
        y=round(kbest*x+bbest);
        if y>=1 && y<=h
            A(y,x)=0;
        end
    end
    
    d=5;
    H(max(1,KIbest-d):min(KMAX,KIbest+d), ...
      max(1,BIbest-d):min(BMAX,BIbest+d))=0;
end
figure,imshow(A),title('Four detected lines');
