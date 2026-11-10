function R=GradCorrXY(A,B)
% Appendix 6: gradient component correlation.
[h,w]=size(A);
[Gxa,Gya]=imgradientxy(A,'Sobel');
[Gxb,Gyb]=imgradientxy(B,'Sobel');
Sa=fft2(Gxa);
Sb=fft2(Gxb,h,w);
Sr=Sa.*conj(Sb);
Sa=fft2(Gya);
Sb=fft2(Gyb,h,w);
Sr=Sr+Sa.*conj(Sb);
R=real(ifft2(Sr));
end
