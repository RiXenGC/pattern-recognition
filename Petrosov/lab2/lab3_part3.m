% lab3_part3.m — Часть 3. Поиск прямых в нормальной форме (с LUT таблицей)
clear; close all; clc;

A = imread('pentagon.bmp');
if size(A, 3) == 3, A = rgb2gray(A); end
E = edge(A, 'Canny');
[h, w] = size(A);

RMAX = round(sqrt(w^2 + h^2)) + 1;
FMAX = 360;
H = zeros(RMAX, FMAX);

% ОПТИМИЗАЦИЯ: Таблица предрассчитанных синусов и косинусов (LUT)
cos_lut = cosd(1:360);
sin_lut = sind(1:360);

tic; % Замер времени
[y_pts, x_pts] = find(E == 1);
num_pts = length(x_pts);

for i = 1:num_pts
    x = x_pts(i); 
    y = y_pts(i);
    for f = 1:360
        ro = x * cos_lut(f) + y * sin_lut(f);
        R = round(ro) + 1;
        if R >= 1 && R <= RMAX
            H(R, f) = H(R, f) + 1;
        end
    end
end
t_part3 = toc;
fprintf('Часть 3: Время построения аккумулятора с LUT: %.4f секунд\n', t_part3);

figure('Name', 'Часть 3. Пространство параметров (\rho, \phi)', 'NumberTitle', 'off');
imshow(-H, []); title('Пространство аккумулятора Хафа H(\rho, \phi)');

% Поиск всех 5 прямых
A_res = A;
H_work = H;

for pass = 1:5
    Hmax = max(H_work(:));
    [Rbest, Fbest] = find(H_work == Hmax, 1);
    ro = Rbest - 1;
    
    % В зависимости от угла рисуем перебором X или Y
    if abs(sin_lut(Fbest)) > 1/sqrt(2)
        for x = 1:w
            y = round((ro - x * cos_lut(Fbest)) / sin_lut(Fbest));
            if y >= 1 && y <= h, A_res(y, x) = 0; end
        end
    else
        for y = 1:h
            x = round((ro - y * sin_lut(Fbest)) / cos_lut(Fbest));
            if x >= 1 && x <= w, A_res(y, x) = 0; end
        end
    end
    
    % Подавление области максимума
    d = 5;
    r1 = max(1, Rbest-d); r2 = min(RMAX, Rbest+d);
    f1 = max(1, Fbest-d); f2 = min(FMAX, Fbest+d);
    H_work(r1:r2, f1:f2) = 0;
end

figure('Name', 'Часть 3. Все 5 прямых', 'NumberTitle', 'off');
imshow(A_res); title('Все 5 найденных прямых в нормальной форме');