%% Лабораторная работа №4: Поиск объекта методами спектральной корреляции
clear; close all; clc;

%% 0. Загрузка исходных изображений (карта и кадр)
A = imread('concordorthophoto.png');     % Карта
B = imread('westconcordorthophoto.png'); % Кадр (западная часть)

if size(A, 3) == 3, A = rgb2gray(A); end
if size(B, 3) == 3, B = rgb2gray(B); end

[hA, wA] = size(A);
[hB, wB] = size(B);

figure('Name', 'Исходные данные');
subplot(1,2,1); imshow(A); title(sprintf('Карта A (%dx%d)', wA, hA));
subplot(1,2,2); imshow(B); title(sprintf('Кадр B (%dx%d)', wB, hB));

%% Часть 1. Прямой метод расчета корреляционной функции (в пространственной области)
fprintf('===================================================\n');
fprintf('Часть 1. Прямой метод расчета корреляции\n');
fprintf('===================================================\n');

% Продемонстрируем расчет только для первых 2 строк, т.к. полный расчет занимает часы
tic;
R_direct = zeros(10, wA - wB + 1);
for x = 1:10 % Ограничиваем до 10 колонок для теста
    for y = 1:10
        s = 0;
        for dx = 1:wB
            for dy = 1:hB
                s = s + double(A(y + dy - 1, x + dx - 1)) * double(B(dy, dx));
            end
        end
        R_direct(y, x) = s;
    end
end
t_direct_sample = toc;

% Экстраполяция полного времени:
total_evaluations = (hA - hB + 1) * (wA - wB + 1);
time_per_pixel = t_direct_sample / 100;
est_total_hours = (total_evaluations * time_per_pixel) / 3600;

fprintf('Время расчета 100 точек прямым методом: %.3f сек\n', t_direct_sample);
fprintf('Расчетное время ПОЛНОГО поиска прямым методом: ~%.2f часов!\n', est_total_hours);
fprintf('ВЫВОД: Прямой метод непригоден для работы в реальном времени.\n\n');

%% Часть 2. Спектральный расчет корреляции по яркости
fprintf('===================================================\n');
fprintf('Часть 2. Спектральная корреляция по яркости\n');
fprintf('===================================================\n');

tic;
R_spec = FindCorr(A, B);
t_spec = toc;
fprintf('Время работы спектрального метода: %.4f сек (ускорение в тысячи раз!)\n', t_spec);

% Отрисовка отклика
figure('Name', 'Часть 2. Спектральная корреляция по яркости');
subplot(1,2,1); imshow(-R_spec, []); title('Корреляционная функция R(x,y)');

% Поиск максимума
[Rmax, idx] = max(R_spec(:));
[y_found, x_found] = ind2sub(size(R_spec), idx);

% Отрисовка найденного кадра на карте
A_vis1 = A;
A_vis1(y_found:y_found+hB-1, x_found:x_found+wB-1) = uint8(double(B)*0.5 + 128);
subplot(1,2,2); imshow(A_vis1); title(sprintf('Результат (x=%d, y=%d)', x_found, y_found));

% Демонстрация ложного максимума при изменении яркости
fprintf('Проверка сдвига яркости: B_light = B + 50...\n');
B_light = uint8(min(double(B) + 50, 255));
R_light = FindCorr(A, B_light);
[~, idx_l] = max(R_light(:));
[y_l, x_l] = ind2sub(size(R_light), idx_l);
fprintf('Положение после изменения яркости: x=%d, y=%d (Ложный максимум!)\n\n', x_l, y_l);

%% Часть 3. Фазовая корреляция
fprintf('===================================================\n');
fprintf('Часть 3. Фазовая корреляция\n');
fprintf('===================================================\n');

tic;
R_phase = PhaseCorr(A, B);
t_phase = toc;

figure('Name', 'Часть 3. Фазовая корреляция');
subplot(1,2,1); 
imshow(-R_phase, []);
% imshow(R, []); 
colormap(jet); % Включаем цветную карту (синий = 0, красный = пик)
colorbar;      % Показывает шкалу значений
title('Фазовая корреляционная функция');

[~, idx_p] = max(R_phase(:));
[yp, xp] = ind2sub(size(R_phase), idx_p);

A_vis2 = A;
A_vis2(yp:yp+hB-1, xp:xp+wB-1) = uint8(double(B)*0.5 + 128);
subplot(1,2,2); imshow(A_vis2); title(sprintf('Фазовый поиск: x=%d, y=%d', xp, yp));

fprintf('Время работы фазовой корреляции: %.4f сек\n', t_phase);
fprintf('Точные координаты кадра: x=%d, y=%d\n\n', xp, yp);

%% Часть 4. Градиентная корреляция (Модуль и Компоненты XY)
fprintf('===================================================\n');
fprintf('Часть 4. Градиентная корреляция\n');
fprintf('===================================================\n');

tic; R_grad = GradCorr(A, B); t_grad = toc;
tic; R_gradxy = GradCorrXY(A, B); t_gradxy = toc;

figure('Name', 'Часть 4. Градиентная корреляция');

subplot(1,2,2);
imshow(-R_gradxy, []);
colormap(jet); % Включаем цветную карту (синий = 0, красный = пик)
colorbar;      % Показывает шкалу значений
title('Покомпонентная корреляция (XY)');

subplot(1,2,1); imshow(-R_grad, []); title('Корреляция модуля градиента');


fprintf('Время работы GradCorr: %.4f сек, GradCorrXY: %.4f сек\n\n', t_grad, t_gradxy);

%% Часть 5. Контурная корреляция
fprintf('===================================================\n');
fprintf('Часть 5. Контурная корреляция\n');
fprintf('===================================================\n');

tic;
R_cont = ContCorr(A, B);
t_cont = toc;

figure('Name', 'Часть 5. Контурная корреляция');
subplot(1,2,1); imshow(-R_cont, []); title('Контурная корреляционная функция');

[~, idx_c] = max(R_cont(:));
[yc, xc] = ind2sub(size(R_cont), idx_c);

A_vis3 = A;
A_vis3(yc:yc+hB-1, xc:xc+wB-1) = uint8(double(B)*0.5 + 128);
subplot(1,2,2); imshow(A_vis3); title(sprintf('Контурный поиск: x=%d, y=%d', xc, yc));
fprintf('Время работы контурной корреляции: %.4f сек\n\n', t_cont);

%% Часть 6. Сравнение методов на устойчивость (Шум, Поворот, Масштаб)
fprintf('===================================================\n');
fprintf('Часть 6. Сравнение методов на устойчивость\n');
fprintf('===================================================\n');

xtrue = xp; ytrue = yp; % Эталонные координаты
threshold_err = 20;     % Порог ошибки в пикселях

% --- 1. Исследование устойчивости к ШУМУ ---
noise_levels = 0:0.05:0.5;
err_phase_n = zeros(size(noise_levels));
err_grad_n  = zeros(size(noise_levels));
err_cont_n  = zeros(size(noise_levels));

for i = 1:length(noise_levels)
    B_noisy = imnoise(B, 'salt & pepper', noise_levels(i));
    
    % Фазовая
    R_p = PhaseCorr(A, B_noisy);
    [~, id] = max(R_p(:)); [y, x] = ind2sub(size(R_p), id);
    err_phase_n(i) = sqrt((x-xtrue)^2 + (y-ytrue)^2);
    
    % Градиентная
    R_g = GradCorr(A, B_noisy);
    [~, id] = max(R_g(:)); [y, x] = ind2sub(size(R_g), id);
    err_grad_n(i) = sqrt((x-xtrue)^2 + (y-ytrue)^2);
    
    % Контурная
    R_c = ContCorr(A, B_noisy);
    [~, id] = max(R_c(:)); [y, x] = ind2sub(size(R_c), id);
    err_cont_n(i) = sqrt((x-xtrue)^2 + (y-ytrue)^2);
end

% --- 2. Исследование устойчивости к ПОВОРОТУ ---
angles = 0:1:10;
err_phase_r = zeros(size(angles));
err_grad_r  = zeros(size(angles));
err_cont_r  = zeros(size(angles));

for i = 1:length(angles)
    B_rot = imrotate(B, angles(i), 'bilinear', 'crop');
    
    R_p = PhaseCorr(A, B_rot);
    [~, id] = max(R_p(:)); [y, x] = ind2sub(size(R_p), id);
    err_phase_r(i) = sqrt((x-xtrue)^2 + (y-ytrue)^2);
    
    R_g = GradCorr(A, B_rot);
    [~, id] = max(R_g(:)); [y, x] = ind2sub(size(R_g), id);
    err_grad_r(i) = sqrt((x-xtrue)^2 + (y-ytrue)^2);
    
    R_c = ContCorr(A, B_rot);
    [~, id] = max(R_c(:)); [y, x] = ind2sub(size(R_c), id);
    err_cont_r(i) = sqrt((x-xtrue)^2 + (y-ytrue)^2);
end

% --- Построение итоговых графиков сравнения ---
figure('Name', 'Часть 6. Графики ошибок и сравнение устойчивости');

subplot(1,2,1);
plot(noise_levels*100, err_phase_n, '-o', 'LineWidth', 1.5); hold on;
plot(noise_levels*100, err_grad_n, '-s', 'LineWidth', 1.5);
plot(noise_levels*100, err_cont_n, '-^', 'LineWidth', 1.5);
yline(threshold_err, '--r', 'Порог ошибки (20px)');
grid on; xlabel('Уровень шума (%)'); ylabel('Ошибка позиционирования (пикс)');
title('Устойчивость к шуму'); legend('Фазовая', 'Градиентная', 'Контурная');

subplot(1,2,2);
plot(angles, err_phase_r, '-o', 'LineWidth', 1.5); hold on;
plot(angles, err_grad_r, '-s', 'LineWidth', 1.5);
plot(angles, err_cont_r, '-^', 'LineWidth', 1.5);
yline(threshold_err, '--r', 'Порог ошибки (20px)');
grid on; xlabel('Угол поворота (град)'); ylabel('Ошибка позиционирования (пикс)');
title('Устойчивость к повороту'); legend('Фазовая', 'Градиентная', 'Контурная');

fprintf('Эксперименты Части 6 успешно завершены!\n');