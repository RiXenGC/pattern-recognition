function [ R ] = GradCorr( A,B )
%GradCorr Считает градиентную корреляционную функцию двух изображений 
%спектральным методом
[h,w]=size(A);
Ga=imgradient(A,'Sobel');
Gb=imgradient(B,'Sobel');
Sa=fft2(Ga);
Sb=fft2(Gb,h,w);
Sr=Sa.*conj(Sb);
R=ifft2(Sr);