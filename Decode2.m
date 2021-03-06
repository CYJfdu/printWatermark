function [ message_data ] = Decode2(I_cov2,w,alpha,Mess,strengh )
%UNTITLED5 此处显示有关此函数的摘要
%   此处显示详细说明
%UNTITLED4 此处显示有关此函数的摘要
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
I_re=[];
I_re(:,:,1)=wiener2(I_cov2(:,:,1),[5,5]);
I_re(:,:,2)=wiener2(I_cov2(:,:,2),[5,5]);
I_re(:,:,3)=wiener2(I_cov2(:,:,3),[5,5]);
blocksize=8;
noise_layer=double(I_cov2)-I_re;
I_re=I_re(65:192,65:192,:);
I_cov_gray=double(rgb2gray(uint8(I_re)));
blockrow=size(I_cov_gray,1)/size(W01,1);
blockcol=size(I_cov_gray,2)/size(W01,1);
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
[row,col,~]=size(noise_layer);
noise_layer3=noise_layer;
ncc=zeros(row,col);
blocksize=31;
for i=1:row
    for j=1:col
        if(i+blocksize>row||j+blocksize>col)
            continue;
        end
        ncc(i,j)=max([NCC(noise_layer3(i:i+blocksize,j:j+blocksize,1),template(:,:,1)),...
              NCC(noise_layer3(i:i+blocksize,j:j+blocksize,2),template(:,:,2)),...
              NCC(noise_layer3(i:i+blocksize,j:j+blocksize,3),template(:,:,3))]);
    end
end
ncc2=ncc;
ncc2(ncc2<strengh)=0;
imshow(ncc2)
%%
ncc2=1-(ncc2);
n = 160;m = 160;% 需要将图像恢复的尺寸：m*n
imshow([ncc2(:,:)]);hold on;
for p = 1:4
    [loc_x(p),loc_y(p)] = zginput(1);
    plot(loc_x(p),loc_y(p),'r.');
end
loc_x = floor(loc_x);
loc_y = floor(loc_y);

%% 对筛选出的四个点坐标进行排序
[X,Y] = my_sort(loc_x,loc_y,ncc2);
%% 对原图像进行透视变换
noise_layer2 = my_pres_trans(noise_layer,X,Y,m,n);
noise_layer2=noise_layer2(33:m,33:n,:);
%%
loc=1;
for i=1:blockrow
    for j=1:blockcol
         Area(:,:,:,loc)=noise_layer2((i-1)*size(W01,1)+1:(i-1)*size(W01,1)+size(W01,1),(j-1)*size(W01,1)+1:(j-1)*size(W01,1)+size(W01,1),:);
        loc=loc+1;
    end
end

AreaEmb=Area;
%%
%水印提取
w_re=[];
blocksize=16;
tt=1;
k=1;
loc=1;
for i=1:8
    for j=1:8
        for kk=1:5
            tempPrw0(kk)=mean([max(max(NCC(AreaEmb((i-1)*blocksize+1:(i-1)*blocksize+blocksize,(j-1)*blocksize+1:(j-1)*blocksize+blocksize,1,k),w0(:,:,1,kk)))),...
                max(max(NCC(AreaEmb((i-1)*blocksize+1:(i-1)*blocksize+blocksize,(j-1)*blocksize+1:(j-1)*blocksize+blocksize,2,k),w0(:,:,2,kk)))),...
                max(max(NCC(AreaEmb((i-1)*blocksize+1:(i-1)*blocksize+blocksize,(j-1)*blocksize+1:(j-1)*blocksize+blocksize,3,k),w0(:,:,3,kk))))]);
        end
        tempPrw0=mean(tempPrw0);
        for kk=1:5
            tempPrw1(kk)=mean([max(max(NCC(AreaEmb((i-1)*blocksize+1:(i-1)*blocksize+blocksize,(j-1)*blocksize+1:(j-1)*blocksize+blocksize,1,k),w1(:,:,1,kk)))),...
                max(max(NCC(AreaEmb((i-1)*blocksize+1:(i-1)*blocksize+blocksize,(j-1)*blocksize+1:(j-1)*blocksize+blocksize,2,k),w1(:,:,2,kk)))),...
                max(max(NCC(AreaEmb((i-1)*blocksize+1:(i-1)*blocksize+blocksize,(j-1)*blocksize+1:(j-1)*blocksize+blocksize,3,k),w1(:,:,3,kk))))]);
        end
        tempPrw1=mean(tempPrw1);
        if(tempPrw0>tempPrw1)
            w_re(loc,k)=0;
        else
            w_re(loc,k)=1;
        end
        loc=loc+1;
    end
end
%%
for i=1:64
    if(sum(w_re(i,1)==1)>sum(w_re(i,1)==0))
        W_re(i)=1;
    else
        W_re(i)=0;
    end
end
sum(w~=W_re)


W_re = W_re(1:63);
message_bit = 30;
check_bit = 7;
check_bin = [1,0,0,1,0,0,1];
ww = gf(W_re);
J = bchdec(ww,63,message_bit+check_bit-1);
h=crc.detector('Polynomial',check_bin, 'InitialState', 0);
[message_data,error1] = detect(h,(J.x)');
message_data = double(message_data');
num1 = 0;
sum(message_data~=Mess)
if error1 == 0
    for ii = 1:message_bit
        num1 = num1 + message_data(ii)*2^((message_bit-ii));
    end
    figure,imshow(I_cov2)
    title(['您的编号为：',num2str(num1,'%.0f')]);
else
    title('提取失败');
end
end

