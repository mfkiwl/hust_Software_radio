% OFDM����ϵͳ
clc;clear all;close all;
% ��������
N = 128;%ifft ����
num_carriers = 64;%�ز���
M = 4;%QPSK
m = 1024;%���ٸ���Ҷ�任
length_symbol = 100;%���ų���
total = num_carriers*length_symbol;%�ܷ�����
% �������������ź�
sig = randi(1,total,[0 3]);
% QPSK����
sig_mod = pskmod(sig,M);
% ����ת��
sig_s = reshape(sig_mod,num_carriers,length_symbol);
% �����ײ�ֵ
sid_0= [sig_s(1:num_carriers/2,:);
zeros(N-num_carriers,length_symbol);
sig_s(num_carriers/2+1:num_carriers,:)];
% Ifft
sig_tx = ifft(sid_0,N);
% ������
Sf = fftshift(fft(sig_tx,m));
OFDM_Sig_PSD=10*log10(abs(Sf).^2/max(abs(Sf).^2));
f = (0:length(OFDM_Sig_PSD)-1)/length(OFDM_Sig_PSD);%��һ��Ƶ��
plot(f,OFDM_Sig_PSD);
hold on;
axis([0 1 -40 0]);
xlabel('��һ��Ƶ��');ylabel('��һ��������');title('OFDM������')
