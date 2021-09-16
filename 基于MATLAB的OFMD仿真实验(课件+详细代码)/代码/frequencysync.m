function out_signal = frequencysync(transmit,fs)
    len = length(transmit);
    pha=zeros(1,1);
    D = 16;%����Ϊ16�Ĵ���
    pha=0;
    for i=1:(len-D-20)
    %ÿ��������d�����ݺ�����ݹ�����ˣ����ܺ�
    pha=pha+transmit(19+i).*conj(transmit(i+D));
    end 

    cfo_est = -angle(pha) / (2*D*pi/fs);%����Ƴ���Ƶƫ
    cfo = cfo_est/fs*[0:len-1];%��Ƶƫ 
    %[0:total_length-1]/fs=nTs ��f=0.2*fs/fftlen
    phase_shift = exp(-j*2*pi*cfo)';
    out_signal= transmit.*phase_shift;%��Ƶƫ�ӵ�������ź���