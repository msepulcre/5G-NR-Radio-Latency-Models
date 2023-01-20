function [Tproc1,Tproc2]=processingTimeParameters(num,cap)

% based on Table 5.7.1.1.2-1 and Table 5.7.1.1.1-1 in 3GPP TR 37.910 V16.1.0 (2019-09), 
% Tproc2 and Tproc1 are equal for DL and UL, that is, when the BS and 
% the UE are Tx or Rx

% PUSCH preparation time N2 [symbols], see 3GPP TS 38.214 v16.4.0 (12-2020)
% UE capability 1
N1_1=[8 10 17 20];
N2_1=[10 12 23 36];
% UE capability 2
N1_2=[3 4.5 9 NaN];
N2_2=[5 5.5 11 NaN];

if cap==1
    N1=N1_1(num+1);
    N2=N2_1(num+1);
elseif cap==2
    N1=N1_2(num+1);
    N2=N2_2(num+1);
else
    disp('numerology value is not valid');
end

Tc=1/(480000*4096); % see eq.(3) in 'Final Evaluation Report from the 
                    % 5G Infrastructure Association on IMT-2020 Proposals IMT-2020'
k=64;
Tproc2=max(N2*(2014+144)*k*(2^-num)*Tc,0);
Tproc1=N1*(2048+144)*k*(2^-num)*Tc;
