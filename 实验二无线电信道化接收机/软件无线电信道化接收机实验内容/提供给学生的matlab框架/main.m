clear all;
close all;
clc;

load data.mat            %% ��ȡԭʼ��������
N = length(data);        %% ���ݳ���
fs = 16e6;               %% ԭʼ������
Bw = 40e3;               %% ����ȡ�źŴ���
f_Lo = 2e6;              %% ����ȡ�ź�����Ƶ��

Power_xdBm(data(1:2^20),fs);  %��ԭʼ�����źŹ�����ͼ��dataΪ��data.mat�ж�����ԭʼ��������
title('�����źŹ�����ͼ ������16MHz Ƶ�׷ֱ���15.259Hz');


%% NCO mixing ������Ƶ
Lo = exp( - 1j * 2 * pi * f_Lo * ( 0 : N - 1 ) / fs ); %% ����������Ƶ�ı����ź�

mixing_data = data .* Lo;  

%% ��һ��CIC�˲�+��ȡ




%% HB1 Filter+2����ȡ



%% HB2 Filter+2����ȡ


%% ����HB�˲����������ݷ���ȷ��


%% ���һ��FIR�˲�+��ȡ 



%% ����ÿһ���˲����ķ�Ƶ��Ӧ


%% ������źŹ����ף�����fir_dataΪ���һ���˲���ȡ������ݣ�fs_outΪ���һ��������ݲ�����
Power_xdBm_complex(fir_data(1:4096),fs_out);  %
title('DDC����źŹ�����ͼ ������100kHz Ƶ�׷ֱ���24.414Hz');
