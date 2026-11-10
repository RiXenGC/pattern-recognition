function R=GradCorr(A,B)
% Appendix 5: gradient magnitude correlation.
[h,w]=size(A);
Ga=imgradient(A,'Sobel');
Gb=imgradient(B,'Sobel');
Sa=fft2(Ga);
Sb=fft2(Gb,h,w);
Sr=Sa.*conj(Sb);
R=real(ifft2(Sr));
end
