clc;
clear all;
kk=1;



for iii=1:3
   
    for ii=1:4
my_image=imread('C0218.bmp');
my_image=rgb2gray(my_image);
secret_image=imread('lena512_gray.bmp');
if(iii==3)
    iii=iii+1;
end

my_image=imresize(my_image,[128*iii 128*iii]);

headerlength=32;
[R,C]=size(my_image);
% [R1,C1]=size(secret_image);
[s,k]=size(secret_image);
watermarklength=s*k;
slength=uint8(headerlength/2);
klength=uint8(headerlength-slength);
slengthbits=dec2bin(s,slength);
slengthbits=reshape(slengthbits',[],1);
klengthbits=dec2bin(k,klength);
klengthbits=reshape(klengthbits',[],1);
sizebits=uint8(zeros(headerlength,1));
for j=1:uint8(headerlength)
    if(j<=slength)
        sizebits(j)=uint8(slengthbits(j)-48);
    else
        sizebits(j)=uint8(klengthbits(j-klength)-48);
    end
end
actualbits=dec2bin(secret_image);
actualbits=reshape(actualbits',[],1);
totalnoofbitstobeembedded=watermarklength*8+headerlength;

for i=1:totalnoofbitstobeembedded
    if(i<=headerlength)
        watermarkbits(i)=uint8(sizebits(i));
    else
        watermarkbits(i)=uint8(actualbits(i-headerlength)-48);
    end
end
blocksizeR=1;
blocksizeC=4;
wholeBlockRows = ceil(R / blocksizeR);
wholeBlockCols = ceil(C / blocksizeC);

% blocksize=2;
% wholeBlockRows = floor(R / blocksize);
% wholeBlockCols = floor(C / blocksize);
% padding if the image is not divisible by block size
if rem(R,blocksizeR)==0
    effectiveblocksizeR=rem(R,blocksizeR);
else
    effectiveblocksizeR=blocksizeR-rem(R,blocksizeR);
end
if rem(C,blocksizeC)==0
    effectiveblocksizeC=rem(C,blocksizeC);
else
    effectiveblocksizeC=blocksizeC-rem(C,blocksizeC);
end

my_image = padarray(my_image, [effectiveblocksizeR effectiveblocksizeC], 'replicate','pre');
%imwrite(my_image,'E:\Dr. Ram Sarkar\MATLAB_SKG_PROG\ori_resize\lena512_gray_pad.bmp');
[R,C]=size(my_image);
bin=zeros(R,C,'uint8');

flag=0;
traversedbit=1;
traversedbit=uint32(traversedbit);
noOfbitEmbedded=[ii+1 ii-1 ii-1 ii+1];

% loop over all rows and columns
for i=1:wholeBlockRows
    for j=1:wholeBlockCols
        % get the block
        one_block=my_image((i-1)*blocksizeR+[1:blocksizeR],(j-1)*blocksizeC+[1:blocksizeC]);
        %Transform the block
        tn_one_block=uint32(BFT(uint32(one_block)));
        backup_tn_one_block=tn_one_block;
        for m=1:blocksizeR
            for n=1:blocksizeC
                freqcom=tn_one_block(m,n);
%                 backupfreqcom=freqcom;
                for l=1:noOfbitEmbedded(m*n)
                    if(traversedbit<=totalnoofbitstobeembedded)
                        if watermarkbits(traversedbit)==1
                            freqcom=bitor(freqcom,(2^(l-1)));
                        else
                            freqcom=bitand(freqcom,bitcmp((2^(l-1)),'uint16'));
                        end
%                         tn_one_block(m,n)=freqcom;
                        traversedbit=traversedbit+1;
                    else
                        flag=1;
                        break;
                    end
                    
                    if(flag)
                        break;
                    end
                end
                if(flag)
                    break;
                end
                tn_one_block(m,n)=freqcom;
            end
        end
         tn_one_block(1,1)=frequencyAdjustment(backup_tn_one_block(1,1),tn_one_block(1,1),noOfbitEmbedded(1));
         tn_one_block(1,2)=frequencyAdjustment(backup_tn_one_block(1,2),tn_one_block(1,2),noOfbitEmbedded(2));
         tn_one_block(1,3)=frequencyAdjustment(backup_tn_one_block(1,3),tn_one_block(1,3),noOfbitEmbedded(3));
         tn_one_block(1,4)=frequencyAdjustment(backup_tn_one_block(1,4),tn_one_block(1,4),noOfbitEmbedded(4));
         In_one_block=uint32(IBT(int32(tn_one_block)));

        for m=1:blocksizeR
            for n=1:blocksizeC
                pixelval=In_one_block(m,n);
                bin((i-1)*blocksizeR+m,(j-1)*blocksizeC+n)=pixelval;
            end
        end
    end
end

%imshow(bin);

PSNR(kk)=psnr(my_image,bin);
SSIM(kk)=ssim(my_image,bin);


my_image=rescale(my_image);
bin=rescale(bin);
WWPSNR(kk)=WPSNR(my_image,bin);
kk=kk+1;


end
end
disp(PSNR);
disp(SSIM);
disp(WWPSNR);
