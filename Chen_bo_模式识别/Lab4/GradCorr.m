function R=GradCorr(A,B)
if ndims(A)==3, A=rgb2gray(A); end
if ndims(B)==3, B=rgb2gray(B); end
[h,w]=size(A);
A=imgradient(A,'Sobel');
B=imgradient(B,'Sobel');
Sa=fft2(A);
Sb=fft2(B,h,w);
Sr=Sa.*conj(Sb);
R=real(ifft2(Sr));
end
