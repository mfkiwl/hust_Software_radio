

n1 = [1; 2 ; 3];

m1 = abs(filter(ones(1,2), 1, n1));  % m1 = [1;3;5]


n3 = [1 ; 2 ; 3 ; 4 ; 5];

m3 = abs(filter(ones(1,2), 1, n3));  % m3 = [1;3;5;7;9]  �������ͬά��
% 1*0 + 1*1 = 1
% 1*1 + 1*2 = 3
% 1*2 + 1*3 = 5
% 1*3 + 1*4 = 7
% 1*4 + 1*5 = 9


n2 = [1  2  3];

m2 = abs(filter(ones(1,2), 1, n2));  % m2 = [1 2 3]