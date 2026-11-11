%% 作业一 边界搜索
clc;
clear all;
A = imread('print.png');
B = ~rgb2gray(A);
figure, imshowpair(A, B, "montage"), title("原图与反转后的灰度图");

% sobel掩膜
Sx = [-1 0 1;-2 0 2;-1 0 1];
Sy = Sx';
B = im2double(B);
Dx = imfilter(B, Sx);
Dy = imfilter(B, Sy);
figure, imshowpair(Dx, Dy, "montage"), title("沿x和y求导");

% 灰度梯度向量
G_mod = sqrt(Dx.^2 + Dy.^2);
G_phase = atan2d(Dx, Dy);
figure, imshowpair(G_mod, G_phase, "montage"), title("灰度梯度向量的模值和相位");

% 缩小边界宽度
E = edge(B);
figure, imshow(E), title("缩小后边界宽度");

%% 作业二 霍夫变换做直线搜索
clc;
clear all;
A = imread('print.png');
[h, w, p] = size(A);
B = rgb2gray(A);
E = edge(B);
KMAX = 1000;
BMAX = 1000;
H = zeros(KMAX, BMAX);
kmax = 5;
bmax = 1000;

% 将参数k、b转换为矩阵H的索引KI、BI，并实现反向转化
% 霍夫变换
for x = 1: w
    for y = 1:h
        if E(y, x) == 1
            for KI = 1:KMAX
                k = (KI-1)*(2*kmax)/(KMAX-1)-kmax;
                b = -x*k+y;
                BI = round((b+bmax)*(BMAX-1)/(2*bmax)+1);
                if (BI>=1)&&(BI<=BMAX)
                    H(KI,BI) = H(KI,BI) + 1;
                end
            end
        end
    end
end
figure,imshow(-H,[]),title('搜索空间/Пространство поиска');

C = B;
for Pass = 1:4
    Hbest = max(H(:));
    [KIbest, BIbest] = find(H==Hbest);
    KIbest = KIbest(1);
    BIbest = BIbest(1);
    kbest = (KIbest-1)*(2*kmax)/(KMAX-1) - kmax;
    bbest = (BIbest-1)*(2*bmax)/(BMAX-1) - bmax;

    % 绘制直线
    for x=1:w
        y = round(kbest*x + bbest);
        if (y>=1) && (y<=h)
            C(y, x) = 0;
        end
    end

    d = 5;
    H(KIbest-d:KIbest+d, BIbest-d:BIbest+d) = 0;
end
figure, imshow(C), title('找到的直线/Найденные прямые');

% 标准形式直线检测
RMAX = round(sqrt(w^2 + h^2)) +1;
FMAX = 360;
H = zeros(RMAX, FMAX);

% 霍夫变换至标准形式
for  x = 1:w
    for y = 1:h
        if E(y, x) == 1
            for f=1:360
                ro = x*cosd(f)+y*sind(f);
                R = round(ro) + 1;
                if (R>=1)&&(R<=RMAX)
                    H(R, f) = H(R, f) + 1;
                end
            end
        end
    end
end
figure,imshow(-H,[]),title('标准形式搜索空间/Пространство поиска');

D = B;
for pass=1:5
    Hmax = max(H(:));
    [Rbest, Fbest] = find(H==Hmax);
    Rbest = Rbest(1);
    Fbest = Fbest(1);
    ro = Rbest-1;

    if abs(sind(Fbest)) > 1/sqrt(2)
        for x=1:w
            y = (ro-x*cosd(Fbest))/sind(Fbest);
            y = round(y);
            if (y>=1)&&(y<=h)
                D(y, x)=0;
            end
        end
    else
        for y = 1:h
            x = (ro-y*sind(Fbest))/cosd(Fbest);
            x = round(x);
            if (x>=1)&&(x<=h)
                D(y, x) = 0;
            end
        end
    end

    d = 5;
    H(Rbest-d:Rbest+d, Fbest-d:Fbest+d)=0;
end
figure,imshow(D),title('直线/Найденные прямые');

% 线段检测
H = zeros(RMAX, FMAX);
Xmin = H+w;
Ymin = H+h;
Xmax = H;
Ymax = H;


% 霍夫变换至标准形式
for  x = 1:w
    for y = 1:h
        if E(y, x) == 1
            for f=1:360
                ro = x*cosd(f)+y*sind(f);
                R = round(ro) + 1;
                if (R>=1)&&(R<=RMAX)
                    H(R, f) = H(R, f) + 1;
                    % 添加极坐标搜索功能
                    Xmin(R, f) = min(x, Xmin(R,f));
                    Xmax(R, f) = max(x, Xmax(R,f));
                    Ymin(R, f) = min(y, Ymin(R,f));
                    Ymax(R, f) = max(y, Ymax(R,f));
                end
            end
        end
    end
end
figure,imshow(-H,[]),title('标准形式搜索空间/Пространство поиска');

F = zeros(size(A)) + 255;
for pass=1:5
    Hmax = max(H(:));
    [Rbest, Fbest] = find(H==Hmax);
    Rbest = Rbest(1);
    Fbest = Fbest(1);
    ro = Rbest-1;

    if abs(sind(Fbest)) > 1/sqrt(2)
        for x=Xmin(Rbest, Fbest):Xmax(Rbest, Fbest)
            y = (ro-x*cosd(Fbest))/sind(Fbest);
            y = round(y);
            if (y>=1)&&(y<=h)
                F(y, x)=0;
            end
        end
    else
        for y = Ymin(Rbest, Fbest):Ymax(Rbest, Fbest)
            x = (ro-y*sind(Fbest))/cosd(Fbest);
            x = round(x);
            if (x>=1)&&(x<=h)
                F(y, x) = 0;
            end
        end
    end

    d = 5;
    H(Rbest-d:Rbest+d, Fbest-d:Fbest+d)=0;
end

figure,imshow(F),title('线段/Найденные отрезки');

F = unit8(F);
R = bitor(B, imcomplement(F));
G = bitand(B, F);
F = bitand(B, F);
F_rgb = cat(3, R, G, B);
figure,imshow(F_rgb),figure,imshow(B),title('线段/Найденные отрезки');

%% 自主学习
clc;
clear all;

A = imread('print.png');
B = rgb2gray(A);
E1 = edge(B, 'Sobel');
E2 = edge(B, 'Canny');
figure, imshowpair(E1, E2, "montage"), title('Sobel vs Canny');

%% 原点移动到中心
clc;
clear all;
A = imread('print.png');
[h, w, p] = size(A);
B = rgb2gray(A);
E = edge(B);
KMAX = 1000;
BMAX = 1000;
H = zeros(KMAX, BMAX);
kmax = 5;
bmax = 1000;

xc = (w+1)/2;
yc = (h+1)/2;
% 将参数k、b转换为矩阵H的索引KI、BI，并实现反向转化
% 霍夫变换
for x = 1: w
    for y = 1:h
        if E(y, x) == 1
            x1 = x - xc;
            y1 = y - yc;
            for KI = 1:KMAX
                k = (KI-1)*(2*kmax)/(KMAX-1)-kmax;
                b = -x1*k+y1;
                BI = round((b+bmax)*(BMAX-1)/(2*bmax)+1);
                if (BI>=1)&&(BI<=BMAX)
                    H(KI,BI) = H(KI,BI) + 1;
                end
            end
        end
    end
end
figure,imshow(-H,[]),title('搜索空间/Пространство поиска');

C = B;
for Pass = 1:4
    Hbest = max(H(:));
    [KIbest, BIbest] = find(H==Hbest);
    KIbest = KIbest(1);
    BIbest = BIbest(1);
    kbest = (KIbest-1)*(2*kmax)/(KMAX-1) - kmax;
    bbest = (BIbest-1)*(2*bmax)/(BMAX-1) - bmax;

    % 绘制直线
    for x=1:w
        y = round(kbest*(x - xc) + bbest + yc);
        if (y>=1) && (y<=h)
            C(y, x) = 0;
        end
    end

    d = 5;
    H(KIbest-d:KIbest+d, BIbest-d:BIbest+d) = 0;
end
figure, imshow(C), title('找到的直线/Найденные прямые');

% 标准形式直线检测
RMAX = round(sqrt(w^2 + h^2)) +1;
FMAX = 360;
H = zeros(RMAX, FMAX);

% 霍夫变换至标准形式
for  x = 1:w
    for y = 1:h
        if E(y, x) == 1
            x1 = x - xc;
            y1 = y - yc;
            for f=1:360
                ro = x1*cosd(f)+y1*sind(f);
                R = round(ro) + 1;
                if (R>=1)&&(R<=RMAX)
                    H(R, f) = H(R, f) + 1;
                end
            end
        end
    end
end
figure,imshow(-H,[]),title('标准形式搜索空间/Пространство поиска');

D = B;
for pass=1:5
    Hmax = max(H(:));
    [Rbest, Fbest] = find(H==Hmax);
    Rbest = Rbest(1);
    Fbest = Fbest(1);
    ro = Rbest-1;

    if abs(sind(Fbest)) > 1/sqrt(2)
        for x=1:w
            y = (ro-(x - xc)*cosd(Fbest))/sind(Fbest);
            y = round(y + yc);
            if (y>=1)&&(y<=h)
                D(y, x)=0;
            end
        end
    else
        for y = 1:h
            x = (ro-(y - yc)*sind(Fbest))/cosd(Fbest);
            x = round(x + xc);
            if (x>=1)&&(x<=w)
                D(y, x) = 0;
            end
        end
    end

    d = 5;
    H(Rbest-d:Rbest+d, Fbest-d:Fbest+d)=0;
end
figure,imshow(D),title('直线/Найденные прямые');