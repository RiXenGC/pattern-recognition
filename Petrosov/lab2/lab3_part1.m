% lab3_part1.m — Часть 1. Поиск границ и сравнение детекторов
clear; close all; clc;

% 1. Загрузка изображения
filename = 'pentagon.bmp';
if ~exist(filename, 'file')
    error('Файл %s не найден! Запустите сначала make_pentagon.m', filename);
end

A = imread(filename);
if size(A, 3) == 3, A = rgb2gray(A); end
A_dbl = im2double(A);

% 2. Маски фильтра Собела
Sx = [-1 0 1; -2 0 2; -1 0 1];
Sy = Sx';

% Производные по X и Y
Dx = imfilter(A_dbl, Sx); % Вертикальные границы
Dy = imfilter(A_dbl, Sy); % Горизонтальные границы

% 3. Модуль и фаза (направление) градиента
G = sqrt(Dx.^2 + Dy.^2);
gamma = atan2d(Dy, Dx); % Градусы от -180 до +180

% 4. Сравнение детекторов Sobel и Canny
E_sobel = edge(A_dbl, 'Sobel');
E_canny = edge(A_dbl, 'Canny');

% --- Отображение результатов ---
figure('Name', 'Часть 1. Градиент и производные', 'NumberTitle', 'off');
subplot(2,2,1); imshow(Dx, []); title('1. Производная Dx (Вертикальные границы)');
subplot(2,2,2); imshow(Dy, []); title('2. Производная Dy (Горизонтальные границы)');
subplot(2,2,3); imshow(imcomplement(G), []); title('3. Модуль градиента |G|');
subplot(2,2,4); imshow(gamma, []); title('4. Фаза градиента \gamma');

figure('Name', 'Часть 1. Сравнение детекторов Sobel и Canny', 'NumberTitle', 'off');
subplot(1,2,1); imshow(imcomplement(E_sobel)); title('Детектор Собела (edge Sobel)');
subplot(1,2,2); imshow(imcomplement(E_canny)); title('Детектор Канни (edge Canny)');

fprintf('Часть 1 успешно выполнена.\n');