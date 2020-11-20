function [I_cov] = Embed(w,I,alpha )
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
%生成随机噪声
%w1
block=2;
blocksize=8;
for key=1:5
rand('seed',key);
W(:,:,key)=rand(blocksize,blocksize);
end
W(W>0.66)=3;
W(W>0.33&W<=0.66)=2;
W(W<=0.33)=1;
W1=zeros(8,8,3,5);
for k=1:5
for i=1:blocksize
    for j=1:blocksize
        WW((i-1)*block+1:i*block,(j-1)*block+1:j*block,k)=W(i,j,k)*ones(block,block);
        W1(i,j,W(i,j),k)=1;
    end
end
end

w1=zeros(blocksize*block,blocksize*block,3,5);
for k=1:5
for i=1:blocksize*block
    for j=1:blocksize*block
        w1(i,j,WW(i,j),k)=255*alpha;
    end
end
end
%w0

blocksize=8;
for key=6:10
rand('seed',key);
W(:,:,key-5)=rand(blocksize,blocksize);
end
W(W>0.66)=3;
W(W>0.33&W<=0.66)=2;
W(W<=0.33)=1;
W0=zeros(8,8,3,5);
for k=1:5
for i=1:blocksize
    for j=1:blocksize
        WW((i-1)*block+1:i*block,(j-1)*block+1:j*block,k)=W(i,j,k)*ones(block,block);
        W0(i,j,W(i,j),k)=1;
    end
end
end
w0=zeros(blocksize*block,blocksize*block,3,5);
for k=1:5
for i=1:blocksize*block
    for j=1:blocksize*block
        w0(i,j,WW(i,j),k)=255*alpha;
    end
end
end

%%
%生成噪声水印模板
loc=1;
blocksize=size(w1,1);
k0=1;
k1=1;
for i=1:8
    for j=1:8
        if(w(loc)==1)
            W01((i-1)*blocksize+1:(i-1)*blocksize+blocksize,(j-1)*blocksize+1:(j-1)*blocksize+blocksize,:)=w1(:,:,:,k1);
            k1=k1+1;
            if(k1>5)
                k1=1;
            end
        else
            W01((i-1)*blocksize+1:(i-1)*blocksize+blocksize,(j-1)*blocksize+1:(j-1)*blocksize+blocksize,:)=w0(:,:,:,k0);
            k0=k0+1;
            if(k0>5)
                k0=1;
            end
        end
      
        loc=loc+1;
    end
end
%%
I_cov=double(I);
I2=I(65:192,65:192,:);
I_gray=double(rgb2gray(I2));
blockrow=size(I_gray,1)/size(W01,1);
blockcol=size(I_gray,2)/size(W01,2);
for i=1:blockrow
    for j=1:blockcol
        H(i,j)=findH(I_gray((i-1)*size(W01,1)+1:(i-1)*size(W01,1)+size(W01,1),...
            (j-1)*size(W01,1)+1:(j-1)*size(W01,1)+size(W01,1)));
    end
end
meanH=mean(mean(H));
T=meanH;
%%
%嵌入水印
loc=1;
for i=1:blockrow
    for j=1:blockcol 
        I_mask((i-1)*size(W01,1)+1:(i-1)*size(W01,1)+size(W01,1),(j-1)*size(W01,1)+1:(j-1)*size(W01,1)+size(W01,1),:)=W01;
        loc=loc+1;
    end
end

I_gray=double(rgb2gray(uint8(I_cov)));
[row,col]=size(I_gray);
for i=1:row/block
    for j=1:col/block
        H_cov(i,j)=findH(I_gray((i-1)*block+1:(i-1)*block+block,...
            (j-1)*block+1:(j-1)*block+block));
        H_cov2((i-1)*block+1:i*block,(j-1)*block+1:j*block,:)=H_cov(i,j)*ones(block,block,3);
    end
end
meanH_cov=mean(mean(H_cov));
T_cov=meanH_cov;
H_cov2(H_cov2<=T_cov)=1;
H_cov2(H_cov2>T_cov)=2;
%%
%模板图像生成
blocksize=16;
rand('seed',4);
W=rand(blocksize,blocksize);
W(W>0.66)=3;
W(W>0.33&W<=0.66)=2;
W(W<=0.33)=1;
for i=1:blocksize
    for j=1:blocksize
        WW((i-1)*2+1:i*2,(j-1)*2+1:j*2)=W(i,j)*ones(2,2);
    end
end
template=zeros(blocksize*2,blocksize*2,3);
for i=1:blocksize*2
    for j=1:blocksize*2
        template(i,j,WW(i,j))=255*alpha;
    end
end
%%
template1=zeros(256,256,3);
template1=repmat(template,size(template1,1)/size(template,1),size(template1,2)/size(template,1));
template1(65:192,65:192,:)=I_mask;
I_mask=template1;
%%
imshow(I_mask)
%%
%将图像分块后计算每个图像块的信息熵，选择信息熵小于整体平均信息熵的3/4作为水印嵌入区域
I_cov=I_mask.*H_cov2+I_cov;
I_cov=uint8(I_cov);
imshow(I_cov)
end

