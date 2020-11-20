clc
clear
%%
%生成水印
rand('seed',1);
w=rand(1,64);
w(w>0.5)=1;
w(w<=0.5)=0;
check_bin = [1,0,0,1,0,0,1];%CRC8
% a = input('请输入需要嵌入的水印序列（0~1073741824）：');
a = 20200421;
message_bit = 30;
if a >= 2^message_bit
    error('Wrong Input!');
end
j = dec2bin(a);
len = length(j);
for i = 1:message_bit
    if i <= len
        J(message_bit-i+1) = str2num(j(len-i+1));
    else
        J(message_bit-i+1) = 0;
    end
end
Mess=J;
h = crc.generator('Polynomial',check_bin, 'InitialState', 0);
data = generate(h,J');
matrix_a = gf(data'); 
JJ = bchenc(matrix_a,63,36);
JJJ = JJ.x;
w = JJJ;
w(64) = 0;
%%
alpha=0.2;
I=imresize(imread('0221.jpg'),[256,256]);
[I_cov] = Embed(w,I,alpha);
%%
%无矫正提取
I_cov2=imread('12_re.png');
alpha=0.2;
[ message_data2 ] = Decode(I_cov2,w,alpha,Mess);
%%
%带矫正提取
strengh=0.1;
[ message_data2 ] = Decode2(I_cov2,w,alpha,Mess,strengh);