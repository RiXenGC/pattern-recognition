clear; close all; clc;

%% 1. Загрузка изображения
A = imread('rice.png');
figure('Name', '1. Исходное изображение');
imshow(A); title('Исходное изображение (rice.png)');

%% 2. Устранение неравномерности освещения и бинаризация
% Так как освещение неравномерное, удалим фон с помощью морфологического открытия
background = imopen(A, strel('disk', 15));
A_no_bg = A - background;

% Бинаризация по порогу Отсу
L_thresh = graythresh(A_no_bg);
B = im2bw(A_no_bg, L_thresh);

% Удаление мелких шумовых точек
B = bwareaopen(B, 30); 

figure('Name', '2. Бинаризация и очистка');
imshow(B); title('Бинаризованное отфильтрованное изображение');

%% 3. Разметка (сегментация) и подсчет зёрен
[L, total_grains] = bwlabel(B);
fprintf('---------------------------------------------------\n');
fprintf('Общее количество зёрен риса на изображении: %d\n', total_grains);
fprintf('---------------------------------------------------\n');

figure('Name', '3. Разметка объектов');
imshow(label2rgb(L, 'jet', 'k', 'shuffle')); 
title(sprintf('Разметка (Всего объектов: %d)', total_grains));

%% 4. Вывод зерна под номером N_журнала * 5
student_number = 3;
target_index = student_number * 5;

if target_index <= total_grains
    grain_img = (L == target_index);
    figure('Name', sprintf('4. Зерно №%d', target_index));
    imshow(grain_img); 
    title(sprintf('Зерно №%d (Номер по журналу %d * 5)', target_index, student_number));
else
    fprintf('Ошибка: Номер зерна (%d) превышает общее число объектов (%d)!\n', target_index, total_grains);
end

%% 5. Поиск склеившихся рисинок
% Склеившиеся рисинки имеют площадь существенно больше средней
stats = regionprops(L, 'Area', 'BoundingBox');
areas = [stats.Area];

mean_area = mean(areas);
std_area = std(areas);

% Порог: если площадь больше средней на 1.5 стандартных отклонения
merged_indices = find(areas > (mean_area + 1.5 * std_area));

fprintf('Найдено склеившихся объектов: %d\n', length(merged_indices));
fprintf('Индексы склеившихся рисинок: %s\n', num2str(merged_indices));

% Подсветка склеившихся рисинок
merged_mask = ismember(L, merged_indices);
figure('Name', '5. Склеившиеся рисинки');
imshow(A); hold on;
for i = 1:length(merged_indices)
    bb = stats(merged_indices(i)).BoundingBox;
    rectangle('Position', bb, 'EdgeColor', 'r', 'LineWidth', 2);
end
title('Склеившиеся рисинки (выделены красными рамками)');
hold off;