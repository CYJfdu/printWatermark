%% ������
clear;clc;
close all;
[filename, pathname, index] = uigetfile('*.bmp;*.jpg;*.png;*.jpeg');
test_image = im2double(imread([pathname,filename]));
n = 256;m = 256% ��Ҫ��ͼ��ָ��ĳߴ磺m*n
imshow([test_image(:,:,:)]);hold on;
for p = 1:4
    [loc_x(p),loc_y(p)] = ginput(1);
    plot(loc_x(p),loc_y(p),'r.');
end
loc_x = floor(loc_x);
loc_y = floor(loc_y);
%% ��ɸѡ�����ĸ��������������
[X,Y] = my_sort(loc_x,loc_y,test_image);
%% ��ԭͼ�����͸�ӱ任
img = imread(strcat(pathname,filename));
I = my_pres_trans(img,X,Y,m,n);
%% дͼ��
k = find(filename == '.');
pathfile=[pathname,[filename(1:k-1),'_re.png']];
imwrite(I,pathfile);

 