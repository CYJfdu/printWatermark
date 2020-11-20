function [ dNC] = NCC( ImageA,ImageB )
%UNTITLED5 此处显示有关此函数的摘要
%   此处显示详细说明
d1=0;
d2=0;
d3=0;
[M,N]=size(ImageA);
% meanA=mean(mean(ImageA));
% meanB=mean(mean(ImageB));
for i = 1:M
    for j = 1:N
%         d1=d1+(ImageA(i,j)-meanA)*(ImageB(i,j)-meanB) ;
%         d2=d2+(ImageA(i,j)-meanA)*(ImageA(i,j)-meanA) ;
%         d3=d3+(ImageB(i,j)-meanB)*(ImageB(i,j)-meanB) ;
        d1=d1+ImageA(i,j)*ImageB(i,j) ;
        d2=d2+ImageA(i,j)*ImageA(i,j) ;
        d3=d3+ImageB(i,j)*ImageB(i,j);
    end
end
dNC=d1/(sqrt(d2)*sqrt(d3));
end

