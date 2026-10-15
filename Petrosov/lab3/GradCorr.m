function R = GradCorr(A, B)
    % GradCorr — Корреляция модулей градиента
    [h, w] = size(A);
    Ga = imgradient(double(A), 'Sobel');
    Gb = imgradient(double(B), 'Sobel');
    Sa = fft2(Ga);
    Sb = fft2(Gb, h, w);
    Sr = Sa .* conj(Sb);
    R = real(ifft2(Sr));
end