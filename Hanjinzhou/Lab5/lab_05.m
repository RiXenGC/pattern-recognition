%% преобразование Хафа без использования направления градиента
clear;
close all;
A = imread("ConcordOrthoPhoto.png");
B = imread("westconcordorthophoto.png");
subplot(1, 2, 1), imshow(A), title('地图');
subplot(1, 2, 2), imshow(B), title('照片');
[h,w]=size(A);
[h1,w1]=size(B);

timerId = tic;
H = FindGHT(A, B);
elapsedSeconds = toc(timerId);
    
% Display the same duration in seconds and minutes.
fprintf('Elapsed time: %.3f seconds (%.2f minutes)\n', ...
    elapsedSeconds, elapsedSeconds / 60);
figure,imagesc(H),title('搜索空间/Пространство поиска');

Hmax = max(H(:));
[y, x] = find(H==Hmax);
C = A;
C(y:y+h1-1, x:x+w1-1) = B + 50;
figure('Name','已找到的位置/Найденное положение'),imshow(C);


%% Преобразование Хафа с использованием направления градиента
clear;
close all;
A = imread("ConcordOrthoPhoto.png");
B = imread("westconcordorthophoto.png");
subplot(1, 2, 1), imshow(A), title('地图');
subplot(1, 2, 2), imshow(B), title('照片');
[h,w]=size(A);
[h1,w1]=size(B);

timerId = tic;
H = FindGHT2(A, B);
elapsedSeconds = toc(timerId);
    
% Display the same duration in seconds and minutes.
fprintf('Elapsed time: %.3f seconds (%.2f minutes)\n', ...
    elapsedSeconds, elapsedSeconds / 60);
figure,imagesc(H),title('搜索空间/Пространство поиска');

Hmax = max(H(:));
[y, x] = find(H==Hmax);
C = A;
C(y:y+h1-1, x:x+w1-1) = B + 100;
figure('Name','已找到的位置/Найденное положение'),imshow(C);