%% ************** Preparation part ********************
clear all; clc;
% system parameters
gi = 1/4;                   % Guard interval factor
fftlen = 64;                % FFT���� = 64 points
gilen = gi*fftlen;          % GI���� =16 points

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
h = zeros(gilen,1);     % 3������
h(1) = 1;
h(5) = 0.5;
h(10) = 0.3;
start_noise_len = 500;      % �ӵ�noise���յ�
snr = 20;       % �����20

%% ************** transmitter ***************************
tx = [short_train_blks; long_train_syms];    % �����źŽ��ɳ������й��ɣ�Ϊ320*1 (����data)

%% ************** pass channel ***************************
rx_signal = filter(h, 1, tx);   % ���նྶ�����ź�     
noise_var = 1/(10^(snr/10))/2;  
len = length(rx_signal);        % �����źų��� = 320
noise = sqrt(noise_var) * (randn(len,1) + j*randn(len,1));   % 320*1

% add noise  
rx_signal = rx_signal + noise;  % �������Ľ����ź�
start_noise = sqrt(noise_var) * (randn(start_noise_len,1) + j*randn(start_noise_len,1)); 
rx_signal = [start_noise; rx_signal];       % �ټ���500points���ȵ���ʼ�����ڽ����ź�֮ǰ   ����Ϊ820*1


%% ************** receiver ***************************
search_win = 700;   % ��������С (�����ϴ�����������500����) 
D = 16;   % ÿ����ѵ�����з���ti���� / the length of short training block: LTB

% Calculate the delayed correlation  һ���Լ����������ڷ��������
delay_xcorr = rx_signal(1:search_win+2*D).*conj(rx_signal(1*D+1:search_win+3*D));  %732*1
% 1:700+2*16    .*    1*16+1:700+3*16        1;732 .* 17:748

% ע���ڶ�ѵ�����з��ŵ���ͬ��λ�ü��Ϊ16(17-1=16)   LTB=D=16
% ���ڷ����ܳ�����Ϊ16*2=32   (2*D)

% Moving average of the delayed correlation   �����������ڷ��������mn(�ķ���|Cn|)
ma_delay_xcorr = abs(filter(ones(1,2*D), 1, delay_xcorr));   % 732*1
ma_delay_xcorr(1:2*D) = [];  % �ӵ�33����ʼ��  *******


%�ĳ�forѭ����д����
ma_delay_xcorr_ss = zeros(700,1);
for i = 1:700
    counter = 0;
    for j = i : (i + 2*D - 1)                               % 2-33��3-34...700-731��701-732
        counter = counter + (delay_xcorr(j+1));              % ���������33����ʼ������+1   ******
    end
    ma_delay_xcorr_ss(i) = abs(counter);
end



% Moving average of received power            �����������ڷ��������mn(�ķ�ĸPn)
ma_rx_pwr = filter(ones(1,2*D), 1, abs(rx_signal(1*D+1:search_win+3*D)).^2);  % 732*1
ma_rx_pwr(1:2*D) = [];


% The decision variable                       
delay_len = length(ma_delay_xcorr);    % 732*1
ma_M = ma_delay_xcorr(1:delay_len)./ma_rx_pwr(1:delay_len);    % һ���Լ����������ڷ��������mn=|Cn|/Pn

% remove delay samples     �Ƴ�ǰ32������Ϊǰ32����δ����2*D = 32 ���ȵ� filter �����������������
%ma_M(1:2*D) = [];    % 700*1

threshold = 0.75;   % �о�����         (threshold = 0.95ʱ��thres_idx = 501)
thres_idx = find(ma_M > threshold);  % ��ѯ��������(����Դ���threshold)Ԫ�ص�λ��thres_idx
 
if isempty(thres_idx)        % �ж����޼�⵽packet
  thres_idx = 1;        
else   
  thres_idx = thres_idx(1);   % ���ж��thres_idx��������������ȡ��һ����Ϊ��⵽packet����ʼ��
end

detected_packet = rx_signal(thres_idx:length(rx_signal));    % ��������ȡ��detected packet