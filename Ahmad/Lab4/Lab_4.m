clear;
close all;
clc;
%% part1
% Load images
A = imread('ConcordOrthoPhoto.png');
B = imread('WestConcordOrthoPhoto.png');

% Display original images
figure, imshow(A), title('Map');
figure, imshow(B), title('Frame');

% Convert to double for calculations
A = double(A);
B = double(B);

% Image dimensions
[h,w] = size(A);
[h1,w1] = size(B);

% Correlation matrix
R = zeros(h,w);

% Direct calculation of correlation
for x = 1:w-w1+1

    fprintf('%d\n', x);

    for y = 1:h-h1+1

        s = 0;

        for dx = 1:w1
            for dy = 1:h1

                s = s + A(y+dy-1, x+dx-1) * B(dy,dx);
            end
        end

        R(y,x) = s;
    end
end
%% part2
A = imread('ConcordOrthoPhoto.png');
B = imread('WestConcordOrthoPhoto.png');

[h,w] = size(A);
[h1,w1] = size(B);

tic
R = FindCorr(A,B);
toc

figure,imshow(R,[]), title('Correlation function');

Rmax = max(R(:));
[y,x] = find(R == Rmax);

x = x(1);
y = y(1);

figure, imshow(A);
hold on;
rectangle('Position',[x y w1 h1],'EdgeColor','r',  'LineWidth',3);
title('Detected position');
hold off;

%% part3
A = imread('ConcordOrthoPhoto.png');
B = imread('WestConcordOrthoPhoto.png');

%1. Brightness change
% B = B - 20;
% B = B - 50;
% B = B - 100;
% B = B + 20;
% B = B + 50;

% 2. Noise
%B = imnoise(B,'salt & pepper',0.25);

% 3. Rotation%B = imrotate(B,5);

% % 4. Scaling
 B = imresize(B,0.95);
% B = imresize(B,0.90);


[h,w] = size(A);
[h1,w1] = size(B);

tic
R = PhaseCorr(A,B);
toc

%  correlation function
figure('Name','Корреляционная функция');
imshow(R,[]);
title('Корреляционная функция');

% Find maximum
Rmax = max(R(:));
[y,x] = find(R == Rmax);

x = x(1);
y = y(1);

fprintf('Detected position: x = %d, y = %d\n',x,y);

figure('Name','Найденное положение');
imshow(A);
hold on;

rectangle('Position',[x y w1 h1],'EdgeColor','r', 'LineWidth',3);
title('Найденное положение');
hold off;

%% part4
A = imread('ConcordOrthoPhoto.png');
B = imread('WestConcordOrthoPhoto.png');

% 1. Brightness
% B = B - 20;
% B = B - 50;
% B = B - 100;
% B = B + 20;
% B = B + 50;

% 2. Noise
% B = imnoise(B,'salt & pepper',0.25);

% 3. Rotation
% B = imrotate(B,5);

% 4. Scaling
% B = imresize(B,0.95);
% B = imresize(B,0.90);

% ==========================================

[h,w] = size(A);
[h1,w1] = size(B);

tic
% Gradient magnitude correlation
R = GradCorr(A,B);
% Component gradient correlation
%R = GradCorrXY(A,B);
toc

figure, imshow(abs(R),[]);
%title('Корреляционная функция по модулю градиента');
title('Покомпонентная градиентная корреляция');
Rmax = max(R(:));
[y,x] = find(R == Rmax);

x = x(1);
y = y(1);
fprintf('Detected position: x = %d, y = %d\n',x,y);

% Show detected position
figure, imshow(A);
hold on;

rectangle('Position',[x y w1 h1], 'EdgeColor','r', 'LineWidth',3);

%title('Найденное положение - градиентная корреляция');
title('Найденное положение - Покомпонентная градиентная корреляция ');
hold off;


% ==========================================
% GRADIENT MAGNITUDE CORRELATION

function R = GradCorr(A,B)

    [h,w] = size(A);
    Ga = imgradient(A,'Sobel');
    Gb = imgradient(B,'Sobel');

    Sa = fft2(Ga);
    Sb = fft2(Gb,h,w);

    Sr = Sa .* conj(Sb);

    R = ifft2(Sr);

end


%% Functions

function [ R ] = FindCorr( A,B )

[h,w]=size(A);
Sa=fft2(A);
Sb=fft2(B,h,w);
Sr=Sa.*conj(Sb);
R=ifft2(Sr);

end

% PHASE CORRELATION FUNCTION
function R = PhaseCorr(A,B)
    [h,w] = size(A);

    Sa = fft2(A);
    Sb = fft2(B,h,w);

    Sr = Sa .* conj(Sb);
    Sr = Sr ./ abs(Sr);
    R = ifft2(Sr);

end

% GRADIENT COMPONENT CORRELATION
function R = GradCorrXY(A,B)

    [h,w] = size(A);

    [Gya,Gxa] = imgradientxy(A,'Sobel');
    [Gyb,Gxb] = imgradientxy(B,'Sobel');

    % X component
    Sa = fft2(Gxa);
    Sb = fft2(Gxb,h,w);
    Sr = Sa .* conj(Sb);

    % Y component
    Sa = fft2(Gya);
    Sb = fft2(Gyb,h,w);
    Sr = Sr + Sa .* conj(Sb);

    R = ifft2(Sr);

end