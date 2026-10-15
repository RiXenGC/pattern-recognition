function [ H ] = FindGHT2( A, B )
    % FindGHT2 — Быстрое GHT с использованием направления градиента и закладок
    [h, w] = size(A);
    H = zeros(h, w);
    
    % 1. Находим границы и направления градиента
    Ca = edge(A, 'Sobel');
    Cb = edge(B, 'Sobel');
    
    [~, gammaA] = imgradient(A, 'Sobel');
    [~, gammaB] = imgradient(B, 'Sobel');
    
    [y, x]   = find(Ca == 1);
    [y1, x1] = find(Cb == 1);
    
    n  = length(x);
    n1 = length(x1);
    
    % 2. Собираем направления градиента в точках контура
    ga = zeros(n, 1);
    for i = 1:n,  ga(i) = gammaA(y(i), x(i)); end
    
    gb = zeros(n1, 1);
    for i = 1:n1, gb(i) = gammaB(y1(i), x1(i)); end
    
    % 3. Сортируем точки кадра по возрастанию угла градиента
    [gb, sortIdx] = sort(gb);
    x1 = x1(sortIdx);
    y1 = y1(sortIdx);
    
    % 4. Формируем массив закладок Q для 360 градусов (от -180 до +180)
    N = 360;
    Q = zeros(N + 1, 1);
    Q(1) = 1;
    
    for i = 2:N+1
        q_val = (i - 1) - 180; % Текущий угол
        idx = find(gb >= q_val, 1, 'first');
        if isempty(idx)
            Q(i) = n1 + 1;
        else
            Q(i) = idx;
        end
    end
    Q(N+1) = n1 + 1;
    
    % 5. Аккумуляция гипотез (только для близких градиентов +-5 градусов)
    eps_angle = 5;
    for i = 1:n
        f = ga(i);
        q = round(f + 181); % Перевод угла [-180..180] в индекс [1..361]
        
        q1 = max(1, q - eps_angle);
        q2 = min(360, q + eps_angle);
        
        idx_start = Q(q1);
        idx_end   = Q(q2 + 1) - 1;
        
        for j = idx_start:idx_end
            dx = x(i) - x1(j);
            dy = y(i) - y1(j);
            if (dx >= 1) && (dy >= 1) && (dx <= w) && (dy <= h)
                H(dy, dx) = H(dy, dx) + 1;
            end
        end
    end
end