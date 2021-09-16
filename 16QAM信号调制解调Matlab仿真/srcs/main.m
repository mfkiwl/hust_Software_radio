% Designed By yandong, ZHANG
% email: zhangyandong1987@gmail.com
% Peking University

clear all;
close all;
clc;
%��������
MES_LEN=4*10000; % source message length
SYM_LEN=MES_LEN/4;% symbol length
INSERT_TIMES=8; %insert times befor filter
PETAL=5; %num of petals each side of filter
BETA=0.5; %filter bandwidth
SELECT=2; %mode slect

switch SELECT
    case 1,%ģʽ1:����SNR�µĵ��ơ�������������
            SNR=12;%����SNRֵ
            %���������ź�
            [signal_sendI,signal_sendQ,message,signal_base_band]=Modulation(MES_LEN,SYM_LEN,INSERT_TIMES,PETAL,BETA);
            figure;
            %�Ӹ�˹������
            [signal_receiveI,signal_receiveQ]=AddNoise(signal_sendI,signal_sendQ,SNR,INSERT_TIMES);
            figure;
            %���ջ����
            [mymessage,mysignal_base_band]=Receiver(signal_receiveI,signal_receiveQ,INSERT_TIMES,MES_LEN,SYM_LEN,BETA,PETAL);
            figure;
            %������ͳ��
            ErrBit = MES_LEN-sum((mymessage == message));
            ErrSym = SYM_LEN-sum((mysignal_base_band == signal_base_band));
            MyErrBitRate=ErrBit/MES_LEN;
            MyErrSymRate=ErrSym/SYM_LEN;
            %����������ʹ�ʽ
            TherSer=SER_16QAM(SNR);
    case 2,%ģʽ2���������ߵĻ���
            SNR = [10 12 14 16 18 20]; %����SNRֵ
            SumBit = zeros(1,length(SNR));
            SumErrBit = zeros(1,length(SNR));            
            SumSym = zeros(1,length(SNR));
            SumErrSym = zeros(1,length(SNR));
            h=waitbar(0,'���ڻ��ƣ����Ժ� ���� ');
            for k = 1:length(SNR)
                SumSym(1,k) = 0;
                SumErrSym(1,k) = 0;
                SumBit(1,k) =0;
                SumErrBit(1,k) =0;
                while(SumErrSym(1,k)<100 && SumSym(1,k)<SYM_LEN*50) %����100������� ���� �������̫��ʱֹͣ
                    %���������ź�
                    [signal_sendI,signal_sendQ,message,signal_base_band]=Modulation(MES_LEN,SYM_LEN,INSERT_TIMES,PETAL,BETA);
                    
                    close all;
                    %�Ӹ�˹������
                    [signal_receiveI,signal_receiveQ]=AddNoise(signal_sendI,signal_sendQ,SNR(k),INSERT_TIMES);
                    
                    close all;
                    %���ջ����
                    [mymessage,mysignal_base_band]=Receiver(signal_receiveI,signal_receiveQ,INSERT_TIMES,MES_LEN,SYM_LEN,BETA,PETAL);
                    
                    close all;
                    %������ͳ��
                    ErrBit = MES_LEN-sum((mymessage == message));
                    ErrSym = SYM_LEN-sum((mysignal_base_band == signal_base_band));
                    SumErrBit(1,k) = SumErrBit(1,k) + ErrBit;
                    SumErrSym(1,k) = SumErrSym(1,k) + ErrSym;
                    SumBit(1,k) = SumBit(1,k) +MES_LEN;
                    SumSym(1,k) = SumSym(1,k) +SYM_LEN;
                end
                waitbar(k/length(SNR),h);
            end
            close(h);
            MyErrBitRate = SumErrBit./SumBit      %����õ����������
            MyErrSymRate = SumErrSym./SumSym      %����õ����������
            TherSer=SER_16QAM(SNR);    %�����������      
            %����������ʺ������������
            figure;
            semilogy(SNR, MyErrSymRate, 'b-*');
            hold on;
            semilogy(SNR, MyErrBitRate, 'r-.');
            hold on;
            semilogy(SNR, TherSer, 'r-*');
            
            legend('�����������','�����������','�����������');
            xlabel('��������� /dB');
            ylabel('�������');
            grid on;
end