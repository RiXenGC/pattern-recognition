function R=ContCorr(A,B)
% Appendix 7: contour correlation.
[h,w]=size(A);
Ea=edge(A,'Sobel');
Eb=edge(B,'Sobel');
Sa=fft2(Ea);
Sb=fft2(Eb,h,w);
Sr=Sa.*conj(Sb);
R=real(ifft2(Sr));
end
