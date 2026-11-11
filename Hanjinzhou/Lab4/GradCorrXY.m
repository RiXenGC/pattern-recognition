function [ R ] = GradCorrXY( A,B )
%GradCorrXY Считает корреляционную функцию двух изображений 
%спектральным методом по компонентам вектора градиента
[h,w]=size(A);
[Gya,Gxa]=imgradientxy(A,'Sobel');
[Gyb,Gxb]=imgradientxy(B,'Sobel');
Sa=fft2(Gxa);
Sb=fft2(Gxb,h,w);
Sr=Sa.*conj(Sb);
Sa=fft2(Gya);
Sb=fft2(Gyb,h,w);
Sr=Sr+Sa.*conj(Sb);
R=ifft2(Sr);
end