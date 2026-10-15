function [ R ] = CentProf( B )
    % B — бинарная маска одного объекта
    
    % Заполняем отверстия для корректного контура
    B_filled = imfill(B, 'holes');
    E = bwperim(B_filled);

    [y, x] = find(B_filled == 1);
    if isempty(x)
        R = zeros(360, 1);
        return;
    end
    
    xc = mean(x);
    yc = mean(y);

    [y, x] = find(E == 1);
    dx = x - xc;
    dy = y - yc;

    ro = sqrt(dx.^2 + dy.^2);
    fi = atan2d(dy, dx); 
    
    f = mod(floor(fi), 360) + 1; 

    n = length(x);
    R = zeros(360, 1);
    for i = 1:n
        R(f(i)) = max(R(f(i)), ro(i));
    end

    % Заполнение возможных пропусков (интерполяция)
    zero_idx = (R == 0);
    if any(zero_idx)
        angles = 1:360;
        R(zero_idx) = interp1(angles(~zero_idx), R(~zero_idx), angles(zero_idx), 'linear', 'extrap');
    end

    % Нормировка
    R = R ./ mean(R);
end