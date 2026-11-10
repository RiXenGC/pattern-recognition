% Parts 1 and 2: GHT detection and timing.
clear;
close all;
A=imread('ConcordOrthoPhoto.png');
B=imread('WestConcordOrthoPhoto.png');
figure,imshow(A),title('Map');
figure,imshow(B),title('Frame');
[h,w]=size(A);
[h1,w1]=size(B);
methods={@FindGHT,@FindGHT2};
names={'GHT','GHT with gradient directions'};
Time=zeros(2,1);
for method=1:2
    tic;
    H=methods{method}(A,B);
    Time(method)=toc;
    [Hmax,index]=max(H(:));
    [y,x]=ind2sub(size(H),index);
    fprintf('%s: x=%d, y=%d, peak=%g, time=%.6f s\n', ...
        names{method},x,y,Hmax,Time(method));
    figure,imshow(H,[]),title(names{method});
    C=A;
    hh=min(h1,h-y+1);
    ww=min(w1,w-x+1);
    C(y:y+hh-1,x:x+ww-1)=uint8(double(B(1:hh,1:ww))*1.2+50);
    figure,imshow(C),title([names{method} ': detected position']);
end
fprintf('Speedup: %.3fx\n',Time(1)/Time(2));
save('part1_2_times.mat','Time');
