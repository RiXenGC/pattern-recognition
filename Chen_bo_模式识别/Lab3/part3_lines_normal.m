clear;
close all;
A=imread('pentagon.bmp');

[h,w,p]=size(A);
if p==3, A=rgb2gray(A); end

E=edge(A);

[h,w]=size(A);
xc=(w+1)/2;
yc=(h+1)/2;
RMAX=ceil(sqrt(((w-1)/2)^2+((h-1)/2)^2))+1;
FMAX=360;

for mode=1:2
    H=zeros(RMAX,FMAX);
    tic;
    if mode==2
        ct=cosd(1:FMAX);
        st=sind(1:FMAX);
    end
    for x=1:w
        for y=1:h
            if E(y,x)==1
                for f=1:FMAX
                    if mode==1
                        ro=(x-xc)*cosd(f)+(y-yc)*sind(f);
                    else
                        ro=(x-xc)*ct(f)+(y-yc)*st(f);
                    end
                    R=round(ro)+1;
                    if ro>=0 && R>=1 && R<=RMAX
                        H(R,f)=H(R,f)+1;
                    end
                end
            end
        end
    end
    elapsed(mode)=toc;
end
fprintf('Original: %.6f s; optimized: %.6f s; speedup: %.3fx\n', ...
    elapsed(1),elapsed(2),elapsed(1)/elapsed(2));

figure,imshow(-H,[]),title('Hough space: origin at image center');

for pass=1:5
    [Hmax,index]=max(H(:));
    [Rbest,Fbest]=ind2sub(size(H),index);
    ro=Rbest-1;
    if abs(st(Fbest))>1/sqrt(2)
        for x=1:w
            y=round(yc+(ro-(x-xc)*ct(Fbest))/st(Fbest));
            if y>=1 && y<=h
                A(y,x)=0;
            end
        end
    else
        for y=1:h
            x=round(xc+(ro-(y-yc)*st(Fbest))/ct(Fbest));
            if x>=1 && x<=w
                A(y,x)=0;
            end
        end
    end

    d=5;
    fi=mod((Fbest-d:Fbest+d)-1,FMAX)+1;
    H(max(1,Rbest-d):min(RMAX,Rbest+d),fi)=0;
end

figure,imshow(A),title('Five detected lines');
