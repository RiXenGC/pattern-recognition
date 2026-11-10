function R=GradCorrXY(A,B)
if ndims(A)==3, A=rgb2gray(A); end
if ndims(B)==3, B=rgb2gray(B); end
[h,w]=size(A);
[Ax,Ay]=imgradientxy(A,'Sobel');
[Bx,By]=imgradientxy(B,'Sobel');
Sr=fft2(Ax).*conj(fft2(Bx,h,w)) ...
  +fft2(Ay).*conj(fft2(By,h,w));
R=real(ifft2(Sr));
end
