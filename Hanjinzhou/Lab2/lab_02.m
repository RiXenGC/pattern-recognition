clear;
close all;
A = imread('rice.png');
figure,imshow(A),title('原图');

% 灰度图直方图，纵轴为频率，横轴为灰度值（0-255）
figure,plot(imhist(A));
% 基于阈值将灰度图
B = im2bw(A, 122/255);
figure,imshow(B),title('阈值二值化');

% Otsu二值化：使类间反差最大，类内方差最小
L = graythresh(A);
C = im2bw(A, L);
figure,imshow(C),title('Otsu二值化');

% 分区二值化
A1 = A(1:180,:);
A2 = A(181:end,:);
L1 = graythresh(A1);
L2 = graythresh(A2);
B1 = im2bw(A1, L1);
B2 = im2bw(A2, L2);
D = zeros(size(A));
D(1:180,:) = B1;
D(181:end,:) = B2;
figure,imshow(D),title('分区做Otsu二值化');

% 滤波
E = medfilt2(D);
se = ones(5, 5);
E = imopen(E, se); figure, imshow(E), title("3*3 open");
E = imclose(E, se); figure, imshow(E), title("3*3 close");

% 标记并找出特定编号的米粒
% se = ones(3,3);
% D = imerode(D, se);
D1 = bwareaopen(D, 5);
imshowpair(D,D1,'montage');
D = D1;
[F, n] = bwlabel(D);
figure,imshow(F,[]),title('标记');
F2 = zeros(size(F));
F2(find(F==4*5))=1;
figure,imshow(F2,[]),title('标记==4*5');


% 1. 找黏在一起的米粒
G = bwperim(D);
figure,imshow(G),title('边界');
H = bwmorph(D,'skel',Inf);
figure,imshow(H),title('骨架');

% 2. 统计每个区域的骨架长度 / Длина скелета каждой компоненты
% 在原二值图D上编号，保持骨架与原米粒区域的对应关系。
% Нумеруем компоненты D, чтобы связать скелет с исходным объектом.
riceRegions = bwconncomp(D, 8);
regionCount = riceRegions.NumObjects;
assert(regionCount > 0, 'D contains no foreground rice regions.');

riceProperties = regionprops(riceRegions, 'BoundingBox', 'Centroid');
skeletonLength = zeros(regionCount, 1);

for regionIndex = 1:regionCount
    % 取当前区域内的像素位置，统计其中属于骨架的像素数。
    % Берём пиксели текущего объекта и считаем среди них пиксели скелета.
    pixelIndices = riceRegions.PixelIdxList{regionIndex};
    skeletonLength(regionIndex) = nnz(H(pixelIndices));
end

% 3. 筛选明显偏长的区域 / Отбор заметно длинных объектов
% 阈值为平均值加k倍标准差；减小k会筛选出更多区域。
% Порог равен среднему плюс k стандартных отклонений; меньше k — больше объектов.
outlierFactor = 2;
meanLength = mean(skeletonLength);
stdLength = std(skeletonLength);
lengthThreshold = meanLength + outlierFactor * stdLength;

isLong = skeletonLength > lengthThreshold;
longLabels = find(isLong);

% 在工作区保存统计表，并显示偏长区域的编号和长度。
% Сохраняем таблицу и выводим номера и длины выделенных объектов.
lengthTable = table((1:regionCount)', skeletonLength, isLong, ...
    'VariableNames', {'RegionID', 'SkeletonPixels', 'IsLong'});
disp(lengthTable(isLong, :));

% 4. 绘制长度分布直方图 / Гистограмма длин
% 每个连通区域贡献一个样本；蓝线为平均值，红线为筛选阈值。
% Каждая компонента даёт один образец; синяя линия — среднее, красная — порог.
figure;
histogram(skeletonLength, 'BinMethod', 'integers');
hold on;
xline(meanLength, 'b--', 'Mean', 'LineWidth', 1.5);
xline(lengthThreshold, 'r--', 'Mean + k*SD', 'LineWidth', 1.5);
hold off;
xlabel('骨架像素数 / Число пикселей скелета');
ylabel('区域数量 / Число объектов');
title('骨架长度分布 / Распределение длин скелета');
grid on;

% 5. 标注偏长区域 / Выделение длинных объектов
% 红框标出区域，黄色文字显示区域编号和骨架像素数。
% Красная рамка выделяет объект; жёлтая подпись показывает номер и длину.
figure;
imshow(D);
hold on;

for regionIndex = longLabels'
    rectangle('Position', riceProperties(regionIndex).BoundingBox, ...
        'EdgeColor', 'r', 'LineWidth', 1.5);

    center = riceProperties(regionIndex).Centroid;
    text(center(1), center(2), ...
        sprintf('#%d: %d px', regionIndex, skeletonLength(regionIndex)), ...
        'Color', 'y', 'FontSize', 9, 'FontWeight', 'bold');
end

hold off;
title(sprintf('偏长区域 / Длинные объекты: %d', numel(longLabels)));

%% 作业2
clear;
close all;

A = imread('print.png');A = rgb2gray(A);
A = imcomplement(A);
figure,imshow(A),title('原图');

[labels, N] = bwlabel(A);
figure,imshow(labels,[]);
B = zeros(size(A));
B(find(labels==1))=1;
figure,imshow(B,[]),title('标记==1');

[y, x] = find(labels == 1);
yc = mean(y);
xc = mean(x);
A(round(yc), round(xc)) = 0;
figure,imshow(A),title("质心");

C = bwperim(B);
[y, x] = find(C==1);
figure,imshow(C),title("边框");
dx = x - xc;
dy = y - yc;
ro = sqrt(dx.^2 + dy.^2);
fi = atan2d(dy, dx);
f = floor(fi) + 180 + 1;
n = length(x);
R = zeros(360, 1);
for i = 1:n
    R(f(i))=max(R(f(i)), ro(i));
end
figure,plot(R),title('质心轮廓');
R = R./mean(R);
figure,bar(R),title("归一化质心轮廓");

% B = zeros(size(A));
% B(find(labels==3))=1;
% figure,imshow(B,[]),title('标记==3');
% R = CentProf(B);
% figure,bar(R),title("归一化质心轮廓");

% 2. 设置识别条件 / Параметры распознавания
% 这些容差允许绘图误差和像素锯齿，适用于当前实验图像。
% Допуски учитывают погрешности рисунка и растровые ступеньки.

minimumPeakHeight = 1.035;
minimumPeakSpacing = 30;
maximumAngleError = 10;
maximumHeightCV = 0.08;
minimumSolidity = 0.97;

% 每个标签只有一个连通区域，所以孔数等于1减去欧拉数。
% Каждая метка содержит одну компоненту, поэтому число отверстий равно 1 минус число Эйлера.
properties = regionprops(labels, 'EulerNumber');
holeCounts = 1 - [properties.EulerNumber]';
objectCount = N
grayImage = A;
peakCounts = zeros(objectCount, 1);
angleErrors = inf(objectCount, 1);
heightCVs = inf(objectCount, 1);
isPentagon = false(objectCount, 1);


% 3. 计算各物品的外轮廓特征 / Признаки внешнего контура
for objectIndex = 1:objectCount

    % 提取当前物品，不依赖预先指定的标签编号。
    % Выделяем текущий предмет без заранее заданного номера.
    objectMask = labels == objectIndex;

    % 填孔副本仅用于外形分析；原始掩膜和孔数保持不变。
    % Заполненная копия нужна только для формы; исходная маска и число отверстий сохраняются.
    filledMask = imfill(objectMask, 'holes');
    shape = regionprops(filledMask, 'Centroid', 'Solidity');

    xc = shape.Centroid(1);
    yc = shape.Centroid(2);

    % 提取填孔后的外边界，计算边界点到质心的距离。
    % Находим внешнюю границу и расстояния её точек до центра.
    boundaryMask = bwperim(filledMask, 8);
    [y, x] = find(boundaryMask);
    radii = hypot(x - xc, y - yc);

    % 将角度转换到[0,360)，对应下标1至360，避免出现下标361。
    % Переводим углы в [0,360), затем в индексы от 1 до 360.
    angleBins = floor(mod(atan2d(y - yc, x - xc), 360)) + 1;

    % 每个角度保留最远边界点，缺失角度先用NaN表示。
    % Для каждого угла сохраняем самый дальний радиус; пропуски обозначаем NaN.
    R = nan(360, 1);

    for pointIndex = 1:numel(radii)
        binIndex = angleBins(pointIndex);

        if isnan(R(binIndex)) || radii(pointIndex) > R(binIndex)
            R(binIndex) = radii(pointIndex);
        end
    end

    % 缺失角度不是零半径；利用周期插值补齐。
    % Пропущенный угол не означает нулевой радиус; заполняем его периодической интерполяцией.
    knownBins = find(~isnan(R));

    % 边界采样过少时，无法可靠判断外形，跳过五边形识别。
    % При слишком малом числе образцов пропускаем распознавание пятиугольника.
    if numel(knownBins) < 3
        continue;
    end

    R = interp1( ...
        [knownBins - 360; knownBins; knownBins + 360], ...
        [R(knownBins); R(knownBins); R(knownBins)], ...
        (1:360)', 'linear');

    % 环形15点平均减少像素锯齿；除以平均半径消除尺度影响。
    % Круговое среднее по 15 точкам уменьшает шум; нормировка убирает масштаб.
    R = conv( ...
        [R(end-6:end); R; R(1:7)], ...
        ones(15, 1) / 15, 'valid');

    R = R / mean(R);

    % 寻找明显的局部峰，比较时包含359度与0度之间的接缝。
    % Ищем выраженные локальные пики, учитывая стык между 359 и 0 градусами.
    peakMask = R > circshift(R, 1) ...
        & R >= circshift(R, -1) ...
        & R > minimumPeakHeight;

    candidates = find(peakMask);

    % 一个顶角可能产生多个邻近小峰，优先保留较高峰。
    % Одна вершина может давать несколько близких пиков; предпочитаем более высокий.
    [~, heightOrder] = sort(R(candidates), 'descend');
    peaks = zeros(0, 1);

    for candidateIndex = heightOrder'
        candidate = candidates(candidateIndex);

        % 用环形角距离判断两个峰是否太近。
        % Проверяем близость пиков по круговому угловому расстоянию.
        distance = abs(peaks - candidate);
        distance = min(distance, 360 - distance);

        if all(distance > minimumPeakSpacing)
            peaks(end + 1, 1) = candidate;
        end
    end

    peaks = sort(peaks);
    peakCounts(objectIndex) = numel(peaks);

    % 正五边形应有5个主峰，角间距约72度，峰高接近，外形近似凸形。
    % Правильный пятиугольник имеет 5 пиков с шагом около 72 градусов,
    % близкой высотой и почти выпуклым внешним контуром.
    if numel(peaks) == 5

        % 加入最后一个峰到第一个峰的间隔，形成完整圆周。
        % Добавляем интервал от последнего пика до первого через конец круга.
        angleGaps = diff([peaks; peaks(1) + 360]);

        angleErrors(objectIndex) = max(abs(angleGaps - 72));
        heightCVs(objectIndex) = std(R(peaks)) / mean(R(peaks));

        isPentagon(objectIndex) = ...
            angleErrors(objectIndex) < maximumAngleError ...
            && heightCVs(objectIndex) < maximumHeightCV ...
            && shape.Solidity > minimumSolidity;
    end
end


% 4. 根据孔数识别四孔物品 / Распознавание четырёх отверстий
% 孔数是独立特征，不根据质心轮廓的峰数判断。
% Число отверстий — независимый признак; оно не равно числу пиков профиля.
isFourHole = holeCounts == 4;

% 将识别出的标签转换为与原图大小相同的逻辑掩膜。
% Преобразуем выбранные метки в логические маски размера исходного изображения.
pentagonMask = ismember(labels, find(isPentagon & (holeCounts == 0)));
fourHoleMask = ismember(labels, find(isFourHole));


% 5. 分别填为红色和绿色 / Окрашивание в красный и зелёный
% 从原灰度图建立RGB图，保留未识别物品、背景和孔洞。
% Создаём RGB-изображение, сохраняя остальные предметы, фон и отверстия.
red = grayImage;
green = grayImage;
blue = grayImage;

% 近似五边形的原始前景像素设为红色：[255,0,0]。
% Пиксели пятиугольников окрашиваем в красный: [255,0,0].
red(pentagonMask) = 255;
green(pentagonMask) = 0;
blue(pentagonMask) = 0;

% 四孔物品的原始前景像素设为绿色：[0,255,0]。
% Пиксели предметов с четырьмя отверстиями окрашиваем в зелёный: [0,255,0].
% 若某物品同时符合两类，则绿色优先。
% Если предмет соответствует обоим признакам, зелёный имеет приоритет.
red(fourHoleMask) = 0;
green(fourHoleMask) = 255;
blue(fourHoleMask) = 0;

coloredImage = cat(3, red, green, blue);

figure;
imshow(coloredImage);
title('五边形：红色；四孔物品：绿色 / Пятиугольник: красный; 4 отверстия: зелёный');


% 6. 显示统计并保存结果 / Таблица и сохранение
% 表中列出区域编号、孔数、主峰数以及两类识别结果。
% Таблица содержит номер, число отверстий, число пиков и результаты распознавания.
resultTable = table( ...
    (1:objectCount)', holeCounts, peakCounts, isPentagon, isFourHole, ...
    'VariableNames', {'Label', 'Holes', 'Peaks', 'Pentagon', 'FourHoles'});

disp(resultTable);




