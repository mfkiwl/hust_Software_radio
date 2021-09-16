%% ************** Preparation part ********************
clear all; clc;
% system parameters
fs = 20e6;                  % ����Ƶ��
gi = 1/4;                   % Guard interval factor
fftlen = 64;                % FFT���� = 64 points
gilen = gi*fftlen;          % GI���� = 16 points

% ѵ������
ShortTrain = sqrt(13/6)*[0 0 1+j 0 0 0 -1-j 0 0 0 1+j 0 0 0 -1-j 0 0 0 -1-j 0 ...
 0 0 1+j 0 0 0 0 0 0 -1-j 0 0 0 -1-j 0 0 0 1+j 0 0 0 1+j 0 0 0 1+j 0 0 0 1+j 0 0].';
NumShortTrainBlks = 10;     % ��ѵ�����з����� = 10

short_train = tx_freqd_to_timed(ShortTrain);    % �Ѷ�ѵ�����д�Ƶ��ת����ʱ��
%plot(abs(short_train));
short_train_blk = short_train(1:16);    % ÿ����ѵ�����г���16
short_train_blks = repmat(short_train_blk,NumShortTrainBlks,1);    % ��10����ѵ������--����10*16=160



LongTrain = [1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 ...
      1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1 1 1 1].';   %ע�⣬����ת����
NumLongTrainBlks = 2;   % ��ѵ�����з����� = 2

long_train = tx_freqd_to_timed(LongTrain);  % 64*1
long_train_syms = [long_train(fftlen-2*gilen+1:fftlen,:); long_train; long_train];  
% (64-2*16+1 = 33)  33:64��32��       
% ��һ��ǰ32�����ڶ���ȫ64����������ȫ64�� -- ����Ϊ 160*1
% �ֱ����� GI2��T1��T2

%% ************** channel ***************************
% ����ྶ�ŵ�
h = zeros(gilen,1);    % 3������
h(1) = 1;
h(5) = 0.5;
h(10) = 0.3;
cfo = 0.1*fs/fftlen;   % �ز�Ƶ��ƫ��     cfoΪʲô�����������ţ�
%% ************** Loop start***************************
snr = 5:5:20;   % SNR = 5��10��15��20            (1,4)
mse = zeros(1,length(snr));   % MSE0ֵ��ʼ��     (1,4)
pkt_num = 2000;     % ����Ϊ2000

for snr_idx = 1:length(snr)    % ����4��snrֵ�۲���Ƶƫ�������MSE
    %snr_idx   % ���ڼ�ʱ�������id
    est_err = zeros(1,pkt_num);   % 0ֵ��ʼ��Ƶƫ������� (1,1000)
    
    for pkt_idx = 1:pkt_num    % 1-2000
        % transmitter
        tx = [short_train_blks; long_train_syms];

        % channel
        rx_signal = filter(h,1,tx);     % (320,1)
        noise_var = 1/(10^(snr(snr_idx)/10))/2;
        len = length(rx_signal);

        noise = sqrt(noise_var) * (randn(len,1) + j*randn(len,1));
        
        % add noise
        rx_signal = rx_signal + noise;
        
        % add CFO ===============================
        total_length = length(rx_signal);   % 320
        t = [0:total_length-1]/fs;  % (1,320)
        
        phase_shift = exp(j*2*pi*cfo*t).';  % ��Ƶƫָ��
        rx_signal = rx_signal.*phase_shift;

        % receiver
        % for the dirty samples at the beginning (and synch errors in practical system)
        pkt_det_offset = 30;    % �����ƫ�ƣ���
        % averaging length
        rlen = length(short_train_blks) - pkt_det_offset;  % 160 - 30 = 130
        
        % short training symbol periodicity
        D = 16;
        
        % һ���Լ����������ڷ��������(115,1)      30-144 .* 46-160    
        phase = rx_signal(pkt_det_offset:pkt_det_offset+rlen-D).* ...   % 30 : 30+130-16
                conj(rx_signal(pkt_det_offset+D:pkt_det_offset+rlen));  % 30+16 : 30+130
        % add all estimates 
        phase = sum(phase);
        
        % Ƶƫ����  CFO Estimation
        freq_est = -angle(phase) / (2*pi*D/fs);
        % Ƶƫ����������
        est_err(pkt_idx) = (freq_est - cfo)/cfo;  % (1,2000)

%         radians_per_sample = 2*pi*freq_est/fs;
%         time_base = 0:length(rx_signal)-1;
%         correction = exp(-j*(radians_per_sample)*time_base);             
%         out_signal = rx_signal.*correction.';
    end
    mse(snr_idx) = mean(abs(est_err).^2);   % (1,4)
end

semilogy(snr,mse);
xlabel('SNR/dB');
ylabel('MSE');