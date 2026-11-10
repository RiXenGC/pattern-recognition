function R=PhaseCorr(A,B)
if ndims(A)==3, A=rgb2gray(A); end
if ndims(B)==3, B=rgb2gray(B); end
[h,w]=size(A);

Sa=fft2(double(A));
Sb=fft2(double(B),h,w);
Sr=Sa.*conj(Sb);
d=abs(Sr); d(d==0)=1;
Sr=Sr./d;
R=real(ifft2(Sr));
end
