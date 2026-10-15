function R = FindCorr(A, B)
    % FindCorr — Спектральная корреляция по яркости
    [h, w] = size(A);
    Sa = fft2(double(A));
    Sb = fft2(double(B), h, w);
    Sr = Sa .* conj(Sb);
    R = real(ifft2(Sr));
end