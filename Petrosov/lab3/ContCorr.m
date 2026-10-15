function R = ContCorr(A, B)
    % ContCorr — Контурная корреляция по бинарным границам
    [h, w] = size(A);
    Ea = double(edge(double(A), 'Sobel'));
    Eb = double(edge(double(B), 'Sobel'));
    Sa = fft2(Ea);
    Sb = fft2(Eb, h, w);
    Sr = Sa .* conj(Sb);
    R = real(ifft2(Sr));
end
