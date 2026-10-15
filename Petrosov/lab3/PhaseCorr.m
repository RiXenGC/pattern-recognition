function R = PhaseCorr(A, B)
    % PhaseCorr — Фазовая корреляция (нормализация модуля кросс-спектра)
    [h, w] = size(A);
    Sa = fft2(double(A));
    Sb = fft2(double(B), h, w);
    Sr = Sa .* conj(Sb);
    eps_val = 1e-10; % Защита от деления на ноль
    Sr = Sr ./ (abs(Sr) + eps_val); % Оставляем только фазу
    R = real(ifft2(Sr));
end