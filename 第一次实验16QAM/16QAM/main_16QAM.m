clear
close all

%  ϵͳ��������
sys_param = Parameter();
M=16;
k=log2(M);
%  ����������
N=400;
%  ����ı���������
input_data = randi([0,1],1,N);

% �źŵ���
modulated_signal = QAM_Modulation(input_data,sys_param);

%�����ź�ʱ���� ǰ400������
figure
PlotTDSignal(modulated_signal(1:400),sys_param.sample_freq,sys_param.symbol_rate);
title('�����ź�ʱ����(ǰ400������)');
% �����ź�Ƶ��
figure
PlotFFTSignal(modulated_signal,sys_param.sample_freq);
title('�����ź�Ƶ��');

% ����ŵ�����
for j=1:10
signal_noise = awgn(modulated_signal,sys_param.SNR(j));

% ����������ɽ����ʽ
[decode_data,I,Q] = QAM_Demodulation(signal_noise,sys_param);
 
% % ����������
error_ratio(j) = CalBitErrorRate(input_data,decode_data);
end
figure
semilogy(sys_param.SNR,error_ratio,'*-k');hold on;grid on;
xlabel('SNR/dB');
ylabel('������');
title('AWGN�ŵ��µ�������');
% % ����ͼ
figure
plot(I,Q,'*');
title('����������ͼ');
% % 
figure
subplot(2,1,1);
stem(input_data(1:200));
title('ԭʼ���͵Ķ������ź�');
subplot(2,1,2);
stem(decode_data(1:200));
title('����(���)�Ķ������ź�');

