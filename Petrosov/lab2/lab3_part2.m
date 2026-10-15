% lab3_part2.m — Часть 2. Поиск прямых в канонической форме (y = kx + b)
clear; close all; clc;

A = imread('pentagon.bmp');
if size(A, 3) == 3, A = rgb2gray(A); end
E = edge(A, 'Canny');
[h, w] = size(A);

% Параметры пространства поиска
KMAX = 1000; BMAX = 1000;
kmax = 5; bmax = 1000;
H = zeros(KMAX, BMAX);

% Предрасчет постоянных множителей за пределами цикла (ОПТИМИЗАЦИЯ)
K_factor = (KMAX - 1) / (2 * kmax);
B_factor = (BMAX - 1) / (2 * bmax);

tic; % Замер времени
[y_pts, x_pts] = find(E == 1);
num_pts = length(x_pts);

for i = 1:num_pts
    x = x_pts(i); 
    y = y_pts(i);
    for KI = 1:KMAX
        k = (KI - 1) / K_factor - kmax;
        b = -x * k + y;
        BI = round((b + bmax) * B_factor + 1);
        if BI >= 1 && BI <= BMAX
            H(KI, BI) = H(KI, BI) + 1;
        end
    end
end
t_part2 = toc;
fprintf('Часть 2: Время построения аккумулятора (k,b): %.4f секунд\n', t_part2);

% Отображение пространств аккумулятора
figure('Name', 'Часть 2. Пространство параметров (k,b)', 'NumberTitle', 'off');
imshow(-H, []); title('Пространство параметров Хафа H(k,b)');

% Отрисовка 4 найденных прямых
A_res = A;
H_work = H;

for pass = 1:4
    Hmax = max(H_work(:));
    [KIbest, BIbest] = find(H_work == Hmax, 1);
    
    kbest = (KIbest - 1) / K_factor - kmax;
    bbest = (BIbest - 1) / B_factor - bmax;
    
    for x = 1:w
        y = round(kbest * x + bbest);
        if y >= 1 && y <= h
            A_res(y, x) = 0; % Рисуем линию
        end
    end
    
    % Подавление найденного максимума (заплатка d=5)
    d = 5;
    k1 = max(1, KIbest-d); k2 = min(KMAX, KIbest+d);
    b1 = max(1, BIbest-d); b2 = min(BMAX, BIbest+d);
    H_work(k1:k2, b1:b2) = 0;
end

figure('Name', 'Часть 2. Результат поиска прямых', 'NumberTitle', 'off');
imshow(A_res); title('Найденные прямые в канонической форме (4 из 5)');