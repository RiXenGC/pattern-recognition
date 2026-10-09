clc;
clear;
close all;

%% part1
A = imread('ConcordOrthoPhoto.png');        
B = imread('WestConcordOrthoPhoto.png');    

figure, imshow(A, []), title('Map: ConcordOrthoPhoto');
figure,imshow(B, []), title('Frame: WestConcordOrthoPhoto');

% edge images
Ca = edge(A, 'Sobel');
Cb = edge(B, 'Sobel');

figure;
imshow(Ca),title('Map edges');
figure, imshow(Cb), title('Frame edges');

%GHT
tic;
H = FindGHT(A, B);
searchTime = toc;

fprintf('Search time: %.4f seconds\n', searchTime);

figure, imshow(H, []);
title('Пространство поиска GHT');

% maximum response
[maxResponse, linearIndex] = max(H(:));

[yMax, xMax] = ind2sub(size(H), linearIndex);
[hFrame, wFrame] = size(B);

figure, imshow(A, []);
hold on;
rectangle('Position',  [xMax, yMax, wFrame, hFrame],  'EdgeColor', 'r', 'LineWidth', 2);
plot(xMax, yMax, 'r+', 'MarkerSize', 12,   'LineWidth', 2);
title(sprintf('Обнаруженное положение кадра: x = %d, y = %d',  xMax, yMax));
hold off;

% results
fprintf('Maximum response : %d\n', maxResponse);
fprintf('Position X       : %d\n', xMax);
fprintf('Position Y       : %d\n', yMax);
fprintf('Search time      : %.4f seconds\n', searchTime);

%% part2 
A = imread('ConcordOrthoPhoto.png');       % карта
B = imread('WestConcordOrthoPhoto.png');   % кадр

% GHT с использованием направления градиента
tic;
H = FindGHT2(A,B);
searchTime = toc;

% Поиск максимального отклика
[maxResponse, index] = max(H(:));
[yMax, xMax] = ind2sub(size(H), index);

fprintf('Время поиска: %.4f с\n\n', searchTime);
fprintf('Максимальный отклик Хафа = %d\n', maxResponse);
fprintf('Найденное смещение:\n');
fprintf('dx = %d\n', xMax);
fprintf('dy = %d\n', yMax);

% Пространство поиска
figure;
imshow(H,[]);
title('Пространство поиска GHT');

[hFrame,wFrame] = size(B);

figure;
imshow(A,[]);
hold on;

rectangle('Position',[xMax yMax wFrame hFrame], 'EdgeColor','r',  'LineWidth',2);
title(sprintf('Обнаруженное положение кадра: x = %d, y = %d - GHT с использованием направления градиента',   xMax,yMax));

hold off;
%% part3 
A = imread('ConcordOrthoPhoto.png');        
B = imread('WestConcordOrthoPhoto.png');   

R = FindGHT2(A,B);

[~,index] = max(R(:));
[yTrue,xTrue] = ind2sub(size(R),index);

fprintf('Правильное положение:\n');
fprintf('x = %d, y = %d\n\n',xTrue,yTrue);


%% ============================================================
% 1. ИССЛЕДОВАНИЕ ВЛИЯНИЯ ПОВОРОТА

angles = -20:1:20;

errorRotation = zeros(size(angles));
errorRotationFiltered = zeros(size(angles));

for k = 1:length(angles)

    angle = angles(k);

    % Поворот кадра
    Brot = imrotate(B,angle,'bilinear','crop');

  
    R = FindGHT2(A,Brot);
    [~,index] = max(R(:));
    [yFound,xFound] = ind2sub(size(R),index);
    errorRotation(k) = sqrt( (xFound-xTrue)^2 + (yFound-yTrue)^2 );

    R1 = imfilter(R,ones(7));

    [~,index] = max(R1(:));
    [yFound,xFound] = ind2sub(size(R1),index);

    errorRotationFiltered(k) = sqrt(  (xFound-xTrue)^2 + (yFound-yTrue)^2 );

end

figure,plot(angles,errorRotation,'o-','LineWidth',1.5);
hold on;
plot(angles,errorRotationFiltered,'s-','LineWidth',1.5);
grid on;
xlabel('Угол поворота, градусы');
ylabel('Ошибка положения, пиксели');
title('Зависимость ошибки положения от угла поворота');
legend('ОПХ',  'ОПХ после усреднения R1 = imfilter(R,ones(7))', 'Location','best');

%% ============================================================
% 2. ИССЛЕДОВАНИЕ ВЛИЯНИЯ МАСШТАБА

scales = 0.80:0.02:1.20;
errorScale = zeros(size(scales));
errorScaleFiltered = zeros(size(scales));

[hB,wB] = size(B);
for k = 1:length(scales)

    scale = scales(k);
    Bscaled= imresize(B,scale);
    R = FindGHT2(A,Bscaled);
    [~,index] = max(R(:));
    [yFound,xFound] = ind2sub(size(R),index);
    errorScale(k) = sqrt(   (xFound-xTrue)^2 +   (yFound-yTrue)^2 );
  
    R1 = imfilter(R,ones(7));
    [~,index] = max(R1(:));
    [yFound,xFound] = ind2sub(size(R1),index);

    errorScaleFiltered(k) = sqrt(  (xFound-xTrue)^2 +  (yFound-yTrue)^2 );

end

figure, plot(scales,errorScale,'o-','LineWidth',1.5);
hold on;
plot(scales,errorScaleFiltered,'s-','LineWidth',1.5);
grid on;
xlabel('Коэффициент масштаба');
ylabel('Ошибка положения, пиксели');
title('Зависимость ошибки положения от масштаба');
legend('ОПХ', 'ОПХ после усреднения R1 = imfilter(R,ones(7))',  'Location','best');


%% ============================================================
% 3. ИССЛЕДОВАНИЕ ВЛИЯНИЯ ШУМА

noiseLevels = 0:0.05:1.0;
errorNoise = zeros(size(noiseLevels));
errorNoiseFiltered = zeros(size(noiseLevels));

Bd = im2double(B);

for k = 1:length(noiseLevels)

    sigma = noiseLevels(k);

    if sigma == 0
        Bnoise = Bd;
    else
        Bnoise = imnoise(Bd,'gaussian',0,sigma^2);
    end

    R = FindGHT2(A,Bnoise);

    [~,index] = max(R(:));
    [yFound,xFound] = ind2sub(size(R),index);

    errorNoise(k) = sqrt((xFound-xTrue)^2 + (yFound-yTrue)^2);

    R1 = imfilter(R,ones(7));

    [~,index] = max(R1(:));
    [yFound,xFound] = ind2sub(size(R1),index);

    errorNoiseFiltered(k) = sqrt((xFound-xTrue)^2 + (yFound-yTrue)^2);

end

figure;
plot(noiseLevels,errorNoise,'o-','LineWidth',1.5);
hold on;
plot(noiseLevels,errorNoiseFiltered,'s-','LineWidth',1.5);
grid on;
xlabel('Уровень шума');
ylabel('Ошибка положения, пиксели');
title('Зависимость ошибки положения от уровня шума');
legend('ОПХ', 'ОПХ после усреднения R1 = imfilter(R,ones(7))', 'Location','best');

Ecrit = 20;

fprintf('\n===== КРИТИЧЕСКИЕ ЗНАЧЕНИЯ =====\n');

idx = find(angles >= 0 & errorRotation > Ecrit, 1, 'first');
if ~isempty(idx)
    fprintf('Критический положительный угол: %.1f°\n', angles(idx));
else
    fprintf('Критический положительный угол не достигнут\n');
end

idx = find(angles <= 0 & errorRotation > Ecrit, 1, 'last');
if ~isempty(idx)
    fprintf('Критический отрицательный угол: %.1f°\n', angles(idx));
else
    fprintf('Критический отрицательный угол не достигнут\n');
end

idx = find(scales >= 1 & errorScale > Ecrit, 1, 'first');
if ~isempty(idx)
    fprintf('Критический масштаб при увеличении: %.2f\n', scales(idx));
else
    fprintf('Критический масштаб при увеличении не достигнут\n');
end

idx = find(scales <= 1 & errorScale > Ecrit, 1, 'last');
if ~isempty(idx)
    fprintf('Критический масштаб при уменьшении: %.2f\n', scales(idx));
else
    fprintf('Критический масштаб при уменьшении не достигнут\n');
end

idx = find(errorNoise > Ecrit, 1, 'first');
if ~isempty(idx)
    fprintf('Критический уровень шума: %.2f\n', noiseLevels(idx));
else
    fprintf('Критический уровень шума не достигнут\n');
end


