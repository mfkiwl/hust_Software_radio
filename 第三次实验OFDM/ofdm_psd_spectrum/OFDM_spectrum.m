% OFDM���ز�Ƶ��
clear all; 
close all; 
clc;  
Num_Sc = 4; % 5�����ز��������һ��
Ts = 1; % 1s 
F_space = 1/Ts;  
F = -F_space*Num_Sc/2-4:0.001:F_space*Num_Sc/2+4; %������ȡֵ��Χ��-6��6
F_spectrum = zeros(Num_Sc,length(F));%��ʼ������
for i = -Num_Sc/2:1:Num_Sc/2 %������ͼ
F_spectrum(i+Num_Sc/2+1,1:end)= sin(2*pi*(F-i*F_space).*Ts/2)./(2*pi*(F-i*F_space).*Ts/2); 
end  
plot(F,F_spectrum) 
grid on