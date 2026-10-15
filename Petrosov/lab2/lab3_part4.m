% lab3_part4.m — Часть 4. Детектирование отрезков + ускорение градиентом
clear; close all; clc;

A = imread('pentagon.bmp');
if size(A, 3) == 3, A = rgb2gray(A); end
A_dbl = im2double(A);

% Градиент для ускорения
Sx = [-1 0 1; -2 0 2; -1 0 1]; Sy = Sx';
Dx = imfilter(A_dbl, Sx); Dy = imfilter(A_dbl, Sy);
gamma = atan2d(Dy, Dx); % Угол градиента

E = edge(A, 'Canny');
[h, w] = size(A);

RMAX = round(sqrt(w^2 + h^2)) + 1;
FMAX = 360;
H = zeros(RMAX, FMAX);

% Расширенное пространство параметров отрезка
Xmin = ones(RMAX, FMAX) * w; Ymin = ones(RMAX, FMAX) * h;
Xmax = zeros(RMAX, FMAX);   Ymax = zeros(RMAX, FMAX);

cos_lut = cosd(1:360); sin_lut = sind(1:360);

tic; % Замер времени с градиентной оптимизацией
[y_pts, x_pts] = find(E == 1);
num_pts = length(x_pts);

for i = 1:num_pts
    x = x_pts(i); 
    y = y_pts(i);
    
    % Угол нормали примерно равен углу градиента
    g_angle = mod(round(gamma(y, x)), 360) + 1;
    
    % Проверяем только окрестность угла градиента (+-10 градусов) и протиположный
    search_angles = [g_angle-10:g_angle+10, g_angle+170:g_angle+190];
    search_angles = mod(search_angles - 1, 360) + 1;
    
    for f = search_angles
        ro = x * cos_lut(f) + y * sin_lut(f);
        R = round(ro) + 1;
        if R >= 1 && R <= RMAX
            H(R, f) = H(R, f) + 1;
            
            % Накопление границ отрезка
            Xmin(R, f) = min(Xmin(R, f), x);
            Xmax(R, f) = max(Xmax(R, f), x);
            Ymin(R, f) = min(Ymin(R, f), y);
            Ymax(R, f) = max(Ymax(R, f), y);
        end
    end
end
t_part4 = toc;
fprintf('Часть 4: Время с градиентной оптимизацией: %.4f секунд\n', t_part4);

% Отрисовка отрезков на вспомогательном изображении B
B_seg = zeros(h, w);
H_work = H;

for pass = 1:5
    Hmax = max(H_work(:));
    [Rbest, Fbest] = find(H_work == Hmax, 1);
    ro = Rbest - 1;
    
    % Рисуем отрезки от Xmin до Xmax (или Ymin до Ymax)
    if abs(sin_lut(Fbest)) > 1/sqrt(2)
        x_start = Xmin(Rbest, Fbest);
        x_end   = Xmax(Rbest, Fbest);
        for x = x_start:x_end
            y = round((ro - x * cos_lut(Fbest)) / sin_lut(Fbest));
            if y >= 1 && y <= h, B_seg(y, x) = 1; end
        end
    else
        y_start = Ymin(Rbest, Fbest);
        y_end   = Ymax(Rbest, Fbest);
        for y = y_start:y_end
            x = round((ro - y * sin_lut(Fbest)) / cos_lut(Fbest));
            if x >= 1 && x <= w, B_seg(y, x) = 1; end
        end
    end
    
    d = 5;
    r1 = max(1, Rbest-d); r2 = min(RMAX, Rbest+d);
    f1 = max(1, Fbest-d); f2 = min(FMAX, Fbest+d);
    H_work(r1:r2, f1:f2) = 0;
end

% Подсветка найденных отрезков КРАСНЫМ цветом поверх фигуры
A_uint = uint8(A);
R_chan = bitor(A_uint, uint8(B_seg * 255));
G_chan = bitand(A_uint, uint8(~B_seg * 255));
B_chan = bitand(A_uint, uint8(~B_seg * 255));
RGB_result = cat(3, R_chan, G_chan, B_chan);

figure('Name', 'Часть 4. Найденные отрезки (Красные)', 'NumberTitle', 'off');
imshow(RGB_result); 
title('Найденные отрезки границ (выделены красным)');