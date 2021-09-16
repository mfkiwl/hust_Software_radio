%% ************** Preparation part ********************
clear all; clc;
% system parameters
ml = 2;                      % Modulation level: 2          QPSK����
NormFactor = sqrt(2/3*(ml.^2-1));
gi = 1/4;                    % GI factor
fftlen = 64;
gilen = gi*fftlen;           % Length of GI = 16
blocklen = fftlen + gilen;   % Length of OFDM symbol = 80

% index define
UsedSubcIdx = [7:32 34:59];
reorder = [33:64 1:32];

% long training for channel estimation and SFO estimation (NumSymbols = 52)
LongTrain = [1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 ...
      1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1 1 1 1].';  % ע������ת���� (52,1)
NumLongTrainBlks = 2;   % ��ѵ�����з����� = 2

long_train = tx_freqd_to_timed(LongTrain);    % IFFT (64,1)
long_train_syms = [long_train(fftlen-2*gilen+1:fftlen,:); long_train; long_train];
% (64-2*16+1 = 33)  33:64��32�����Ƶ���ǰ����GI       
% ��һ��ǰ32�����ڶ���ȫ64����������ȫ64�� -- ����Ϊ(160,1)
% �ֱ����� GI2��T1��T2
%% ************** channel ***************************
h = zeros(gilen,1);   % ����ྶ�ŵ�(16,1)    % 3������
h(1) = 1;
h(5) = 0.5;
h(10) = 0.3;
channel = fft(h, 64);      % 64��FFTƵ���ŵ� (64,1)
channel(reorder) = channel;     % ǰ��λ  (64,1)     % reorder = [33:64 1:32];
channel = channel(UsedSubcIdx);    % ȡ�������ز�λ�õ��ŵ� (52,1)

%% ************** Loop start***************************
snr = 0:2:20;     % ����ȹ۲��λ��0��2��4......18��20  ��11��      ���������
mse = zeros(1,length(snr));    % 0ֵ��ʼ��11�������ŵ��������(MSE)��
pkt_num = 1000;     % ����Ϊ1000

% ��ȡ�����ź�
tx = long_train_syms;   % ��ȡ��ѵ�������������ź� (160,1)
rx = filter(h,1,tx);    % �����ྶ�ŵ��������ź�
len = length(rx);       % �����źų���160    


for snr_idx = 1:length(snr)     % ����11��snrֵ�۲����ŵ��������MSE
    err_est = zeros(1, pkt_num);    % 0ֵ��ʼ���ŵ�������� (1,1000)
    
    for pkt_idx = 1:pkt_num     % 1-1000
        % ��ȡ��ʼ�����ź�
        rx_signal =  rx; 
        
        % ��Ӽ�������       SNR=10 lg(S/N)      S/N=10^(SNR/10)     1/.../2 Ϊʲô
        noise_var = 1/(10^(snr(snr_idx)/10))/2;     % ��������    
        noise = sqrt(noise_var) * (randn(len,1) + j*randn(len,1));  % ���������������(160,1)
        rx_signal = rx_signal + noise;     % ��Ӽ������� (160,1)
        
        % ȥ���������
        long_tr_syms = rx_signal(33:end);      % ȥ��GI2 (128,1)
        long_tr_syms = reshape(long_tr_syms, 64, 2);   % (64,2)

        % to frequency domain
        freq_long_tr = fft(long_tr_syms)/(64/sqrt(52));   % FFT+���ʹ�һ�� (64,2)
        freq_long_tr(reorder,:) = freq_long_tr;     % reorder = [33:64 1:32]
        freq_tr_syms = freq_long_tr(UsedSubcIdx,:);     % (52,2)

        % �ŵ����� + ����������
        channel_est = mean(freq_tr_syms,2).*conj(LongTrain); % H(k) = freq_tr_syms * conj(LongTrainingSyms)
        %err_est(pkt_idx) = mean(abs(channel_est-channel).^2)/mean(abs(channel).^2); % ����MSE  ע��"/"�ĺ���
        err_est(pkt_idx) = mean(abs(channel_est-channel).^2); % ����  ��MSE�������ŵ����Ƶ�����
    end
    % ��ƽ����������������ŵ����Ƶ�����
    mse(snr_idx) = mean(err_est);   % ��ÿ��snr�����£���1000��packet��est_err��ƽ��
end


% ��ͼ
semilogy(snr,mse,'-o');
%title('');
xlabel('SNR (dB)');
ylabel('MSE');
grid on; 
