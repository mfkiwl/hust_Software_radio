function fine_time_est = finetimesync(transmit,longTrain);
        i_matrix=zeros(64,1);
        j_matrix=zeros(71,1);
        for j=150:220    %��ȷ��ͬ��λ����160+32+1����ѡ��Χ����193
        for i=1:64       %��ѵ�����е�64λ
            i_matrix(i)=transmit(j-1+i).*conj(longTrain(i)); %���������볤ѵ�����й������
            j_matrix(j-149)=j_matrix(j-149)+i_matrix(i);    %��ÿһ��bitΪ��ʼ�����һ����
        end
        end
        [a,b] = max(abs(j_matrix));        %������ģ���س̶����
        fine_time_est = 149 +b;