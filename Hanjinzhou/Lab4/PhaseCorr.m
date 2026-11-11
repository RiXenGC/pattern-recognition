function [ R ] = PhaseCorr( A,B )
%PhaseCorr Считает фазовую корреляционную функцию двух изображений 
%спектральным методом
[h,w]=size(A);
Sa=fft2(A);
Sb=fft2(B,h,w);
Sr=Sa.*conj(Sb);
Sr=Sr./abs(Sr); %Оставляем только фазу спектра
R=ifft2(Sr);
end