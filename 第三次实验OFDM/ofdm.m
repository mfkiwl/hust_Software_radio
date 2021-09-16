clc
clear
%q1:ifft�����ѵ�����Ӧ�õ������ز��������ز�����ifft�����Ĺ�ϵ��
%a:ifft�����������ز���
%q2���Ծ������fft��
%a:y������һ�����������yΪ��������Y��y��FFT��������y������ͬ�ĳ��ȡ���yΪһ������Y�ǶԾ����ÿһ����������FFT��
%image_data_generator();
%�������ز���128
%fft����512
snr = 0:1:20%dB ��˹�ŵ���SNR
cdata_number = 128; 
fft_n = 128;
%OFDM��Ԫ���� 500
%���������������
cdata_length = 500;
cdata = rand_bit(cdata_number*cdata_length*2);
%--------------------------------------------------------------------------
figure;
subplot(2,1,1);
time(cdata(1,1:200),"��Դ����ʱ��ͼ",'B');
subplot(2,1,2);
frequency_response(cdata(1,1:200),"��Դ����Ƶ��ͼ",'B');
%--------------------------------------------------------------------------
%��Ƶ����256
%���뵼Ƶ���Ϊ5
%��������ĵĵ�Ƶ����
pilot_inter = 5;
pilot_length = 256;
pilot_bit = rand_bit(pilot_length);
%--------------------------------------------------------------------------
figure;
subplot(2,1,1);
time(pilot_bit(1,1:200),"��Ƶ����ʱ��ͼ",'B');
subplot(2,1,2);
frequency_response(pilot_bit(1,1:200),"��Ƶ����Ƶ��ͼ",'B');
%--------------------------------------------------------------------------
%����qpsk���� �����������
qpsk_bit = modulator_QPSK(cdata);
scatterplot(qpsk_bit);
%--------------------------------------------------------------------------
figure;
subplot(2,1,1);
time(real(qpsk_bit(1:100)),"��Դ����QPSK",'B');
hold on;
time(imag(qpsk_bit(1:100)),"��Դ����QPSK",'R');
subplot(2,1,2);
frequency_response(qpsk_bit(1:100),"��Դ����QPSKƵ��ͼ",'B');
%--------------------------------------------------------------------------
%����ת�� 128*1000
paradata = reshape(qpsk_bit,cdata_number,cdata_length);
%--------------------------------------------------------------------------
%���뵼Ƶ
inserted_bit = insert_pilot(paradata,pilot_bit,pilot_inter);
%--------------------------------------------------------------------------
%�渵��Ҷ�任
ifft_data = ifft(inserted_bit,fft_n,1)*sqrt(fft_n);
%--------------------------------------------------------------------------
figure;
subplot(2,1,1);
time(real(ifft_data(1:100)),"�渵��Ҷ�任ʱ��ͼ",'B');
hold on;
time(imag(ifft_data(1:100)),"�渵��Ҷ�任ʱ��ͼ",'R');
subplot(2,1,2);
frequency_response(ifft_data(1:100),"�渵��Ҷ�任Ƶ��ͼ",'B');
%--------------------------------------------------------------------------
%����OFDMƵ��ͼ
figure;
for i = 1:600
    hold on;
    frequency_response_deshift(inserted_bit(:,i)',"OFDMƵ��ͼ",'B');
end
%--------------------------------------------------------------------------
%����ѭ��ǰ׺
symbol_cp_pro = cyclic_prefix(ifft_data);
%--------------------------------------------------------------------------
[row,column] = size(symbol_cp_pro);
%--------------------------------------------------------------------------
%������˹�ŵ�
awgn_err_plot(cdata,symbol_cp_pro);
%--------------------------------------------------------------------------
%ls�ྶ�ŵ�
ERR1 = ls_err_plot(cdata,symbol_cp_pro,pilot_bit);
%--------------------------------------------------------------------------
%����ת��
symbol_cp = reshape(symbol_cp_pro,1,[]);
%--------------------------------------------------------------------------
figure;
time(real(symbol_cp(1:160)),"����CPʱ��ͼ",'B');
hold on;
time(imag(symbol_cp(1:160)),"����CPʱ��ͼ",'R');
%--------------------------------------------------------------------------
%�ŵ�
%ts�������
%fdDopplerƵƫ��HZ
%tau�ྶ��ʱ
%pdb��������
%---------------------------------------------�ྶ�ŵ�---------------------
fs = 15000;
ts = 1/fs;
fd = 0;
tau = [0,50,120,200,230,500,1600,2300,5000]/(10^9);
pdb = [-1.0,-1.0,-1.0,0,0,0,-3.0,-5.0,-7.0];
chan = rayleighchan(ts,fd,tau,pdb);
chan.ResetBeforeFiltering = 0;
chan_symbol_s = filter(chan,symbol_cp);
%--------------------------------------------------------------------------
figure;
subplot(2,1,1);
time(real(chan_symbol_s(1:100)),"���ྭ�ŵ�ʱ��ͼ",'B');
hold on;
time(imag(chan_symbol_s(1:100)),"���ྭ�ŵ�ʱ��ͼ",'R');
subplot(2,1,2);
frequency_response(chan_symbol_s(1:100),"���ྭ�ŵ�Ƶ��ͼ",'B');
%--------------------------------------------�ྶ�ŵ�-----------------------

%------------------------------------------���Ӹ�˹�ŵ�---------------------
SNR = 20;%��λdB
chan_symbol_s = awgn(chan_symbol_s,SNR);
%--------------------------------------------------------------------------
figure;
subplot(2,1,1);
time(real(chan_symbol_s(1:100)),"���ྭ�ŵ����Ӹ�˹�ŵ�ʱ��ͼ",'B');
hold on;
time(imag(chan_symbol_s(1:100)),"���ྭ�ŵ����Ӹ�˹�ŵ�ʱ��ͼ",'R');
subplot(2,1,2);
frequency_response(chan_symbol_s(1:100),"���ྭ�ŵ����Ӹ�˹�ŵ�Ƶ��ͼ",'B');
%--------------------------------------------------------------------------
figure;
for i=1:100
plot(chan_symbol_s(i),'b*');
title('QPSK���ƾ�����˹�ŵ�����ź�����ͼ');
xlabel('I(t)');
ylabel('Q(t)');
hold on;
end
%--------------------------------------------------------------------------
%����ת��
chan_symbol_p = reshape(chan_symbol_s,row,length(chan_symbol_s)/row);
%--------------------------------------------------------------------------
%ȥѭ����
re_symbol_cp = re_cyclic_prefix(chan_symbol_p);   
%--------------------------------------------------------------------------
%fft
fft_symbol = fft(re_symbol_cp,fft_n,1)./sqrt(fft_n);
%--------------------------------------------------------------------------
figure;
subplot(2,1,1);
time(real(fft_symbol(:,1)'),"����Ҷ�任ʱ��ͼ",'B');
hold on;
time(imag(fft_symbol(:,1)'),"����Ҷ�任ʱ��ͼ",'R');
subplot(2,1,2);
frequency_response(fft_symbol(:,1)',"����Ҷ�任Ƶ��ͼ",'B');
%--------------------------------------------------------------------------
%ȥ����Ƶ
[output,pilot_symbol] = re_insert_pilot(fft_symbol,pilot_inter);
% %----------------��Ƶλ���ŵ���ӦLS����-----------------------------------
pilot_qpsk =  modulator_QPSK(pilot_bit);
pilot_patt=repmat(pilot_qpsk',1,100);
pilot_esti=pilot_symbol./pilot_patt;     % Y = H*X + S
[r,c] = size(output);
h = zeros(r,c);
for i = 1:100
    h(:,(1+(i-1)*5):i*5) = repmat(pilot_esti(:,i),1,pilot_inter);
end
output = output./h;
%--------------------------------------------------------------------------
figure;
subplot(2,1,1);
time(real(output(1:100)),"��������QPSK",'B');
hold on;
time(imag(output(1:100)),"��������QPSK",'R');
subplot(2,1,2);
frequency_response(output(1:100),"��������QPSKƵ��ͼ",'B');
%--------------------------------------------------------------------------
figure;
for i=1:100
plot(output(i),'b*');
title('�����ŵ��������ź�����ͼ');
xlabel('I(t)');
ylabel('Q(t)');
hold on;
end
%--------------------------------------------------------------------------
%����ת��
output = reshape(output,1,[]);
re_modulated =re_modulatorQPSK(output);
figure;
subplot(2,1,1);
time(re_modulated(1,1:200),"���ն�����ʱ��ͼ",'B');
subplot(2,1,2);
frequency_response(re_modulated(1,1:200),"���ն�����Ƶ��ͼ",'B');
%--------------------------------------------------------------------------
% err = 0;
% for n = 1:length(cdata)
%     if cdata(n) ~= re_modulated(n)
%         err = err + 1;
%     end
% end
% err = err/length(cdata);
% n = 1:20;
% ERR = repmat(err,1,20);
% figure;
% semilogy(n,ERR,'-*b')
%     legend('OFDM����������')
%     xlabel('��������� (dB)');
%     ylabel('�������/�������');
%�����������
function sr = rand_bit(L)
    sr = round(rand(1,L));
end
%�����źŽ���QPSK����
function pilot_modulated = modulator_QPSK(pilot)
    length_pilot = length(pilot);
    ip = zeros(1,floor(length_pilot/2));
    for ii = 1:floor(length_pilot/2)
        ip(ii) = 1/sqrt(2)*1i*(2*pilot(2*ii) - 1) + 1/sqrt(2)*(2*pilot(1 + 2*(ii - 1)) - 1);
    end
    pilot_modulated = ip;
end
%QPSK���
function output =re_modulatorQPSK(input)%����
    length_input = length(input);
    output = zeros(1,2*length_input);
    for ii = 1:length_input
        r = real(input(ii));
        i = imag(input(ii));
        if r>0&&i>0
            output(2*ii-1) = 1;
            output(2*ii) = 1;
        end
    if r>0&&i<0
            output(2*ii-1) = 1;
            output(2*ii) = 0;
    end
        if r<0&&i<0
            output(2*ii-1) = 0;
            output(2*ii) = 0;
        end
        if r<0&&i>0
            output(2*ii-1) = 0;
            output(2*ii) = 1;
        end
    end
end
%��״��Ƶ
%input����ת����Ĵ������
%pilot����ĵ�Ƶ����
%pilot_inter���뵼Ƶ���
%output���뵼Ƶ��ľ���
function output = insert_pilot(input,pilot_bit,pilot_inter)
    pilot_symbol = modulator_QPSK(pilot_bit);%1 128
    pilot_symbol = pilot_symbol';%128 1
    %pilot_symbol_tem = reshape(pilot_symbol,128,1);
    %pilot_seq = ifft(pilot_symbol_tem,128)*sqrt(128);
    [N,NL] = size(input);%�������������� 128 500
    output = zeros(N,(NL + fix(NL/pilot_inter)));
    count = 0;
    i = 1;
        while i < (NL+fix(NL/pilot_inter))
            output(:,i) = pilot_symbol;
            count =count + 1;
            if count * pilot_inter <= NL
                output(:,(i + 1):(i + pilot_inter)) = input(:,((count - 1)*pilot_inter + 1):count * pilot_inter);
            else
                output(:,(i + 1):(i + pilot_inter + NL - count * pilot_inter)) = input(:,((count - 1)*pilot_inter + 1):NL);
            end
            i = i + pilot_inter + 1;
        end
end
%ȡ����Ƶ
function [output,pilot_symbol] = re_insert_pilot(input,pilot_inter)
    [row,column] = size(input);%128 600
    pilot_symbol = zeros(row,column/(pilot_inter + 1));%128 100
    output = zeros(row,column - column/(pilot_inter + 1));%128  500
    for i = 1:column/(pilot_inter + 1)%1:100
    output(:,(1+(i-1)*pilot_inter):i*pilot_inter) = input(:,(2+(i-1)*(pilot_inter+1)):i*(pilot_inter+1));
    pilot_symbol(:,i) = input(:,1+(i-1)*(pilot_inter+1));
    end
    
end
%����ѭ��ǰ׺
function symbol_cp = cyclic_prefix(output_ifft)
    [row,column] = size(output_ifft);
    symbol_cp = [output_ifft((row-31):end,:); output_ifft];
end
%ȡ��ѭ��ǰ׺
function re_symbol_cp = re_cyclic_prefix(input)
    re_symbol_cp = input(33:end,:);
end
%����OFDMƵ��ͼ
function []=frequency_response_deshift(data,tit,col)%qpsk_bit 128
    N=256;
    data_p = zeros(1,256);
    data_p(65:192) = data;
    data_p = awgn(data_p,50);
    data_p = ifft(data_p,256);
    delta_f=15*10^3; %subcarrier spacing    
    fs=N*delta_f; %sampling frequency
    ts=1/fs; %sampling period    OFDM��Ԫ��� N*Ts
    data_sampled=fft(data_p,1024)*ts;
    data_sampled = 10*log10(data_sampled*10^3);
    data_ss=fftshift(data_sampled);
    len=length(data_sampled)-1;
    ff=fs/len;
    f=0:ff:fs;
    %stem(real(Hcentered),imag(Hcentered))
    plot(f,real(data_sampled),col)
    title(tit);
    xlim([-10*delta_f,fs+10*delta_f]);
    xlabel('frequency');
    ylabel('frequency response');
end
%����Ƶ��ͼ 
function []=frequency_response(data,tit,col)
    N=128;     
    delta_f=15*10^3; %subcarrier spacing    
    fs=N*delta_f; %sampling frequency
    ts=1/fs; %sampling period    OFDM��Ԫ��� N*Ts
    data_sampled=fft(data,1024)*ts;
    data_ss=fftshift(data_sampled);
    len=length(data_sampled)-1;
    ff=fs/len;
    f=[0:ff:fs] -fs/2;
    %stem(real(Hcentered),imag(Hcentered))
    plot(f,real(data_ss),col)
    title(tit);
    xlabel('frequency');
    ylabel('frequency response');
end
%����ʱ��ͼ
function []= time(inp,titled,col)
    stem(inp,col);
    title(titled);
    xlabel('index');
    ylabel('amplitude');
    axis tight;
end
%���Ƹ�˹�ŵ��������
function [] = awgn_err_plot(cdata,pass_data)
    fft_n = 128;
    pilot_inter = 5;
    [row,column] = size(pass_data);
    pass_data = reshape(pass_data,1,[]);
    snr = 0:1:20;%dB
    ERR = zeros(1,21);
    N = length(pass_data);
    
    for i = 0:20
        err = 0;
        pass = awgn(pass_data,i);
        pass = reshape(pass,row,length(pass)/row);
        %ȥѭ����
        re_symbol_cp = re_cyclic_prefix(pass);   
        %fft
        fft_symbol = fft(re_symbol_cp,fft_n,1)./sqrt(fft_n);
        %ȥ����Ƶ
        [output,pilot_symbol] = re_insert_pilot(fft_symbol,pilot_inter);
        output = reshape(output,1,[]);
        data = re_modulatorQPSK(output);
        for n = 1:N
            if cdata(n) ~= data(n)
                err = err + 1;
            end
        end
        ERR(i+1) = err/N;
    end
    figure;
    semilogy(snr,ERR,'-*g')
    legend('AWGN����������')
    xlabel('��������� (dB)');
    ylabel('�������');
    grid on;

end
%���Ƶ����˸�˹�ŵ��Ķྶ�ŵ����������
function ERR = ls_err_plot(cdata,pass_data,pilot_bit)
    fft_n = 128;
    pilot_inter = 5;
    [row,column] = size(pass_data);
    pass_data = reshape(pass_data,1,[]);
    snr = 0:1:20;%dB
    ERR = zeros(1,21);
    N = length(pass_data);
%---------------------------------------------�ྶ�ŵ�----------------------------------
        fs = 15000;
        ts = 1/fs;
        fd = 0;
        tau = [0,50,120,200,230,500,1600,2300,5000]/(10^9);
        pdb = [-1.0,-1.0,-1.0,0,0,0,-3.0,-5.0,-7.0];
        chan = rayleighchan(ts,fd,tau,pdb);
        chan.ResetBeforeFiltering = 0;
        chan_symbol_s = filter(chan,pass_data);
%--------------------------------------------�ྶ�ŵ�-------------------------------------
     for i = 0:20
            err = 0;
%------------------------------------------���Ӹ�˹�ŵ�---------------------------------
        pass = awgn(chan_symbol_s,i);
%----------------------------------------------------------------------------------------
        
        pass = reshape(pass,row,length(pass)/row);
        %chan_symbol_s = reshape(chan_symbol_s,row,length(chan_symbol_s)/row);
        %ȥѭ����
        re_symbol_cp = re_cyclic_prefix(pass);  
        %re_symbol_cp_ = re_cyclic_prefix(chan_symbol_s);   

        %fft
        fft_symbol = fft(re_symbol_cp,fft_n,1)./sqrt(fft_n);
        %fft_symbol_ = fft(re_symbol_cp_,fft_n,1)./sqrt(fft_n);

        %ȥ����Ƶ
        [output,pilot_symbol] = re_insert_pilot(fft_symbol,pilot_inter);
        pilot_qpsk =  modulator_QPSK(pilot_bit);
        pilot_patt=repmat(pilot_qpsk',1,100);
        pilot_esti=pilot_symbol./pilot_patt;     
        [r,c] = size(output);
        h = zeros(r,c);
        for m = 1:100
            h(:,(1+(m-1)*5):m*5) = repmat(pilot_esti(:,m),1,pilot_inter);
        end
        output = output./h;
        output = reshape(output,1,[]);
        data = re_modulatorQPSK(output);
        for n = 1:N
            if cdata(n) ~= data(n)
                err = err + 1;
            end
        end
        ERR(i+1) = err/N;
     end
    figure;
    semilogy(snr,ERR,'-*g')
    legend('�ŵ��������������')
    xlabel('��������� (dB)');
    ylabel('�������/�������');
    grid on;

end