% Part 3: noise, rotation, scale, window summation, spectral comparison.
clear;
close all;
A=imread('ConcordOrthoPhoto.png');
B=imread('WestConcordOrthoPhoto.png');
N=0:5:100;
Ang=0:1:20;
M=100:-1:80;
threshold=20;
names={'GHT2','GHT2 + 7x7','FindCorr','PhaseCorr', ...
    'GradCorr','GradCorrXY','ContCorr'};
spectral={@FindCorr,@PhaseCorr,@GradCorr,@GradCorrXY,@ContCorr};
R=PhaseCorr(A,B);
[~,index]=max(R(:));
[ytrue,xtrue]=ind2sub(size(R),index);
Time=zeros(7,1);
Error0=zeros(7,1);
for method=1:7
    tic;
    if method==1
        R=FindGHT2(A,B);
    elseif method==2
        R=FindGHT2(A,B);
        R=imfilter(R,ones(7));
    else
        R=spectral{method-2}(A,B);
    end
    Time(method)=toc;
    [~,index]=max(R(:));
    [y,x]=ind2sub(size(R),index);
    Error0(method)=hypot(x-xtrue,y-ytrue);
end
E=zeros(21,7,3);
Critical=nan(7,3);
axesValues={N,Ang,M};
titles={'Noise','Rotation','Scale'};
xlabels={'Noise (%)','Angle (degrees)','Scale (%)'};
rng(1);
for Exp=1:3
    T=axesValues{Exp};
    for pass=1:numel(T)
        if Exp==1
            B1=imnoise(B,'salt & pepper',N(pass)/100);
        elseif Exp==2
            B1=imrotate(B,Ang(pass));
        else
            B1=imresize(B,M(pass)/100);
        end
        H=FindGHT2(A,B1);
        for method=1:7
            if method==1
                R=H;
            elseif method==2
                R=imfilter(H,ones(7));
            else
                R=spectral{method-2}(A,B1);
            end
            [~,index]=max(R(:));
            [y,x]=ind2sub(size(R),index);
            E(pass,method,Exp)=hypot(x-xtrue,y-ytrue);
        end
        fprintf('%s: %d / %d\n',titles{Exp},pass,numel(T));
    end
    for method=1:7
        first=find(E(:,method,Exp)>threshold,1);
        if ~isempty(first), Critical(method,Exp)=T(first); end
    end
end
Results=table(names',Time,Error0,Critical(:,1),Critical(:,2),Critical(:,3), ...
    'VariableNames',{'Method','Time_s','BaselineError_px', ...
    'CriticalNoise_percent','CriticalAngle_deg','CriticalScale_percent'});
disp(Results);
fprintf('NaN: error did not exceed 20 pixels in the tested range.\n');
save('part3_results.mat','E','N','Ang','M','Results','threshold');
writetable(Results,'part3_results.csv');
for Exp=1:3
    T=axesValues{Exp};
    figure('Name',titles{Exp});
    plot(T,E(:,:,Exp),'-o');
    hold on;
    plot(T,threshold*ones(size(T)),'k--');
    xlabel(xlabels{Exp});
    ylabel('Position error (pixels)');
    title(titles{Exp});
    legend([names {'Threshold'}],'Location','best');
    if Exp==3, set(gca,'XDir','reverse'); end
end
