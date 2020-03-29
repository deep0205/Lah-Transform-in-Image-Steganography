clc;
clear all;
my_image=imread('M:\lena512_gray_stego.bmp');
[R,C]=size(my_image);
% sdataLength=0;
% R1=64;
% C1=64;
headerlength=32;
msgW=0;
msgW=uint32(msgW);
msgH=0;
msgH=uint32(msgH);
msgWlength=uint8(headerlength/2);
msgHlength=uint8(headerlength-msgWlength);
noOfbitExtracted=[1 2];
blocksizeR=1;
blocksizeC=2;
wholeBlockRows = ceil(R / blocksizeR);
wholeBlockCols = ceil(C / blocksizeC);

% watermarklength=msgW*msgH;
% sdataLength=uint32(sdataLength);
% sdataLength=traversedbit+headerlength;
mask=0;
% z=1;
% bin=ones(R1,C1,'uint8');
flag=0;
traversedbit=1;
traversedbit=uint32(traversedbit);
% loop over all rows and columns
for i=1:wholeBlockRows
    for j=1:wholeBlockCols
        % get the block
        one_block=my_image((i-1)*blocksizeR+[1:blocksizeR],(j-1)*blocksizeC+[1:blocksizeC]);
        %Transform the block
        tn_one_block=uint32(BFT(uint32(one_block)));
        
        for m=1:blocksizeR
            for n=1:blocksizeC
                freqcom=tn_one_block(m,n);
                for l=1:noOfbitExtracted(m*n)
                    if traversedbit<=msgWlength
                        if ((bitand(freqcom,(2^(l-1))))~=0)
                            msgH=msgH+2^(uint32(msgWlength)-uint32(traversedbit));
                        end
                    elseif((traversedbit>msgWlength)&&(traversedbit<=headerlength))
                        if ((bitand(freqcom,(2^(l-1))))~=0)
                            msgW=msgW+2^(uint32(headerlength)-uint32(traversedbit));
                        end
                    else
                        
                        if ((bitand(freqcom,(2^(l-1))))~=0)
                            retrievebitArray(traversedbit-headerlength)=1;
                        else
                            retrievebitArray(traversedbit-headerlength)=0;
                            
                        end
                        %                 if(traversedbit~=sdataLength)
                        %                     lsbfreqcom=mod(freqcom,2);
                        %                     traversedbit=traversedbit+1;
                        %                     retrievebitArray(traversedbit)=lsbfreqcom;
                        %disp(traversedbit);
                        %                     else
                        %                         flag=1;
                        %                         break;
                        %                     end
                        
                        
                        if(traversedbit==(headerlength+(uint32(uint32(msgW)*uint32(msgH))*8)))
                            for k=1:uint32((traversedbit-headerlength)/8)
                                newpixel=0;
                                for m=1:8
                                    if(retrievebitArray((k-1)*8+m)==1)
                                        newpixel= newpixel+2^(8-m);
                                    end
                                end
                                pixelarray(k)=newpixel;
                            end
                            imagematrix = reshape(pixelarray,[msgH,msgW]);
                            bin=repmat(uint8(imagematrix),[1,1,1]);
                            flag=1;
                            break;
                        end
                    end
                    
                    
                    if(flag)
                        break;
                    end
                    traversedbit=traversedbit+1;
                end
                if(flag)
                    break;
                end
            end
            if(flag)
                break;
            end
        end
        if(flag)
            break;
        end
    end
    if(flag)
        break;
    end
end
imshow(bin);
