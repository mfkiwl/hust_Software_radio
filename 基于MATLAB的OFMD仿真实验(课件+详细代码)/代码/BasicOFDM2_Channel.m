%% ************** Preparation part ********************
clear all; clc;
% system parameters
fs = 20e6
ml = 2;                      % Modulation level: 2--4QAM; 4--16QAM; 6--64QAM
NormFactor = sqrt(2/3*(ml.^2-1));
gi = 1/4;                   % Guard interval: in the Brazil_E model,the maxmum delay is 2e-6s, equals to 16 points. 
fftlen = 64;
gilen = gi*fftlen;           % Length of guard interval (points)
blocklen = fftlen + gilen;   % total length of the block with CP

% index define

DataSubcPatt = [1:5 7:19 21:26 27:32 34:46 48:52]';
DataSubcIdx = [7:11 13:25 27:32 34:39 41:53 55:59];
PilotSubcPatt = [6 20 33 47];
PilotSubcIdx = [12 26 40 54];
UsedSubcIdx = [7:32 34:59];
reorder = [33:64 1:32];

% packet information
NumBitsPerBlk = 48*ml;
NumBlksPerPkt = 50;
NumBitsPerPkt = NumBitsPerBlk*NumBlksPerPkt;
NumPkts = 50;

%% ************** channel ***************************
h = zeros(gilen,1);
h(1) = 1;
% h(5) = 0.5;
% h(10) = 0.3;
cfo = 0.1*fs/fftlen
start_noise_len = 500;
%% ************** Loop start***************************
snr = 200;
ber = zeros(1,length(snr));
for snr_index = 1:length(snr)
    num_err = 0;
    err = zeros(1,NumPkts);
    for pkt_index = 1:NumPkts
        [snr_index pkt_index]
        %%  Transmitter 
        % Generate the information bits
        inf_bits = randn(1,NumBitsPerPkt)>0;
        
        %Modulate
        paradata = reshape(inf_bits,length(inf_bits)/ml,ml);
        ModedSeq = qammod(bi2de(paradata),2^ml)/NormFactor;
        
        mod_ofdm_syms = zeros(52, NumBlksPerPkt);
        mod_ofdm_syms(DataSubcPatt,:) = reshape(ModedSeq, 48, NumBlksPerPkt);
        mod_ofdm_syms(PilotSubcPatt,:) = 1;
        
        tx_blks = tx_freqd_to_timed(mod_ofdm_syms);
        
        % Guard interval insertion
        tx_frames = [tx_blks(fftlen-gilen+1:fftlen,:); tx_blks];
        % P/S
        tx_seq = reshape(tx_frames,NumBlksPerPkt*blocklen,1);
        
        %%  Channel 
        rx_signal = filter(h,1,tx_seq);
        noise_var = 1/(10^(snr(snr_index)/10))/2;
        len = length(rx_signal);
        noise = sqrt(noise_var) * (randn(len,1) + j*randn(len,1));
        % add noise
        rx_signal = rx_signal + noise;
        % add CFO
        total_length = length(rx_signal);
        t = [0:total_length-1]/fs;
        phase_shift = exp(j*2*pi*cfo*t).';
        rx_signal = rx_signal.*phase_shift;
        
%         start_noise = sqrt(noise_var) * (randn(start_noise_len,1) + j*randn(start_noise_len,1));
%         rx_signal = [start_noise; rx_signal];
        
        data_syms = reshape(rx_signal, 80, NumBlksPerPkt);
        % remove guard intervals
        data_syms(1:16,:) = [];
        freq_data = fft(data_syms)/(64/sqrt(52));
        freq_data(reorder,:) = freq_data;
        
        %Select data carriers
        freq_data_syms = freq_data(DataSubcIdx,:);
        
        for blk_idx = 1:10
            scatterplot(freq_data_syms(:,blk_idx));
        end

%         Data_seq = reshape(freq_data_syms,48*NumBlksPerPkt,1);
%         DemodSeq = de2bi(qamdemod(Data_seq*NormFactor,2^ml));
%         SerialBits = reshape(DemodSeq,size(DemodSeq,1)*ml,1).';
%         
%         err(pkt_index) = sum(abs(SerialBits-inf_bits));
%         num_err = num_err + err(pkt_index);
    end
    ber(snr_index) = num_err/(NumPkts*NumBitsPerPkt);
end

%% display SNR-BER
semilogy(snr,ber,'-b.');hold on;