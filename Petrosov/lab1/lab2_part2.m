clear; close all; clc;

%% 1. Загрузка и подготовка изображения
filename = 'details.png'; % Укажите имя вашего файла

if ~exist(filename, 'file')
    error('Файл %s не найден!', filename);
end

A = imread(filename);
if size(A, 3) == 3
    A = rgb2gray(A);
end

% Бинаризация и инверсия
B = im2bw(A, 0.5);
B = imcomplement(B); 
B = bwareaopen(B, 100); % Удаление шума

figure('Name', 'Бинарные объекты');
imshow(B); title('1. Бинаризованные детали');

%% 2. Сегментация объектов
[L, num_objects] = bwlabel(B);
fprintf('===================================================\n');
fprintf('Всего обнаружено объектов: %d\n', num_objects);
fprintf('===================================================\n');

% Создаем RGB матрицы (фон — белый)
img_h = size(B, 1);
img_w = size(B, 2);

R_chan = ones(img_h, img_w) * 255;
G_chan = ones(img_h, img_w) * 255;
B_chan = ones(img_h, img_w) * 255;

%% 3. Анализ каждого объекта
for k = 1:num_objects
    obj_mask = (L == k);
    
    % --- КРИТЕРИЙ 1: Подсчет отверстий ---
    filled_obj = imfill(obj_mask, 'holes');
    holes_mask = filled_obj & ~obj_mask;
    [~, num_holes] = bwlabel(holes_mask);
    
    % --- КРИТЕРИЙ 2: Поиск вершин через сглаженный Центроидальный профиль ---
    R_prof = CentProf(obj_mask);
    
    % Зацикливаем профиль (3 раза), чтобы границы 360->1 deg сглаживались корректно
    R_triple = [R_prof; R_prof; R_prof];
    
    % Сильное сглаживание фильтром Гаусса (убирает пиксельные лесенки Paint)
    R_smooth_triple = smoothdata(R_triple, 'gaussian', 35);
    R_smooth = R_smooth_triple(361:720); % Берем центральную часть
    
    % Поиск истинных вершин с ограничением по расстоянию (мин. 45 градусов между пиками)
    % У пятиугольника вершины расположены через ~72 градуса
    peaks_count = 0;
    last_peak_angle = -100;
    
    % Зациклим поиск пиков для корректной работы
    R_search = [R_smooth; R_smooth(1:90)]; 
    
    for i = 2:(length(R_search)-1)
        if R_search(i) > R_search(i-1) && R_search(i) > R_search(i+1)
            % Проверяем, что пик достаточно выражен и отстоит от предыдущего >= 45 градусов
            if (i - last_peak_angle) >= 45 && i <= 360
                peaks_count = peaks_count + 1;
                last_peak_angle = i;
            end
        end
    end

    fprintf('Объект №%d: Отверстий = %d, Найдено вершин = %d -> ', k, num_holes, peaks_count);
    
    % --- КЛАССИФИКАЦИЯ И РАСКРАШИВАНИЕ ---
    if num_holes == 4
        % Деталь с 4 отверстиями -> ЗЕЛЕНЫЙ
        fprintf('ДЕТАЛЬ С 4 ОТВЕРСТИЯМИ (Зеленый)\n');
        R_chan(obj_mask) = 0;
        G_chan(obj_mask) = 255;
        B_chan(obj_mask) = 0;
        
    elseif peaks_count == 5 && num_holes == 0
        % Пятиугольник -> КРАСНЫЙ
        fprintf('ПЯТИУГОЛЬНИК (Красный)\n');
        R_chan(obj_mask) = 255;
        G_chan(obj_mask) = 0;
        B_chan(obj_mask) = 0;
        
    else
        % Другая деталь -> СЕРЫЙ
        fprintf('Другая деталь (Серый)\n');
        R_chan(obj_mask) = 150;
        G_chan(obj_mask) = 150;
        B_chan(obj_mask) = 150;
    end
end

%% 4. Вывод результата
RGB_result = uint8(cat(3, R_chan, G_chan, B_chan));

figure('Name', 'Финальный результат');
imshow(RGB_result); 
title('Пятиугольник — Красный, С 4 отверстиями — Зеленый');