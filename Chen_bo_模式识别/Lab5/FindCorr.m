function R=FindCorr(A,B)
% Appendix 3: spectral intensity correlation.
[h,w]=size(A);
Sa=fft2(double(A));
Sb=fft2(double(B),h,w);
Sr=Sa.*conj(Sb);
R=real(ifft2(Sr));
end
