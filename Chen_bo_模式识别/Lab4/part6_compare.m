clear; close all;
A=imread('ConcordOrthoPhoto.png');
B=imread('WestConcordOrthoPhoto.png');
if ndims(A)==3, A=rgb2gray(A); end
if ndims(B)==3, B=rgb2gray(B); end
[h,w]=size(A); [h1,w1]=size(B);
assert(h1<=h && w1<=w,'Frame must fit inside the map.');
fprintf('Map: %d x %d; frame: %d x %d\n',h,w,h1,w1);
% Enter ONE visually verified position from the original-image experiment.
% Do not accept the PhaseCorr peak automatically when matching has failed.
xy=input('Verified original frame top-left [x y]: ');
assert(numel(xy)==2 && all(isfinite(xy)) && all(xy>=1) ...
    && xy(1)+w1-1<=w && xy(2)+h1-1<=h,'Invalid reference position.');
xtrue=xy(1); ytrue=xy(2);
methods={@PhaseCorr,@GradCorr,@GradCorrXY,@ContCorr};
names={'PhaseCorr','GradCorr','GradCorrXY','ContCorr'};
N=0:5:100; Ang=0:1:20; M=100:-1:80;
levels={N,Ang,M}; labels={'Noise (%)','Rotation (degrees)','Scale (%)'};
threshold=20;
E=zeros(21,4,3); Times=zeros(21,4,3); critical=nan(4,3);
baseError=zeros(4,1); baseTime=zeros(4,1);
for m=1:4
    tic; R=methods{m}(A,B); baseTime(m)=toc;
    [~,idx]=max(R(:)); [y,x]=ind2sub(size(R),idx);
    baseError(m)=hypot(x-xtrue,y-ytrue);
end
rng(1);
for experiment=1:3
    values=levels{experiment};
    for pass=1:numel(values)
        v=values(pass);
        if experiment==1
            if v==0, B1=B; else, B1=imnoise(B,'salt & pepper',v/100); end
        elseif experiment==2
            B1=imrotate(B,v);
        else
            B1=imresize(B,v/100);
        end
        for m=1:4
            tic; R=methods{m}(A,B1); Times(pass,m,experiment)=toc;
            [~,idx]=max(R(:)); [y,x]=ind2sub(size(R),idx);
            % Assignment convention: top-left coordinate error.
            E(pass,m,experiment)=hypot(x-xtrue,y-ytrue);
        end
        fprintf('Experiment %d: %d / %d\n',experiment,pass,numel(values));
    end
    for m=1:4
        first=find(E(:,m,experiment)>threshold,1);
        if ~isempty(first), critical(m,experiment)=values(first); end
    end
    save('part6_results.mat','E','Times','critical','levels','names', ...
        'xtrue','ytrue','threshold','baseError','baseTime');
end
Summary=table(names',baseTime,baseError,critical(:,1),critical(:,2),critical(:,3), ...
    'VariableNames',{'Method','Time_s','OriginalError_px','NoiseCritical_pct', ...
    'RotationCritical_deg','ScaleCritical_pct'});
disp(Summary); writetable(Summary,'part6_summary.csv');
% NaN means the threshold was not exceeded in the tested range.
for experiment=1:3
    figure; plot(levels{experiment},E(:,:,experiment),'LineWidth',1); hold on;
    plot(levels{experiment},threshold*ones(size(levels{experiment})),'k--');
    xlabel(labels{experiment}); ylabel('Position error (pixels)');
    legend([names,{'Threshold'}],'Location','best');
    if experiment==3, set(gca,'XDir','reverse'); end
    exportgraphics(gcf,sprintf('part6_experiment%d.png',experiment));
    Curve=array2table([levels{experiment}',E(:,:,experiment)], ...
        'VariableNames',[{'Level'},names]);
    writetable(Curve,sprintf('part6_experiment%d.csv',experiment));
end
