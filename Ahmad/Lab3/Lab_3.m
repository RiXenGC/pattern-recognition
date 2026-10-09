clear;
close all;
clc; 

%% LOAD IMAGE

A = imread('pentagon.png');
figure; imshow(A); title('Исходное изображение');

[h,w,p] = size(A);
if p == 3
    A = rgb2gray(A);
end

%% GRADIENT DIRECTION

Ad = im2double(A);

Sx = [-1 0 1;
      -2 0 2;
      -1 0 1];

Sy = Sx';
Dx = imfilter(Ad,Sx);
Dy = imfilter(Ad,Sy);
gamma = atan2d(Dy,Dx);

%% EDGE DETECTION

E = edge(A,'Sobel'); 
figure; imshow(E);
title('Собель');

E2 = edge(A,'Canny'); 
figure; imshow(imcomplement(E2));
title('Канни');

%% ORIGINAL HOUGH METHOD  y = k*x + b

KMAX = 1000;
BMAX = 1000;

kmax = 5;
bmax = 1000;

H_original = zeros(KMAX,BMAX);

tic;
for x = 1:w
    for y = 1:h
        if E(y,x) == 1
            for KI = 1:KMAX
                
                k =  (KI-1)*(2*kmax)/(KMAX-1) - kmax;
                b = -x*k + y;
                BI = round((b+bmax)*(BMAX-1)/(2*bmax) + 1);

                if (BI >= 1) &&  (BI <= BMAX)

                    H_original(KI,BI) =  H_original(KI,BI) + 1;
                end
            end
        end
    end
end

t_before = toc;

figure; Hshow = H_original';
imshow(Hshow, [0 0.3*max(Hshow(:))]);
colormap(flipud(gray(256))); title('Пространство поиска');

%% DRAW FOUR STRONGEST LINES

B4 = A;
Htemp = H_original;

for Pass = 1:4

    % Find strongest maximum
    Hmax = max(Htemp(:));
    [Kbest,Bbest] = find(Htemp == Hmax);

    Kbest = Kbest(1);
    Bbest = Bbest(1);

    kbest = (Kbest-1)*(2*kmax)/(KMAX-1) - kmax;
    bbest = (Bbest-1)*(2*bmax)/(BMAX-1) - bmax;

    for x = 1:w
        y = round(kbest*x + bbest);
        if (y >= 1) &&  (y <= h)
            B4(y,x) = 0;

        end
    end

    d = 12;
    K1 = max(Kbest-d,1);
    K2 = min(Kbest+d,KMAX);

    B1 = max(Bbest-d,1);
    B2 = min(Bbest+d,BMAX);

    Htemp(K1:K2,B1:B2) = 0;

end
figure; imshow(B4); title('Четыре наиболее выраженные линии');


%%  PART 2
% FORCE A FIFTH LINE USING ORIGINAL HOUGH SPACE

B5wrong = A;
Htemp = H_original;

for Pass = 1:5
    Hmax = max(Htemp(:));

    [Kbest,Bbest] = find(Htemp == Hmax);

    Kbest = Kbest(1);
    Bbest = Bbest(1);

    kbest = (Kbest-1)*(2*kmax)/(KMAX-1) - kmax;

    bbest = (Bbest-1)*(2*bmax)/(BMAX-1) - bmax;
    for x = 1:w

        y = round(kbest*x + bbest);
        if (y >= 1) &&  (y <= h)
            B5wrong(y,x) = 0;
        end
    end

    d = 12;

    K1 = max(Kbest-d,1);
    K2 = min(Kbest+d,KMAX);

    B1 = max(Bbest-d,1);
    B2 = min(Bbest+d,BMAX);
    Htemp(K1:K2,B1:B2) = 0;

end

figure;
imshow(B5wrong);
title(['Принудительно найденная пятая линия из исходного пространства']);


%% ORIGINAL HOUGH METHOD OPTIMIZATION
H_optimized = zeros(KMAX,BMAX);
alpha =   (2*kmax)/(KMAX-1);
beta =    (BMAX-1)/(2*bmax);
tic;
for x = 1:w

    for y = 1:h

        if E(y,x) == 1

            for KI = 1:KMAX

                k = (KI-1)*alpha - kmax;
                b = -x*k + y;

                BI = round(   (b+bmax)*beta + 1);

                if (BI >= 1) &&  (BI <= BMAX)

                    H_optimized(KI,BI) =  H_optimized(KI,BI) + 1;
                end
            end
        end
    end
end
t_after = toc;

%% RESULTS
speedup =  t_before / t_after;
improvement =  (t_before - t_after) / t_before * 100;

fprintf('\n');
fprintf('========================================\n');
fprintf('РЕЗУЛЬТАТЫ ОПТИМИЗАЦИИ\n');
fprintf('----------------------------------------\n');

fprintf('До оптимизации      = %.6f с\n', t_before);

fprintf('После оптимизации   = %.6f с\n', t_after);
fprintf('Ускорение           = %.3f x\n', speedup);
fprintf('Улучшение           = %.2f %%\n',  improvement);


%% NORMAL HOUGH TRANSFORM - TRIGONOMETRIC OPTIMIZATION

RMAX = round(sqrt(w^2 + h^2)) + 1;
FMAX = 360;

%% BEFORE OPTIMIZATION
% sin and cos are calculated inside the loop

H_before = zeros(RMAX,FMAX);

tic;
for x = 1:w
    for y = 1:h

        if E(y,x) == 1
            for FI = 1:FMAX
                rho = x*cosd(FI) + y*sind(FI);
                RI = round(rho) + 1;
                if RI >= 1 && RI <= RMAX
                    H_before(RI,FI) =   H_before(RI,FI) + 1;
                end
            end
        end
    end
end

t_trig_before = toc;


%% AFTER OPTIMIZATION
% Precalculate sine and cosine tables

phi_values = 1:FMAX;

cos_phi = cosd(phi_values);
sin_phi = sind(phi_values);

H_after = zeros(RMAX,FMAX);

tic;
for x = 1:w
    for y = 1:h

        if E(y,x) == 1

            for FI = 1:FMAX

                rho = x*cos_phi(FI) +  y*sin_phi(FI);

                RI = round(rho) + 1;

                if RI >= 1 && RI <= RMAX
                    H_after(RI,FI) =   H_after(RI,FI) + 1;
                end

            end
        end
    end
end

t_trig_after = toc;


%% PERFORMANCE RESULTS

speedup_trig = t_trig_before / t_trig_after;

improvement_trig =  (t_trig_before - t_trig_after) /  t_trig_before * 100;

fprintf('\n');
fprintf('========================================\n');
fprintf('TRIGONOMETRIC OPTIMIZATION\n');
fprintf('----------------------------------------\n');
fprintf('Before optimization = %.6f s\n', t_trig_before);
fprintf('After optimization  = %.6f s\n', t_trig_after);
fprintf('Speedup             = %.3f x\n', speedup_trig);
fprintf('Improvement         = %.2f %%\n', improvement_trig);

H_normal = H_after;
t_normal = t_trig_after;

figure;Hmax = max(H_normal(:)); imshow(-H_normal, [-0.25*Hmax 0]);
title('Пространство поиска');


%% FULL NORMAL HOUGH - BEFORE GRADIENT OPTIMIZATION

RMAX = round(sqrt(w^2+h^2)) + 1;
FMAX = 360;

phi_values = 1:FMAX;
cos_phi = cosd(phi_values);
sin_phi = sind(phi_values);

H_full = zeros(RMAX,FMAX);

tic;
for x = 1:w
    for y = 1:h

        if E(y,x) == 1
            for FI = 1:FMAX
                rho = x*cos_phi(FI) + y*sin_phi(FI);
                RI = round(rho) + 1;
                if RI >= 1 && RI <= RMAX
                    H_full(RI,FI) = H_full(RI,FI) + 1;
                end

            end
        end
    end
end
t_gradient_before = toc;
%% GRADIENT-OPTIMIZED HOUGH

H_gradient = zeros(RMAX,FMAX);
angleTolerance = 10;
tic;

for x = 1:w
    for y = 1:h

        if E(y,x) == 1

            % Gradient direction in range 0...359 degrees
            g = mod(round(gamma(y,x)),360);

            % Two possible normal directions
            centers = [g, mod(g+180,360)];

            for C = 1:2

                centerAngle = centers(C);

                % Search only within +-10 degrees
                for delta = -angleTolerance:angleTolerance
                    angle = mod(centerAngle + delta,360);

                    if angle == 0
                        FI = 360;
                    else
                        FI = angle;
                    end

                    rho = x*cos_phi(FI) + y*sin_phi(FI);

                    RI = round(rho) + 1;

                    if RI >= 1 && RI <= RMAX

                        H_gradient(RI,FI) = H_gradient(RI,FI) + 1;

                    end
                end
            end
        end
    end
end

t_gradient_after = toc;

%% GRADIENT OPTIMIZATION RESULTS

speedup_gradient =  t_gradient_before / t_gradient_after;
improvement_gradient = (t_gradient_before - t_gradient_after) / t_gradient_before * 100;

fprintf('\n');
fprintf('========================================\n');
fprintf('GRADIENT OPTIMIZATION\n');
fprintf('----------------------------------------\n');

fprintf('Before optimization = %.6f s\n',  t_gradient_before);

fprintf('After optimization  = %.6f s\n',  t_gradient_after);

fprintf('Speedup             = %.3f x\n', speedup_gradient);

fprintf('Improvement         = %.2f %%\n',  improvement_gradient);

figure; HgradMax = max(H_gradient(:));
imshow(-H_gradient, [-0.25*HgradMax 0]); title('Пространство Хафа с использованием направления градиента');
%% DETECT FIVE DISTINCT LINES

Bnormal = A;
E_remaining = E;
distanceTolerance = 3;

for Pass = 1:5

    H_pass = zeros(RMAX,FMAX);

    for x = 1:w
        for y = 1:h
            if E_remaining(y,x) == 1
                for FI = 1:FMAX
                    rho = x*cos_phi(FI) + y*sin_phi(FI);
                    RI = round(rho) + 1;
                    if (RI >= 1) && (RI <= RMAX)
                        H_pass(RI,FI) = H_pass(RI,FI) + 1;
                    end
                end
            end
        end
    end

    %% Find strongest maximum

    Hmax = max(H_pass(:));

    [Rbest,Fbest] = find(H_pass == Hmax);

    Rbest = Rbest(1);
    Fbest = Fbest(1);

    %% Convert indices to rho and phi

    rho_best = Rbest - 1;

    phi_best = phi_values(Fbest);

    ct = cosd(phi_best);
    st = sind(phi_best);

    if abs(st) > abs(ct)

        for x = 1:w

            y = round((rho_best - x*ct) / st);
            if (y >= 1) && (y <= h)
                Bnormal(y,x) = 0;
            end
        end
    else
        for y = 1:h

            x = round((rho_best - y*st) / ct);

            if (x >= 1) && (x <= w)
                Bnormal(y,x) = 0;
            end
        end
    end

    [Yedge,Xedge] = find(E_remaining);

    distances = abs(Xedge*ct + Yedge*st - rho_best);

    removeMask = distances <= distanceTolerance;

    Xremove = Xedge(removeMask);
    Yremove = Yedge(removeMask);
    removeIndex = sub2ind( size(E_remaining),  Yremove, Xremove);

    E_remaining(removeIndex) = 0;

end
figure;imshow(Bnormal);
title(['найденные линий в нормальном пространстве Хафа (\theta,\rho)']);

%% NORMAL HOUGH TRANSFORM WITH ORIGIN AT IMAGE CENTER

% Center of the image
cx = (w + 1) / 2;
cy = (h + 1) / 2;

rho_max_center = ceil(sqrt((w/2)^2 + (h/2)^2));

RMAX_center = 2*rho_max_center + 1;
FMAX_center = 360;

H_center = zeros(RMAX_center,FMAX_center);
for x = 1:w
    for y = 1:h
        if E(y,x) == 1

            % Coordinates relative to image center
            xc = x - cx;
            yc = y - cy;

            for FI = 1:FMAX_center

                rho = xc*cos_phi(FI) + yc*sin_phi(FI);

                RI = round(rho) + rho_max_center + 1;

                if RI >= 1 && RI <= RMAX_center
                    H_center(RI,FI) =   H_center(RI,FI) + 1;
                end
            end
        end
    end
end

figure; imshow(-H_center, []);
title('Пространство Хафа с началом координат в центре изображения');

speedup = t_before / t_after;
improvement = (t_before - t_after) / t_before * 100;

fprintf('РЕЗУЛЬТАТЫ ОПТИМИЗАЦИИ\n');

fprintf('До оптимизации      = %.6f с\n', t_before);
fprintf('После оптимизации   = %.6f с\n', t_after);
fprintf('Ускорение           = %.3f x\n', speedup);
fprintf('Улучшение           = %.2f %%\n', improvement);


