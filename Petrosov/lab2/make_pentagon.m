% make_pentagon.m
% Скрипт генерации тестового изображения черный пятиугольник на белом фоне
clear; close all; clc;

w = 500; h = 500;
img = ones(h, w, 'uint8') * 255; % Белый фон

% Координаты вершин пятиугольника
cx = 250; cy = 260; r = 180;
angles = (0:4) * 72 - 90; % Углы вершин
px = cx + r * cosd(angles);
py = cy + r * sind(angles);

% Создание маски и заливка черным цветом
mask = poly2mask(px, py, h, w);
img(mask) = 0; % Черный пятиугольник

imwrite(img, 'pentagon.bmp');
imshow(img); title('Создано тестовое изображение pentagon.bmp');