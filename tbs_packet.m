function [tbs, nPRB]=tbs_packet(data,indMCS,MCS_table,v,link,SCS,BW,CP,PDCCH_config,PUCCH_config,N_OS,NRB)
% data: amount of data to be transmitted in the packet
% indMCS: index to the vector of Imcs in the corresponding MCS table 

% Table 5.1.3.1-2: MCS index table 2 for PDSCH and 
% Table 5.1.3.1-3: MCS index table 3 for PDSCH in 3GPP TS 38.214 V16.4.0 (2020-12)
Imcs=0:31;
Qm_Table3=[2*ones(1,15) 4*ones(1,6) 6*ones(1,8) 2 4 6];
R_Table3=[30 40 50 64 78 99 120 157 193 251 308 379 449 526 602 340 378 434 ...
    490 553 616 438 466 517 567 616 666 719 772 NaN NaN NaN]./1024;
SE_Table3=[0.0586 0.0781 0.0977 0.1250 0.1523 0.1934 0.2344 0.3066 0.3770 ...
    0.4902 0.6016 0.7402 0.8770 1.0273 1.1758 1.3281 1.4766 1.6953 1.9141 ...
    2.1602 2.4063 2.5664 2.7305 3.0293 3.3223 3.6094 3.9023 4.2129 4.5234 ...
    NaN NaN NaN];

Qm_Table2=[2*ones(1,5) 4*ones(1,6) 6*ones(1,9) 8*ones(1,8) 2 4 6 8];
R_Table2=[120 193 308 449 602 378 434 490 553 616 658 466 517 567 616 ...
    666 719 772 822 873 682.5 711 754 797 841 885 916.5 948 NaN NaN NaN NaN]./1024;
SE_Table2=[0.2344 0.3770 0.6016 0.8770 1.1758 1.4766 1.6953 1.9141 2.1602 ...
    2.4063 2.5703 2.7305 3.0293 3.3223 3.6094 3.9023 4.2129 4.5234 4.8164 ...
    5.1152 5.3320 5.5547 5.8906 6.2266 6.5703 6.9141 7.1602 7.4063 NaN ...
    NaN NaN NaN];

if MCS_table==2
    R=R_Table2;
    Qm=Qm_Table2;
    SE=SE_Table2;
elseif MCS_table==3
    R=R_Table3;
    Qm=Qm_Table3;
    SE=SE_Table3;
end
nPRB=0;
tbs=0;
while tbs<data
    nPRB=nPRB+1;
    tbs=TBS_calculation(R(indMCS),Qm(indMCS),v,nPRB,link,SCS,BW,CP,PDCCH_config,PUCCH_config,N_OS,NRB);
end
