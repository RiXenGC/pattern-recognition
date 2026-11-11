%% 相关性直接计算
clear;
close all;
A = imread("ConcordOrthoPhoto.png");
B = imread("westconcordorthophoto.png");
subplot(1, 2, 1), imshow(A), title('地图');
subplot(1, 2, 2), imshow(B), title('照片');
[h0, w0] = size(A);
[h1, w1] = size(B);
R = zeros(h0, w0);

timerId = tic;
for x = 1:w0-w1-1
    % fprintf('%d\n', x);
    % Read the elapsed wall-clock time in seconds and save it for later use.
    elapsedSeconds = toc(timerId);
    
    % Display the same duration in seconds and minutes.
    fprintf('Elapsed time: %.3f seconds (%.2f minutes)\n', ...
        elapsedSeconds, elapsedSeconds / 60);
    for y = 1:h0-h1-1
        s = 0;
        for dx = 1:w1
            for dy = 1:h1
                s = s + A(y+dy, x+dx)*B(dy, dx);
            end
        end
        R(x, y) = s;
    end
end

Rmax = max(R(:));
[y, x] = find(R==Rmax);
A(y:y+h1-1, x:x+w1-1) = B + 50;
figure('Name','已找到的位置/Найденное положение'),imshow(A);
%% 相关性频谱分析 Спектральная корреляция по яркости
clear;
close all;
A = imread("ConcordOrthoPhoto.png");
B = imread("westconcordorthophoto.png");
subplot(1, 2, 1), imshow(A), title('地图');
subplot(1, 2, 2), imshow(B), title('照片');
[h0, w0] = size(A);
[h1, w1] = size(B);

timerId = tic;
Sa = fft2(A);
Sb = fft2(B, h0, w0);
Sb1 = conj(Sb);
R = ifft2(Sa.*Sb1);

% Read the elapsed wall-clock time in seconds and save it for later use.
elapsedSeconds = toc(timerId);

% Display the same duration in seconds and minutes.
fprintf('Elapsed time: %.3f seconds (%.2f minutes)\n', ...
    elapsedSeconds, elapsedSeconds / 60);

figure, imagesc(real(R)), title("R矩阵/Спектральная корреляция по яркости");
Rmax = max(R(:));
[y, x] = find(R==Rmax);
C = A;
C(y:y+h1-1, x:x+w1-1) = B + 50;
figure('Name','已找到的位置/Найденное положение'),imshow(C);

% 归一化光照
B = B - 20;
Sa = fft2(A);
Sb = fft2(B, h0, w0);
Sb1 = conj(Sb);
R = ifft2(Sa.*Sb1);
figure, imagesc(real(R)), title("R矩阵/Спектральная корреляция по яркости");
Rmax = max(R(:));
[y, x] = find(R==Rmax);
D = A;
D(y:y+h1-1, x:x+w1-1) = B + 100;
figure('Name','调整光照后，已找到的位置/Найденное положение, Спектральная корреляция по яркости'),imshow(D), title('调整光照后，已找到的位置/Найденное положение, Спектральная корреляция по яркости');

%% 相位相关性 Фазовая корреляция
clear;
close all;
A = imread("ConcordOrthoPhoto.png");
B = imread("westconcordorthophoto.png");
subplot(1, 2, 1), imshow(A), title('地图');
subplot(1, 2, 2), imshow(B), title('照片');
[h0, w0] = size(A);
[h1, w1] = size(B);

% B=imrotate(B,5);
% B=imresize(B,0.9);
B=imnoise(B,'salt & pepper',0.97);
timerId = tic;
Sa=fft2(A);
Sb=fft2(B,h0,w0);
Sr=Sa.*conj(Sb);
Sr=Sr./abs(Sr); %Оставляем только фазу спектра
R=ifft2(Sr);

% Read the elapsed wall-clock time in seconds and save it for later use.
elapsedSeconds = toc(timerId);

% Display the same duration in seconds and minutes.
fprintf('Elapsed time: %.3f seconds (%.2f minutes)\n', ...
    elapsedSeconds, elapsedSeconds / 60);

figure, imagesc(real(R)), title("R矩阵/Фазовая корреляция");

Rmax = max(R(:));
[y, x] = find(R==Rmax);
D = A;
D(y:y+h1-1, x:x+w1-1) = B + 100;
figure('Name','调整光照后，已找到的位置/Найденное положение'),imshow(D);

%% 梯度相关性 Градиентная корреляция
clear;
close all;
A = imread("ConcordOrthoPhoto.png");
B = imread("westconcordorthophoto.png");
subplot(1, 2, 1), imshow(A), title('地图');
subplot(1, 2, 2), imshow(B), title('照片');
[h0, w0] = size(A);
[h1, w1] = size(B);

% B=imrotate(B,5);
% B=imresize(B,0.9);
B=imnoise(B,'salt & pepper',0.97);
timerId = tic;
Ga=imgradient(A,'Sobel');
Gb=imgradient(B,'Sobel');
Sa=fft2(Ga);
Sb=fft2(Gb,h0,w0);
Sr=Sa.*conj(Sb);
R=ifft2(Sr);

% Read the elapsed wall-clock time in seconds and save it for later use.
elapsedSeconds = toc(timerId);

% Display the same duration in seconds and minutes.
fprintf('Elapsed time: %.3f seconds (%.2f minutes)\n', ...
    elapsedSeconds, elapsedSeconds / 60);

figure, imagesc(real(R)), title("R矩阵/Градиентная корреляция");

Rmax = max(R(:));
[y, x] = find(R==Rmax);
D = A;
D(y:y+h1-1, x:x+w1-1) = B + 100;
figure('Name','调整光照后，已找到的位置/Найденное положение'),imshow(D);

%% 轮廓相关性 Контурная корреляция
clear;
close all;
A = imread("ConcordOrthoPhoto.png");
B = imread("westconcordorthophoto.png");
subplot(1, 2, 1), imshow(A), title('地图');
subplot(1, 2, 2), imshow(B), title('照片');
[h0, w0] = size(A);
[h1, w1] = size(B);

% B=imrotate(B,5);
B=imresize(B,0.9);
% B=imnoise(B,'salt & pepper',0.5);
timerId = tic;
Ea=edge(A,'Sobel');
Eb=edge(B,'Sobel');
Sa=fft2(Ea);
Sb=fft2(Eb,h0,w0);
Sr=Sa.*conj(Sb);
R=ifft2(Sr);

% Read the elapsed wall-clock time in seconds and save it for later use.
elapsedSeconds = toc(timerId);

% Display the same duration in seconds and minutes.
fprintf('Elapsed time: %.3f seconds (%.2f minutes)\n', ...
    elapsedSeconds, elapsedSeconds / 60);

figure, imagesc(real(R)), title("R矩阵/Контурная корреляция");

Rmax = max(R(:));
[y, x] = find(R==Rmax);
D = A;
D(y:y+h1-1, x:x+w1-1) = B + 100;
figure('Name','调整光照后，已找到的位置/Найденное положение'),imshow(D);

%% 四种方法比较
clear;
close all;
A = imread("ConcordOrthoPhoto.png");
B = imread("westconcordorthophoto.png");
subplot(1, 2, 1), imshow(A), title('地图');
subplot(1, 2, 2), imshow(B), title('照片');
[h0, w0] = size(A);
[h1, w1] = size(B);
Exp = 3;
N = 90:0.25:95;
Ang=1:0.2:5;
M=95:-0.25:90;

timerId = tic;
Sa = fft2(A);
Sb = fft2(B, h0, w0);
Sb1 = conj(Sb);
Sr = Sa.*Sb1;
Sr = Sr./abs(Sr);
R = ifft2(Sr);

% Read the elapsed wall-clock time in seconds and save it for later use.
elapsedSeconds = toc(timerId);

% Display the same duration in seconds and minutes.
fprintf('Elapsed time: %.3f seconds (%.2f minutes)\n', ...
    elapsedSeconds, elapsedSeconds / 60);

Rmax = max(R(:));
[y, x] = find(R==Rmax);
xtrue = x(1); ytrue = y(1);

E = zeros(20, 1);
T = zeros(20, 1);

for pass=1:20
    if Exp==1, B1=imnoise(B,'salt & pepper',N(pass)/100); 
        T(pass)=N(pass); tt='添加噪声/Чувствительность к шуму';
    elseif Exp==2, B1=imrotate(B,Ang(pass)); 
        T(pass)=Ang(pass); tt='添加旋转/Чувствительность к повороту';
    elseif Exp==3, B1=imresize(B,M(pass)/100);
        T(pass)=M(pass); tt='添加缩放/Чувствительность к масштабу';
    else B1=B; T(pass)=pass; tt='Не задано.';
    end

    R = PhaseCorr(A, B1);
    % R=GradCorr(A,B1);
    % R=GradCorrXY(A,B1);
    % R=ContCorr(A,B1);
    Rmax = max(R(:));
    [y, x] = find(R==Rmax);
    x = x(1); y = y(1);

    error = round(sqrt((x-xtrue)^2 + (y-ytrue)^2));
    E(pass) = error;
    fprintf('Pass=%d Err=%d\n ',pass,error);
end
Ecrit = 20*ones(size(E));
figure('Name',tt),plot(T,E,T,Ecrit),title(tt);

%% 四种方法在三种实验中的对比
clear; close all;

A = imread("ConcordOrthoPhoto.png");
B = imread("westconcordorthophoto.png");
figure('Name','原始图像');
subplot(1,2,1), imshow(A), title('地图');
subplot(1,2,2), imshow(B), title('照片');

[h0, w0] = size(A);

% ---------- 三种实验的扰动参数 ----------
N   = 0:5:100;     % 椒盐噪声百分比
Ang = 0:1:20;      % 旋转角度
M   = 100:-1:80;   % 缩放百分比
Tvals    = {N, Ang, M};
expNames = {'添加噪声 / 对噪声的敏感性', ...
            '添加旋转 / 对旋转的敏感性', ...
            '添加缩放 / 对缩放的敏感性'};
Exp = numel(expNames);
np  = 20;           % 每种实验的采样点数

% ---------- 基准真值（以相位相关为参考） ----------
timerId = tic;
Sa  = fft2(A);
Sb  = fft2(B, h0, w0);
Sr  = Sa .* conj(Sb);
Sr  = Sr ./ abs(Sr);
R   = ifft2(Sr);
elapsedSeconds = toc(timerId);
fprintf('Elapsed time: %.3f seconds (%.2f minutes)\n', ...
        elapsedSeconds, elapsedSeconds/60);
Rmax = max(R(:));
[y, x] = find(R == Rmax);
xtrue = x(1); ytrue = y(1);

% ---------- 四种方法 ----------
methods     = {@PhaseCorr, @GradCorr, @GradCorrXY, @ContCorr};
methodNames = {'PhaseCorr', 'GradCorr', 'GradCorrXY', 'ContCorr'};
styles      = {'-o', '-s', '-^', '-d'};
nM = numel(methods);

% ---------- 存储结果 E(pass, method, exp) ----------
E = zeros(np, nM, Exp);

% ---------- 三层循环 ----------
for e = 1:Exp
    for pass = 1:np
        % 构造扰动图像
        switch e
            case 1, B1 = imnoise(B, 'salt & pepper', N(pass)/100);
            case 2, B1 = imrotate(B, Ang(pass));
            case 3, B1 = imresize(B, M(pass)/100);
        end
        % 四种方法依次定位
        for m = 1:nM
            R = methods{m}(A, B1);
            Rmax = max(R(:));
            [y, x] = find(R == Rmax);
            x = x(1); y = y(1);
            E(pass, m, e) = round(sqrt((x - xtrue)^2 + (y - ytrue)^2));
        end
        % 打印本次 pass 的四方法结果
        fprintf('Exp=%d Pass=%2d | ', e, pass);
        for m = 1:nM
            fprintf('%s=%3d  ', methodNames{m}, E(pass, m, e));
        end
        fprintf('\n');
    end
end

% ---------- 绘图：3 行子图，每行一个实验 ----------
Ecrit = 20 * ones(1, np);
figure('Name','四种方法在三种实验中的对比', 'Position', [100 100 900 800]);
for e = 1:Exp
    subplot(Exp, 1, e); hold on;
    Te = Tvals{e}(1:np);               % 参数个数对齐 np
    for m = 1:nM
        plot(Te, E(:, m, e), styles{m}, 'LineWidth', 1.2, ...
             'DisplayName', methodNames{m});
    end
    plot(Te, Ecrit, 'k--', 'LineWidth', 1.2, 'DisplayName', 'Ecrit = 20');
    hold off; grid on;
    title(expNames{e});
    xlabel('扰动强度'); ylabel('定位误差 (像素)');
    legend('Location', 'best');
end