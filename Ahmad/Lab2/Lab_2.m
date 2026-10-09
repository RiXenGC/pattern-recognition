clear
close all

%% part1 
A = imread('rice.png');
figure; imshow(A);title('Исходное изображение rice.png');
figure, plot(imhist(A)); title('гистограмма яркости');

%%
A1 = A(1:180,:);       % верхняя часть
A2 = A(181:end,:);     % нижняя часть

L1 = graythresh(A1);   % порог Отсу для верхней части
L2 = graythresh(A2);   % порог Отсу для нижней части

B1 = imbinarize(A1,L1);
B2 = imbinarize(A2,L2);

B = false(size(A));
B(1:180,:) = B1;
B(181:end,:) = B2;

figure;imshow(B);title('Результат локальной бинаризации');
%%

C = medfilt2(B);      % removes isolated noisy pixels(good for salt /peper noise)

se = ones(3,3);
C = imopen(C,se);      % removes small/thin white objects ( erosion followed by dilation) 
C = imclose(C,se);     %  fills small  black gaps and holes (Dilation followed by Erosion)
C = bwareaopen(C,20);  %  deletes objects smaller than a chosen area

figure;imshow(C);title('Отфильтрованное изображение');
%%
[R,N]=bwlabel(C);   % Выполнить разметку (find every separate connected white object in the binary image C and give each one its own number)

R_RGB = label2rgb(R);
figure,imshow(R_RGB,[]),title('разметка')
fprintf('Общее количество зёрен = %d\n', N);

%%
myNumber = 1;
grainNumber = myNumber * 5;

grain = (R == grainNumber);
figure; imshow(grain); title(['Зерно № ', num2str(grainNumber)]);


%% Search for merged grains
stats = regionprops(R,'Area');  %calculate area.
areas = [stats.Area];

medianArea = median(areas);

merged = find(areas > 2 * medianArea);

fprintf('Возможные склеенные объекты:\n');
disp(merged);
M_all = ismember(R, merged);

figure; imshow(M_all); title('Возможные склеенные зёрна');
%% part2
clear;
close all;
clc;

%%
A1 = imread('pentagon.bmp');
% Перевод в оттенки серого
if size(A1,3) == 3
    A1 = rgb2gray(A1);
end

figure; imshow(A1);title('Эталонный пятиугольник');

P = im2bw(A1,0.5);
P = imcomplement(P);
figure; imshow(P); title('Бинаризованный эталонный пятиугольник');

Rp = CentProf(P);

figure;plot(Rp); grid on; xlabel('Угол');
ylabel('Нормированный радиус');
title('Центроидальный профиль эталонного пятиугольника');


%% ЗАГРУЗКА ИЗОБРАЖЕНИЯ С ДЕТАЛЯМИ

A2 = imread('shapes.png');
if size(A2,3) == 3
    A2 = rgb2gray(A2);
end
figure; imshow(A2); title('Исходное изображение');

%%  ФИЛЬТРАЦИЯ И БИНАРИЗАЦИЯ

A2 = medfilt2(A2);
B = im2bw(A2,0.5);
% Черные детали -> белые объекты
B = imcomplement(B);
figure; imshow(B); title('Результат бинаризации');

%% МОРФОЛОГИЧЕСКАЯ ФИЛЬТРАЦИЯ

se = ones(3,3);

B = imopen(B,se);
B = imclose(B,se);
% Удаление мелкого шума
B = bwareaopen(B,100);
figure; imshow(B); title('Результат фильтрации');

% 5 РАЗМЕТКА ОБЪЕКТОВ

[D,N] = bwlabel(B); % finds every separate connected white object.
D_RGB = label2rgb(D);

figure; imshow(D,[]); title('Разметка объектов');
fprintf('Количество объектов = %d\n',N);


Red = ones(size(B));
Green = Red;
Blue = Red;

for i = 1:N

    Q = zeros(size(B));
    Q(D == i) = 1; %finds all pixels belonging to object i, Those pixels become white in Q.

    Q1 = imcomplement(Q);

    [W,N1] = bwlabel(Q1);

    W_RGB = label2rgb(W);

    figure; subplot(2,1,1);
    imshow(Q,[]);
    title(sprintf('Объект №%d',i));

    subplot(2,1,2);
    imshow(W_RGB,[]);
    title(sprintf('Разметка инвертированного изображения №%d',i));

    fprintf('\nОбъект №%d\n',i);
    fprintf('Количество областей после инверсии = %d\n',N1);

    if N1 == 5 % background and 4 holes

        fprintf('Объект %d имеет четыре отверстия\n',i);
        % Зеленый цвет:
       
        Red = Red - Q;
        Blue = Blue - Q;
   
    elseif N1 == 1 % ОБЪЕКТ БЕЗ ОТВЕРСТИЙ

        fprintf('Объект %d не имеет отверстий\n',i);
        Ri = CentProf(Q);
        E=norm((Ri-Rp))

        fprintf('Объект %d: E = %g\n',i,E);
     
        if E < 4   % ПЯТИУГОЛЬНИК

            fprintf('Объект %d распознан как пятиугольник\n',i);
            Green = Green - Q;
            Blue = Blue - Q;

        else

            fprintf('Объект %d не является пятиугольником\n',i);

            Red = Red - Q;
            Green = Green - Q;
            Blue = Blue - Q;
        end
    else

        fprintf('Объект %d - другая деталь\n',i);
        % Черный цвет
        Red = Red - Q;
        Green = Green - Q;
        Blue = Blue - Q;

    end
end

Result = cat(3,Red,Green,Blue);
figure;imshow(Result); title('Результат распознавания');

%% =========================================================

function R = CentProf(B)

    % Граница объекта
    E = bwperim(B);

    % Координаты объекта
    [y,x] = find(B == 1);

    % Центр масс
    xc = mean(x);
    yc = mean(y);

    % Координаты границы
    [y,x] = find(E == 1);

    % Расстояния от центра
    dx = x - xc;
    dy = y - yc;

    % Радиус
    ro = sqrt(dx.^2 + dy.^2);

    % Угол
    fi = atan2d(dy,dx);

    % Перевод угла в индекс
    f = floor(fi) + 180 + 1;

    % Создание профиля
    R = zeros(360,1);

    for j = 1:length(x)
        if f(j) >= 1 && f(j) <= 360

            R(f(j)) = max(R(f(j)),ro(j));
        end
    end
    % Нормировка профиля
    R = R ./ mean(R);

end
