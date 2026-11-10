clear;
close all;
A=imread('pentagon.bmp');
[h,w,p]=size(A);
if p==3, A=rgb2gray(A); end
figure,imshow(A),title('Original image');

Sx=[-1 0 1;-2 0 2;-1 0 1];
Sy=Sx';

A=im2double(A);
Dx=imfilter(A,Sx,'replicate');
Dy=imfilter(A,Sy,'replicate');

figure,imshow(Dx,[]),title('Vertical edges');
figure,imshow(Dy,[]),title('Horizontal edges');

G=sqrt(Dx.^2+Dy.^2);
gamma=atan2d(Dy,Dx);
figure,imshow(imcomplement(G),[]),title('Gradient magnitude');

E=edge(A);

figure,imshow(imcomplement(E)),title('One-pixel edges');

E1=edge(A,'Sobel');
E2=edge(A,'Canny');
figure;
subplot(1,2,1),imshow(imcomplement(E1)),title('Sobel');
subplot(1,2,2),imshow(imcomplement(E2)),title('Canny');
