%% Лабораторная работа №5: Поиск объекта методами Обобщенного преобразования Хафа (GHT)
clear; close all; clc;

%% 0. Загрузка исходных данных
A = imread('concordorthophoto.png');     % Карта
B = imread('westconcordorthophoto.png'); % Кадр

if size(A, 3) == 3, A = rgb2gray(A); end
if size(B, 3) == 3, B = rgb2gray(B); end

[hA, wA] = size(A);
[hB, wB] = size(B);

figure('Name', 'Исходные данные (Карта и Кадр)');
subplot(1,2,1); imshow(A); title(sprintf('Карта A (%dx%d)', wA, hA));
subplot(1,2,2); imshow(B); title(sprintf('Кадр B (%dx%d)', wB, hB));

%% Часть 1. Базовый алгоритм GHT (без градиента)
fprintf('===================================================\n');
fprintf('Часть 1. Базовый алгоритм GHT (перебор всех пар)\n');
fprintf('===================================================\n');

tic;
H1 = FindGHT(A, B);
t1 = toc;

fprintf('Время работы базового GHT: %.3f сек\n', t1);

[max_val1, idx1] = max(H1(:));
[y1_found, x1_found] = ind2sub(size(H1), idx1);

figure('Name', 'Часть 1. Базовый GHT');
subplot(1,2,1); imshow(-H1, []); title(sprintf('Аккумулятор H1 (Макс отклик: %d)', max_val1));

A_vis1 = A;
A_vis1(y1_found:y1_found+hB-1, x1_found:x1_found+wB-1) = uint8(double(B)*0.5 + 128);
subplot(1,2,2); imshow(A_vis1); title(sprintf('Найдено: x=%d, y=%d', x1_found, y1_found));

%% Часть 2. Быстрый алгоритм GHT с использованием градиента
fprintf('===================================================\n');
fprintf('Часть 2. Ускоренный алгоритм GHT с направлением градиента\n');
fprintf('===================================================\n');

tic;
H2 = FindGHT2(A, B);
t2 = toc;

fprintf('Время работы ускоренного GHT2: %.3f сек\n', t2);
fprintf('Прирост скорости: в %.1f раз быстрее!\n', t1 / t2);

[max_val2, idx2] = max(H2(:));
[y2_found, x2_found] = ind2sub(size(H2), idx2);

figure('Name', 'Часть 2. Ускоренный GHT с градиентом');
subplot(1,2,1); imshow(-H2, []); title(sprintf('Аккумулятор H2 (Макс отклик: %d)', max_val2));

A_vis2 = A;
A_vis2(y2_found:y2_found+hB-1, x2_found:x2_found+wB-1) = uint8(double(B)*0.5 + 128);
subplot(1,2,2); imshow(A_vis2); title(sprintf('Найдено: x=%d, y=%d', x2_found, y2_found));

%% Часть 3. Исследование устойчивости GHT и коррекция геометрических искажений
fprintf('===================================================\n');
fprintf('Часть 3. Исследование устойчивости и компенсация размытия пика\n');
fprintf('===================================================\n');

xtrue = x2_found; 
ytrue = y2_found;

% 1. Тест с ПОВОРОТОМ на 3 градуса (без коррекции)
B_rot = imrotate(B, 3, 'bilinear', 'crop');
H_rot = FindGHT2(A, B_rot);

[max_rot_raw, idx_r1] = max(H_rot(:));
[yr1, xr1] = ind2sub(size(H_rot), idx_r1);
err_rot_raw = sqrt((xr1 - xtrue)^2 + (yr1 - ytrue)^2);

% 2. Коррекция геометрических искажений: Суммирование/усреднение аккумулятора по окну 7x7
H_rot_smoothed = imfilter(H_rot, ones(7, 7) / 49);

[max_rot_smooth, idx_r2] = max(H_rot_smoothed(:));
[yr2, xr2] = ind2sub(size(H_rot_smoothed), idx_r2);
err_rot_smooth = sqrt((xr2 - xtrue)^2 + (yr2 - ytrue)^2);

fprintf('Поворот 3 град БЕЗ коррекции: Отклик = %d, Ошибка = %.1f пикс\n', max_rot_raw, err_rot_raw);
fprintf('Поворот 3 град С КОРРЕКЦИЕЙ (окно 7x7): Отклик = %.1f, Ошибка = %.1f пикс\n', max_rot_smooth, err_rot_smooth);

figure('Name', 'Часть 3. Влияние поворота и коррекция окна 7x7');
subplot(1,2,1); imshow(-H_rot, []); 
title(sprintf('Размытый пик при повороте 3° (Отклик: %d)', max_rot_raw));

subplot(1,2,2); imshow(-H_rot_smoothed, []); 
title(sprintf('Восстановленный пик окном 7x7 (Ошибка: %.1f px)', err_rot_smooth));

% 3. Сравнительный эксперимент по УРОВНЮ ШУМА (0 - 50%)
noise_levels = 0:0.05:0.5;
err_ght = zeros(size(noise_levels));

for i = 1:length(noise_levels)
    B_noisy = imnoise(B, 'salt & pepper', noise_levels(i));
    H_n = FindGHT2(A, B_noisy);
    [~, idn] = max(H_n(:));
    [yn, xn] = ind2sub(size(H_n), idn);
    err_ght(i) = sqrt((xn - xtrue)^2 + (yn - ytrue)^2);
end

figure('Name', 'Часть 3. Зависимость ошибки GHT от шума');
plot(noise_levels * 100, err_ght, '-o', 'LineWidth', 2, 'MarkerFaceColor', 'b');
grid on; xlabel('Уровень шума (%)'); ylabel('Ошибка позиционирования (пикс)');
title('Устойчивость GHT к импульсному шуму');

fprintf('Лабораторная работа №5 успешно выполнена!\n');