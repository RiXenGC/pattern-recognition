function R = GradCorrXY(A, B)
    % GradCorrXY — Корреляция по компонентам градиента dI/dx и dI/dy
    [h, w] = size(A);
    [Gya, Gxa] = imgradientxy(double(A), 'Sobel');
    [Gyb, Gxb] = imgradientxy(double(B), 'Sobel');
    
    Sa_x = fft2(Gxa); Sb_x = fft2(Gxb, h, w);
    Sa_y = fft2(Gya); Sb_y = fft2(Gyb, h, w);
    
    Sr = Sa_x .* conj(Sb_x) + Sa_y .* conj(Sb_y);
    R = real(ifft2(Sr));
end