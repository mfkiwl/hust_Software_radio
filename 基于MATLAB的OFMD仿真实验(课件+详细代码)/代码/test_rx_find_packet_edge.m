function detected_packet = test_rx_find_packet_edge(rx_signal)

win_size = 700;   % ��������С (�����ϴ�����������500����) 
LTB = 16;   % ÿ����ѵ�����з��ų���LTB

% һ���Լ����������ڷ��������
xcorr = rx_signal(1:win_size+2*LTB).* ...
              conj(rx_signal(1*LTB+1:win_size+3*LTB));  %(732,1)
% (1:700+2*16)   .*   (1*16+1:700+3*16    =    1;732  .*  17:748

%-------------------------------------------------------------------------
% ��Լ����������ڷ��������mn(�ķ���|Cn|)
Cn_xcorr = zeros(700,1);
for i = 1:700
    recorder = 0;
    for j = i : (i+2*LTB- 1)     
        recorder = recorder + (xcorr(j+1));      
    end
    Cn_xcorr(i) = abs(recorder);
end
%-------------------------------------------------------------------------
% ��Լ����������ڷ��������mn(�ķ�ĸPn)
rx_pwr = abs(rx_signal(1*LTB+1 : win_size+3*LTB)).^2 ;   %17-748
Pn_xcorr = zeros(700,1);
for i = 1:700
    recorder = 0;
    for j = i : (i+2*LTB-1)                  
        recorder = recorder + rx_pwr(j+1); 
    end
    Pn_xcorr(i) = recorder;
end
%-------------------------------------------------------------------------
                  
% һ���Լ����������ڷ��������mn=|Cn|/Pn
x_len = length(Cn_xcorr);    % 700*1
mn = Cn_xcorr(1:x_len)./Pn_xcorr(1:x_len);    
plot(mn);    % ��ͼ

% �ж����޼�⵽��
threshold = 0.75;   % �о�����ֵ   
thres_idx = find(mn > threshold);  % ��ѯ��������(����Դ�������ֵ)Ԫ�ص�id
if isempty(thres_idx)    
  thres_idx = 1;        
else   
  thres_idx = thres_idx(1);   % ���ж��id������������ȡ�׸���Ϊ��⵽�������
end

% ����idȡ�����ݰ�
detected_packet = rx_signal(thres_idx:length(rx_signal));   