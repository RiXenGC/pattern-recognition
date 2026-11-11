function [ R ] = ContCorr( A,B )
%ContCorr Считает контурную корреляционную функцию двух изображений 
[h,w]=size(A);
Ea=edge(A,'Sobel');
Eb=edge(B,'Sobel');
Sa=fft2(Ea);
Sb=fft2(Eb,h,w);
Sr=Sa.*conj(Sb);
R=ifft2(Sr);
end
