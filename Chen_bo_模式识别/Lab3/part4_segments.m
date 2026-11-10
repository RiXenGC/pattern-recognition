clear;
close all;
A=imread('pentagon.bmp');

[h,w,p]=size(A);
if p==3, A=rgb2gray(A); end
E=edge(A);

[h,w]=size(A);
RMAX=round(sqrt(w^2+h^2))+1;
FMAX=360;
ct=cosd(1:FMAX);
st=sind(1:FMAX);

for mode=1:2
    H=zeros(RMAX,FMAX);
    Xmin=H+w;
    Ymin=H+h;
    Xmax=H;
    Ymax=H;
    tic;
    if mode==2
        Sx=[-1 0 1;-2 0 2;-1 0 1];
        Sy=Sx';
        Ad=im2double(A);
        Dx=imfilter(Ad,Sx,'replicate');
        Dy=imfilter(Ad,Sy,'replicate');
        gamma=atan2d(Dy,Dx);
    end
    for x=1:w
        for y=1:h
            if E(y,x)==1
                if mode==1
                    angles=1:FMAX;
                else
                    g=gamma(y,x);
                    % Both normal directions, each within 10 degrees.
                    angles=mod([ceil(g-10):floor(g+10), ...
                        ceil(g+170):floor(g+190)]-1,FMAX)+1;
                end
                for f=angles
                    ro=x*ct(f)+y*st(f);
                    R=round(ro)+1;
                    if R>=1 && R<=RMAX
                        H(R,f)=H(R,f)+1;
                        Xmin(R,f)=min(x,Xmin(R,f));
                        Ymin(R,f)=min(y,Ymin(R,f));
                        Xmax(R,f)=max(x,Xmax(R,f));
                        Ymax(R,f)=max(y,Ymax(R,f));
                    end
                end
            end
        end
    end
    elapsed(mode)=toc;
end
fprintf('Full voting: %.6f s; gradient voting: %.6f s; speedup: %.3fx\n', ...
    elapsed(1),elapsed(2),elapsed(1)/elapsed(2));

figure,imshow(-H,[]),title('Hough space');

B=uint8(zeros(size(A))+255);

for pass=1:5
    [Hmax,index]=max(H(:));
    [Rbest,Fbest]=ind2sub(size(H),index);
    ro=Rbest-1;
    if abs(st(Fbest))>1/sqrt(2)
        for x=Xmin(Rbest,Fbest):Xmax(Rbest,Fbest)
            y=round((ro-x*ct(Fbest))/st(Fbest));
            if y>=1 && y<=h
                B(y,x)=0;
            end
        end
    else
        for y=Ymin(Rbest,Fbest):Ymax(Rbest,Fbest)
            x=round((ro-y*st(Fbest))/ct(Fbest));
            if x>=1 && x<=w
                B(y,x)=0;
            end
        end
    end
    d=5;
    fi=mod((Fbest-d:Fbest+d)-1,FMAX)+1;
    H(max(1,Rbest-d):min(RMAX,Rbest+d),fi)=0;
end

figure,imshow(B),title('Detected segments');
R=bitor(A,imcomplement(B));
G=bitand(A,B);
B=bitand(A,B);
C=cat(3,R,G,B);
figure,imshow(C),title('Detected segments in red');
