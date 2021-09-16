%% ************** Preparation part ********************
clear all; clc;

% ϵͳ����
fs = 8e6;                    % ����Ƶ��
ml = 2;                      % ���ƽ��� = 2 ���� QPSK����
NormFactor = sqrt(2/3*(ml.^2-1));
gi = 1/4;                    % ����������� = 1/4
fftlen = 64;                 % FFT���� = 64 points/chips
gilen = gi*fftlen;           % �������/ѭ��ǰ׺���� = 16 points/chips
blocklen = fftlen + gilen;   % OFDM���ų��� = 80 points/chips


% ���ز����
DataSubcPatt = [1:5 7:19 21:26 27:32 34:46 48:52]'; % �������ز�λ�ñ��
PilotSubcPatt = [6 20 33 47]; % ��Ƶ���ز�λ�ñ��
UsedSubcIdx = [7:32 34:59]; % ����52�����ز�


% �ŵ��������
trellis = poly2trellis(7,[133 171]); % �����
tb = 7*5;
ConvCodeRate = 1/2;       % ���� = 1/2


% ѵ������
% ��ѵ������ (NumSymbols = 52)
ShortTrain = sqrt(13/6) * [0 0 1+j 0 0 0 -1-j 0 0 0 1+j 0 0 0 -1-j ...
                       0 0 0 -1-j 0 0 0 1+j 0 0 0 0 0 0 -1-j 0 0 0 ...
                       -1-j 0 0 0 1+j 0 0 0 1+j 0 0 0 1+j 0 0 0 1+j 0 0].';
NumShortTrainBlks = 10;     % ��ѵ�����з����� = 10
NumShortComBlks = 16*NumShortTrainBlks/blocklen;    % 160/80=2

% ��ѵ������ (NumSymbols = 52)
LongTrain = [1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1 1 1  ...
     1 1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1 1 1 1].';
NumLongTrainBlks = 2;       % ��ѵ�����з����� = 2
%��ѵ�����мӳ�ѵ�����й��൱��4��OFDM����
NumTrainBlks = NumShortComBlks + NumLongTrainBlks; 

short_train = tx_freqd_to_timed(ShortTrain);   % �Ѷ�ѵ�����д�Ƶ��ת����ʱ��
%plot(abs(short_train));
short_train_blk = short_train(1:16);    % ÿ����ѵ�����г���16
% ��10����ѵ������ -- �ܳ���Ϊ10*16=160
short_train_blks = repmat(short_train_blk,NumShortTrainBlks,1);  

long_train = tx_freqd_to_timed(LongTrain);     % �ѳ�ѵ�����д�Ƶ��ת����ʱ��
long_train_syms = [long_train(fftlen-2*gilen+1:fftlen,:);      % ��ѭ��ǰ׺
                   long_train; long_train];
 % ����ǰ��ѵ������
preamble = [short_train_blks; long_train_syms]; 


% ����Ϣ
NumBitsPerBlk = 48*ml*ConvCodeRate;    
% ÿ��OFDM������Ϣ��=48��*2(���ƽ�����ÿ����2bit��Ϣ)*�����Ч��
NumBlksPerPkt = 50;        % ÿ����������50
NumBitsPerPkt = NumBitsPerBlk*NumBlksPerPkt;      % ÿ������Ϣ��λ50*48
NumPkts = 250;             % �ܰ���250

% �ŵ���Ƶƫ����
h = zeros(gilen,1);  % ����ྶ�ŵ�
h(1) = 1; h(3) = 0.5; h(5) = 0.2;   % 3��
h = h/norm(h);
CFO = 0.1*fs/fftlen;    % Ƶƫ

% ��ʱ����
ExtraNoiseSamples = 500;   % ��ǰ�Ӷ���500���ȵ�����

%% ************** Loop start*************************************
snr = 0:1:20;                   % ���ڼ��������ֵ
ber = zeros(1,length(snr));     % 0ֵ��ʼ��������
per = zeros(1,length(snr));     % 0ֵ��ʼ�������

for snr_index = 1:length(snr)  
    num_err = 0;
    err = zeros(1,NumPkts);
    for pkt_index = 1:NumPkts   % 250����

%% *********************** Transmitter **************************
        % ������Ϣ����
        inf_bits = randn(1,NumBitsPerPkt)>0;     % ����48*50����Ϣ����
        CodedSeq = convenc(inf_bits,trellis);    % �������
        
        % ����
        paradata = reshape(CodedSeq,length(CodedSeq)/ml,ml); % ��Ϊ��·��
        ModedSeq = qammod(bi2de(paradata),2^ml)/NormFactor;  % 4QAM����
        
        mod_ofdm_syms = zeros(52, NumBlksPerPkt); 
        mod_ofdm_syms(DataSubcPatt,:) = reshape(ModedSeq,48,NumBlksPerPkt);
        %���ƺ��ź�48��50�ж�Ӧ���ز�id [1:5 7:19 21:26 27:32 34:46 48:52]';
        mod_ofdm_syms(PilotSubcPatt,:) = 1; % �ӵ�Ƶ
        
        % ��OFDM������Mapping��IFFT�����64��50�У�
        tx_blks = tx_freqd_to_timed(mod_ofdm_syms);
        
        % ��ѭ��ǰ׺
        % ÿ��OFDM���ź�16λ�ظ�����ǰ����cp
        tx_frames = [tx_blks(fftlen-gilen+1:fftlen,:); tx_blks];
        
        % ����ת��
        tx_seq = reshape(tx_frames,NumBlksPerPkt*blocklen,1);   % 50*80
        tx = [preamble;tx_seq];     % ��50��OFDM����ǰ��ǰ�����У�����һ����
        
%% ****************************** Channel************************
        FadedSignal = filter(h,1,tx);     % ��ͨ���ྶ�ŵ�
        len = length(FadedSignal);
        noise_var = 1/(10^(snr(snr_index)/10))/2;
        noise = sqrt(noise_var) * (randn(len,1) + j*randn(len,1));
        % ������
        rx_signal = FadedSignal + noise; 
        %��ǰ���500���ȵ�����
        extra_noise = sqrt(noise_var) * (randn(ExtraNoiseSamples,1) +  ...
                      j*randn(ExtraNoiseSamples,1));  
        %������170���ȵ�����
        end_noise = sqrt(noise_var) * (randn(170,1) + j*randn(170,1));  
        
        % �����ź�
        rx = [extra_noise; rx_signal; end_noise]; 
        
        % ����Ƶƫ
        total_length = length(rx);   % ��������źų���
        t = [0:total_length-1]/fs;
        phase_shift = exp(j*2*pi*CFO*t).';    % ���ز�Ƶ��ƫ��
        rx = rx.*phase_shift;

%% *************************  Receiver  *************************
        % �����
        %rx_signalȥ����ǰ�����Ľ����ź�,pkt_offset��ǰ������ƫ����
        rx_signal = test_rx_find_packet_edge(rx);
        
        % Ƶƫ���������
        %rx_signal����Ƶ��ƫ�ƺ�Ľ����ź�,cfo_estƵ��ƫ����
        rx_signal = frequencysync(rx_signal,fs);
        
        % ʱ�侫ͬ��
        % ʱ��ͬ��λ��
        fine_time_est = finetimesync(rx_signal, long_train);
        % Time synchronized signal
        % ����ȥ����ѵ�����м�������ǰcp��
        % �õ����ȼ���ѵ������64*2��+80*50��OFDM����
        expected_length = 64*2+80*NumBlksPerPkt;
        % ȥ����ѵ�������Լ�������ǰcp
        fine_time_est_end = fine_time_est+expected_length-1;
        sync_time_signal = rx_signal(fine_time_est:fine_time_est_end);
        
        [freq_tr_syms, freq_data_syms, freq_pilot_syms] = ...
                                       rx_timed_to_freqd(sync_time_signal);   
        % freq_tr_symsȡ����ѵ������48��n_data_syms��
        % freq_data_symsȡ����Ϣ48��n_data_syms��
        % freq_pilot_symsȡ����Ƶ4��n_data_syms��
        
        % �ŵ�����
        % ����longtrain freq_tr_symsȡ�У�
        % ƽ�� H(k) = freq_tr_syms * conj(LongTrainingSyms)  
        channel_est = mean(freq_tr_syms,2).*conj(LongTrain);       
        
        % Data symbols channel correction
        % ��չ��Ϣ���ж�Ӧ��H(k)��ͬ����OFDM���Ÿ�����ͬ
        chan_corr_mat = repmat(channel_est(DataSubcPatt), ...
                               1, size(freq_data_syms,2));
        % �ù��Ƶ�H(k)����˽�����Ϣ���У��õ����Ƶķ�����Ϣ����                   
        freq_data_syms = freq_data_syms.*conj(chan_corr_mat);
        % �Ե�Ƶ������ͬ���Ĵ���
        chan_corr_mat = repmat(channel_est(PilotSubcPatt), ...
                               1, size(freq_pilot_syms,2));
        freq_pilot_syms = freq_pilot_syms.*conj(chan_corr_mat);

        % ���ȹ�һ��
        % ��Ϣ���ж�Ӧ��H(k)����ֵƽ�������
        chan_sq_amplitude = sum(abs(channel_est(DataSubcPatt,:)).^2, 2);
        %��չ�����Ƶķ�����Ϣ��������
        chan_sq_amplitude_mtx = repmat(chan_sq_amplitude, ...
                                       1, size(freq_data_syms,2));
        data_syms_out = freq_data_syms./chan_sq_amplitude_mtx;  % ���ȹ�һ�� 
       
        % �Ե�Ƶ������ͬ������
        chan_sq_amplitude = sum(abs(channel_est(PilotSubcPatt,:)).^2, 2);
        chan_sq_amplitude_mtx = repmat(chan_sq_amplitude, ...
                                       1, size(freq_pilot_syms,2));
        pilot_syms_out = freq_pilot_syms./chan_sq_amplitude_mtx;

        phase_est = angle(sum(pilot_syms_out)); % ���㵼Ƶ
        phase_comp = exp(-j*phase_est);
        data_syms_out = data_syms_out.*repmat(phase_comp, 48, 1);

        Data_seq = reshape(data_syms_out,48*NumBlksPerPkt,1); % 48*50
        
        % ���
        DemodSeq = de2bi(qamdemod(Data_seq*NormFactor,2^ml),ml);  
        deint_bits = reshape(DemodSeq,size(DemodSeq,1)*ml,1).';
        
        % ���������
        DecodedBits = vitdec(deint_bits(1:length(CodedSeq)), ...
                             trellis,tb,'trunc','hard');  % ά�ر�����
        % ������
        err(pkt_index) = sum(abs(DecodedBits-inf_bits)); % �����������
        num_err = num_err + err(pkt_index);
    end
    ber(snr_index) = num_err/(NumPkts*NumBitsPerPkt);   % ������
    per(snr_index) = length(find(err~=0))/NumPkts;  % �����
end

%% ���� SNR-BER �� SNR-PER����
semilogy(snr,ber,'-b.');
hold on;
semilogy(snr,per,'-re');
xlabel('SNR (dB)');
ylabel('ERROE');
grid on;
legend('BER','PER')

