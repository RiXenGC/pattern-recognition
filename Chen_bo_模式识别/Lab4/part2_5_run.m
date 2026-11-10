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
% 1 FindCorr; 2 PhaseCorr; 3 GradCorr; 4 GradCorrXY; 5 ContCorr.
Method=1;
% 0 original; 1 brightness; 2 noise; 3 rotation; 4 scaling.
Exp=0;
methods={@FindCorr,@PhaseCorr,@GradCorr,@GradCorrXY,@ContCorr};
names={'FindCorr','PhaseCorr','GradCorr','GradCorrXY','ContCorr'};
if Exp==1
    values=[-100 -50 -20 20 50 100];
elseif Exp==2
    values=0.25;
elseif Exp==3
    values=1:5;
elseif Exp==4
    values=0.95:-0.01:0.90;
else
    values=0;
end
results=zeros(numel(values),5);
for k=1:numel(values)
    v=values(k); B1=B;
    if Exp==1, B1=uint8(double(B)+v);
    elseif Exp==2, B1=imnoise(B,'salt & pepper',v);
    elseif Exp==3, B1=imrotate(B,v);
    elseif Exp==4, B1=imresize(B,v);
    end
    % Uncomment ONLY for the Part 2 brightness correction experiment:
    % B1=B-20;
    tic; R=methods{Method}(A,B1); elapsed=toc;
    [~,index]=max(R(:)); [y,x]=ind2sub(size(R),index);
    [bh,bw]=size(B1);
    fits=(x+bw-1<=w && y+bh-1<=h);
    results(k,:)=[v,x,y,elapsed,fits];
    label=sprintf('%s; Exp=%d; value=%g',names{Method},Exp,v);
    fprintf('%s: x=%d, y=%d, time=%.6f s, fits=%d\n',label,x,y,elapsed,fits);
    figure('Name',label); imshow(-R,[]); title('Correlation function');
    figure('Name',label); imshow(A); hold on;
    rectangle('Position',[x,y,bw,bh],'EdgeColor','r','LineWidth',1);
    title(sprintf('Detected position: x=%d, y=%d',x,y));
    if fits
        C=A; C(y:y+bh-1,x:x+bw-1)=uint8(double(B1)*1.2+50);
        figure('Name',label); imshow(C); title('Frame overlaid on map');
    else
        warning('Peak outside full-frame placement area. Do not use it as ground truth.');
    end
end
Result= array2table(results,'VariableNames',{'Value','X','Y','Time_s','Fits'});
disp(Result);
writetable(Result,sprintf('part2_5_%s_exp%d.csv',names{Method},Exp));
