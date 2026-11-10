clear; close all;
A=imread('ConcordOrthoPhoto.png');
B=imread('WestConcordOrthoPhoto.png');
if ndims(A)==3, A=rgb2gray(A); end
if ndims(B)==3, B=rgb2gray(B); end
[h,w]=size(A); [h1,w1]=size(B);
assert(h1<=h && w1<=w,'Frame must fit inside the map.');
fprintf('Map: %d x %d; frame: %d x %d\n',h,w,h1,w1);
figure; imshow(A); title('Map');
figure; imshow(B); title('Frame');
A=double(A); B=double(B);
% Measure 10 positions using the direct formula; estimate the full time.
% Set fullRun=true only if a complete direct calculation is required.
fullRun=false;
nx=w-w1+1; ny=h-h1+1;
if fullRun, ntest=nx*ny; else, ntest=min(10,nx*ny); end
Rsample=zeros(ntest,1);
tic;
for k=1:ntest
    [y,x]=ind2sub([ny,nx],k);
    s=0;
    for dx=1:w1
        for dy=1:h1
            s=s+A(y+dy-1,x+dx-1)*B(dy,dx);
        end
    end
    Rsample(k)=s;
    fprintf('Position %d / %d; x=%d, y=%d\n',k,ntest,x,y);
end
Tsample=toc;
Testimated=Tsample/ntest*(nx*ny);
tic; Rfft=FindCorr(A,B); Tfft=toc;
% Compare using columns, independent of vector orientation.
reference=Rfft(1:ntest); reference=reference(:);
maxDifference=max(abs(Rsample-reference));
fprintf('Measured: %.6f s for %d positions\n',Tsample,ntest);
fprintf('Estimated full direct time: %.2f s (%.2f h)\n',Testimated,Testimated/3600);
fprintf('FFT: %.6f s; estimated speedup: %.2f\n',Tfft,Testimated/Tfft);
fprintf('Direct/FFT sample maximum difference: %.6g\n',maxDifference);
save('part1_times.mat','Tsample','ntest','Testimated','Tfft','maxDifference','fullRun');
if fullRun
    R=reshape(Rsample,ny,nx); figure; imshow(-R,[]); title('Direct correlation');
end
