clear;
close all;
clc;

load data.mat            %% ��ȡԭʼ��������
N = length(data);        %% ���ݳ���
fs = 16e6;               %% ԭʼ������
Bw = 40e3;               %% ����ȡ�źŴ���
f_Lo = 2e6;              %% ����ȡ�ź�����Ƶ��

Power_xdBm_complex(data(1:2^20),fs);  %��ԭʼ�����źŹ�����ͼ��dataΪ��data.mat�ж�����ԭʼ��������
title('�����źŹ�����ͼ ������16MHz Ƶ�׷ֱ���15.259Hz');
%% NCO mixing ������Ƶ
Lo = exp( - 1j * 2 * pi * f_Lo * ( 0 : N - 1 ) / fs ); %% ����������Ƶ�ı����ź�
mixing_data = data .* Lo;
%% ��һ��CIC�˲�+��ȡ
N = 5;
fs1 = fs/N;
cic_data = cic_filter(N,fs,mixing_data,1);
cic_data = cic_data(N+1:N:end);
Power_xdBm_complex(cic_data,fs1);  %��CIC�˲����źŹ�����ͼ
title(['CIC����źŹ�����ͼ ��������    ',num2str(fs1/10^6),'MHz Ƶ�׷ֱ���15.259Hz']);
%% HB1 Filter+2����ȡ
fpass1 = 0.5e6;
fstop1 = fs1/2 - fpass1;
rs1 = 40;rp1 = 40;
fs2 = fs1/2;
HB_data1 = hb_filter(fs1,fpass1,fstop1,rs1,rp1,cic_data,1);
HB_data1 = HB_data1(1:2:end);
Power_xdBm_complex(HB_data1,fs2);  %��HB1�źŹ�����ͼ
title(['HB1����źŹ�����ͼ ��������    ',num2str(fs2/10^6),'MHz Ƶ�׷ֱ���15.259Hz']);
%% HB2 Filter+2����ȡ
fpass2 = 3e5;
fstop2 = fs2/2 - fpass2;
rs2 = 40;rp2 = 40;
% rs2 = 0.01;rp2 = 0.01;
fs3 = fs2/2;
HB_data2 = hb_filter(fs2,fpass2,fstop2,rs2,rp2,HB_data1,1);
HB_data2 = HB_data2(1:2:end);
Power_xdBm_complex(HB_data2,fs3);  %��HB1�źŹ�����ͼ
title(['HB2����źŹ�����ͼ ��������    ',num2str(fs3/10^6),'MHz Ƶ�׷ֱ���15.259Hz']);
%% ����HB�˲����������ݷ���ȷ��
fpass3 = 1.5e5;
fstop3 = fs3/2 - fpass3;
rs3 = 40;rp3 = 40;
% rs3 = 0.01;rp3 = 0.01;
fs4 = fs3/2;
HB_data3 = hb_filter(fs3,fpass3,fstop3,rs3,rp3,HB_data2,1);
HB_data3 = HB_data3(1:2:end);
Power_xdBm_complex(HB_data3,fs4);  %��HB1�źŹ�����ͼ
title(['HB3����źŹ�����ͼ ��������    ',num2str(fs4/10^6),'MHz Ƶ�׷ֱ���15.259Hz']);

fpass4 = 0.75e5;
fstop4 = fs4/2 - fpass4;
rs4 = 40;rp4 = 40;
% rs4 = 0.01;rp4 = 0.01;
fs5 = fs4/2;
HB_data4 = hb_filter(fs4,fpass4,fstop4,rs4,rp4,HB_data3,1);
HB_data4 = HB_data4(1:2:end);
Power_xdBm_complex(HB_data4,fs5);  %��HB1�źŹ�����ͼ
title(['HB4����źŹ�����ͼ ��������   ',num2str(fs5/10^6),'MHz Ƶ�׷ֱ���15.259Hz']);

fpass5 = 0.4e5;
fstop5 = fs5/2 - fpass5;
rs5 = 40;rp5 = 40;
% rs5 = 0.01;rp5 = 0.01;
fs6 = fs5/2;
HB_data5 = hb_filter(fs5,fpass5,fstop5,rs5,rp5,HB_data4,1);
HB_data5 = HB_data5(1:2:end);
Power_xdBm_complex(HB_data5,fs6);  %��HB1�źŹ�����ͼ
title(['HB5����źŹ�����ͼ ��������    ',num2str(fs6/10^6),'MHz Ƶ�׷ֱ���15.259Hz']);
%% ���һ��FIR�˲�+��ȡ
fpass = 2e4;
fstop = 3e4;
% rs5 = 40;rp5 = 40;
rs = 0.000001;rp = 0.1;
fir_data = fir_filter(fs6,fpass,fstop,rs,rp,HB_data5,1);
Power_xdBm_complex(fir_data,fs6);  %��HB1�źŹ�����ͼ
title(['FIR����źŹ�����ͼ ��������    ',num2str(fs6/10^6),'MHz Ƶ�׷ֱ���15.259Hz']);
fs_out = fs6;
%% ����ÿһ���˲����ķ�Ƶ��Ӧ
%% ������źŹ����ף�����fir_dataΪ���һ���˲���ȡ������ݣ�fs_outΪ���һ��������ݲ�����
Power_xdBm_complex(fir_data(1:4096),fs_out);  %
title('DDC����źŹ�����ͼ ��������    100kHz Ƶ�׷ֱ���24.414Hz');
