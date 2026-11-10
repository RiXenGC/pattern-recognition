function R=PhaseCorr(A,B)
% Appendix 4: phase correlation.
[h,w]=size(A);
Sa=fft2(double(A));
Sb=fft2(double(B),h,w);
Sr=Sa.*conj(Sb);
D=abs(Sr);
D(D==0)=1;
Sr=Sr./D;
R=real(ifft2(Sr));
end
