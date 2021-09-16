clear all; clc;
gi = 1/4;                
fftlen = 64;
gilen = gi*fftlen;          

ShortTrain = sqrt(13/6) * [0 0 1+j 0 0 0 -1-j 0 0 0 1+j 0 0 0 -1-j ...
                       0 0 0 -1-j 0 0 0 1+j 0 0 0 0 0 0 -1-j 0 0 0 ...
                       -1-j 0 0 0 1+j 0 0 0 1+j 0 0 0 1+j 0 0 0 1+j 0 0].';

short_demap = zeros(64, 1);
short_demap([7:32 34:59],:) = ShortTrain;
short_demap([33:64 1:32],:) = short_demap;
% ��Ƶ��Ķ�ѵ������ת����ʱ�򲢽��й��ʹ�һ��
ShortTrain=sqrt(64)*ifft(sqrt(64/52)*short_demap); 
ShortTrain =ShortTrain(1:16);
short_train_blks=[ShortTrain;ShortTrain;ShortTrain;ShortTrain;ShortTrain;
                  ShortTrain;ShortTrain;ShortTrain;ShortTrain;ShortTrain];

longTrain = [1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1 1 1 ...
     1 1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1 1 1 1].';
 
long_demap = zeros(64, 1);
long_demap([7:32 34:59],:) = longTrain;
long_demap([33:64 1:32],:) = long_demap;

% ��Ƶ��ĳ�ѵ������ת����ʱ�򲢽��й��ʹ�һ��
longTrain=sqrt(64)*ifft(sqrt(64/52)*long_demap);
% ȡ��ѵ�����еĺ�32λ��Ϊcpǰ׺
long_train_syms = [longTrain(33:64,:); longTrain; longTrain];
% ���ɷ�������
transmit = [short_train_blks; long_train_syms]; 

len = length(transmit);
error = zeros(500,1);
time_est = zeros(500,1);
snr = 0:1:10;
for snr_idx = 1:length(snr)
    for n = 1:500
        noise = sqrt(1/(10^(snr(snr_idx)/10))/2)* ...
                    (randn(len,1)+j*randn(len,1));
        transmit1 = transmit + noise;   % ������
        i_matrix=zeros(64,1);
        j_matrix=zeros(51,1);
        for j=150:200        % ��ȷ��ͬ��λ����160+32+1����ѡ��Χ����193
            for i=1:64       % ��ѵ�����е�64λ
                % ���������볤ѵ�����й������
                i_matrix(i)=transmit1(j-1+i).*conj(longTrain(i)); 
                % ��ÿһ��bitΪ��ʼ�����һ����
                j_matrix(j-149)=j_matrix(j-149)+i_matrix(i);
            end
        end
        [a,b] = max(abs(j_matrix));   % ������ģ���س̶����

        time_est(n) = 149 + b;    % ��������ͬ��λ��
        error(n) = time_est(n) - 193;    % ����λ��ƫ��
         

    end
end


mse(snr_idx)= mean(abs(error).^2); % ��mse
semilogy(snr,mse);
xlabel('SNR/dB');
ylabel('MSE');
grid on;
