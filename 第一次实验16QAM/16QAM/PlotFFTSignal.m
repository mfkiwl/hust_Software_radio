function PlotFFTSignal(x,sampling_freq)

% ����FFT�任���ͼ��
% ���ݵĳ���
data_len = length(x);
% FFT�任���Ƶ��
fft_x = abs(fft(x));
% Ƶ���ź�������
fre_x = fft_x(1:data_len/2);

% Ƶ�ʷ�Χ�����ֵ�������ο�˹�ز������������������Ƶ�ʵ�2����
max_fre = sampling_freq/2;

% Ƶ��Χ
plotscope = linspace(0,max_fre,data_len/2);

% ��ͼ
plot(plotscope,fre_x,'Linewidth',1.5);