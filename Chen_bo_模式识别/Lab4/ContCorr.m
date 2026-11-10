function R=ContCorr(A,B)
if ndims(A)==3, A=rgb2gray(A); end
if ndims(B)==3, B=rgb2gray(B); end
[h,w]=size(A);
A=edge(A,'Sobel');
B=edge(B,'Sobel');
Sa=fft2(double(A));
Sb=fft2(double(B),h,w);
Sr=Sa.*conj(Sb);
R=real(ifft2(Sr));
end
