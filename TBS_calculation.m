function [tbs]=TBS_calculation(R,Qm,v,nPRB,link,SCS,BW,CP,PDCCH_config,PUCCH_config,N_OS,NRB)

% M.C. Lucas-Estañ, B. Coll-Perales, T. Shimizu, J. Gozalvez, 
% T. Higuchi, S. Avedisov, O. Altintas, M. Sepulcre, 
% "An Analytical Latency Model and Evaluation of the Capacity of 5G NR to 
% Support V2X Services using V2N2V Communications", 
% in IEEE Transactions on Vehicular Technology.

% We evaluate three configurations for the number of RBs reserved for the 
% transmission of control messages. The first one is the baseline 
% configuration (conf.1) in Annex A of [20] (Section IV). The second 
% configuration (conf.2) increases the number of RBs reserved for PDCCH 
% and PUCCH by a factor of 6 and 8 respectively. We consider the third 
% ideal scenario (conf.3) where the control messages can always be 
% transmitted in the next PDCCH or PUCCH after being generated. 
    % conf.1: flag_control=1, PDCCH_config=1, PUCCH_config=1
    % conf.2: flag_control=1, PDCCH_config=3, PUCCH_config=3
    % conf.3: flag_control=0, PDCCH_config=1, PUCCH_config=1

% [20]	ITU Radiocommunication Study Groups, “Final Evaluation Report 
% from the 5G Infrastructure Association on IMT-2020 Proposals IMT-2020/14, 
% 15, 16 parts of 17”, Document 5D/50-E, Feb. 2020.



% TS 38.214 V16.4.0 (2020-12)
% Table 5.1.3.2-1 TBS for Ninfo<=3824
Index_1=1:93;
TBS_1=[24 32 40 48 56 64 72 80 88 96 104 112 120 128 136 144 152 160 168 ... 
176 184 192 208 224 240 256 272 288 304 320 336 352 368 384 408 432 456 ...
480 504 528 552 576 608 640 672 704 736 768 808 848 888 928 984 1032 1064 ...
1128 1160 1182 1224 1256 1288 1320 1352 1416 1480 1544 1608 1672 1736 1800 ...
1864 1928 2024 2088 2152 2216 2280 2408 2472 2536 2600 2664 2728 2792 2856 ...
2976 3104 3240 3368 3496 3624 3752 3824];


Nsc_RB=12; %12 subportadoras por RB

Nsymb_sh=N_OS;
% switch CP
%     case 'NCP'
%         Nsymb_sh=14; %number of symbols of the PDSCH allocation within the slot
%              %entiendo que es el número de simbolos asignados dentro de un
%              %slot (max 14 or 12) 
%     case 'ECP'
%         Nsymb_sh=12; 
% end
             
OH_avg=0;

% number of OS and RB reserved for control messages (PDCCH and PUCCH)
switch PDCCH_config
    case 1
        PDCCH_RBs=12;
        PDCCH_symbols=1;
    case 2
        PDCCH_RBs=24;
        PDCCH_symbols=1;
    case 3
        PDCCH_RBs=24;
        PDCCH_symbols=3;
    case 4
        PDCCH_RBs=36;
        PDCCH_symbols=3;
    case 5
        PDCCH_RBs=48;
        PDCCH_symbols=3;
    case 9  %unlimited capacity: consideramos la configuraciÃ³n en referencia
        PDCCH_RBs=12;
        PDCCH_symbols=1;
end
switch PUCCH_config
    case 1
        PUCCH_RBs=2;
        PUCCH_symbols=4;
    case 2
        PUCCH_RBs=4;
        PUCCH_symbols=4;
    case 3
        PUCCH_RBs=8;
        PUCCH_symbols=4;
end

% [NRB,Tslot,num]=RB_definition(1,SCS,BW,minislot_config,CP);
if link=='DL'
    switch CP
        case 'NCP'
            switch N_OS
                case 14 %full-slot transmission
                    NDMRS_PRB=16; % number of REs for DM-RS per PRB in the scheduled duration 
                             % including the overhead of the DM-RS CDM groups without data, 
                             % as indicated by DCI format 1_1 or format 1_2 or as described 
                             % for format 1_0 in Clause 5.1.6.2
                case 7
                    NDMRS_PRB=8;
                case 4
                    NDMRS_PRB=4;
                case 2
                    NDMRS_PRB=4;
            end
        case 'ECP'
            switch N_OS
                case 12 %full-slot transmission
                    NDMRS_PRB=12;
                case 6
                    NDMRS_PRB=8;
                case 4
                    NDMRS_PRB=4;
                case 2
                    NDMRS_PRB=4;
            end
    end
%     average overhead per PRB incorporated by CSI-RS and PDCCH
%     este es un términos que yo incorporo al cómputo del tbs para tener en
%     cuenta el efecto de considerar esas señales y canales

%     el overhead se calcula sobre 20 slots
%     CSI-RS NZP & CSI-IM: 8 RE/RB/slot & 4 RE/RB/slot in all RBs each 20 slots
%       12*NRB
%     CSI-RS (TRS): 12 RE/RB/slot in 52 RBs each 20 slots
%       12*52
%     PDCCH: 1 CORESET/slot with 12 x 12 subcarriers x 1 symbol) in all subframes 
%       PDCCH_RBs*12*PDCCH_symbols*20
%     El total de REs disponibles en 20 slots es 12*NRB*14*20
%     OH_avg = ceil((12*NRB+12*52+PDCCH_symbols*12*PDCCH_symbols*20)*12*N_OS/(12*NRB*14*20));
    OH_avg = ceil((12*NRB+12*52+PDCCH_RBs*12*PDCCH_symbols*20)*N_OS/(NRB*14*20));
    
else
    switch CP
        case 'NCP'
            switch N_OS
                case 14 %full-slot transmission
                    NDMRS_PRB=12;
                case 7
                    NDMRS_PRB=8;
                case 4
                    NDMRS_PRB=4;
                case 2
                    NDMRS_PRB=4;
            end
        case 'ECP'
            switch N_OS
                case 12 %full-slot transmission
                    NDMRS_PRB=12;
                case 6
                    NDMRS_PRB=8;
                case 4
                    NDMRS_PRB=4;
                case 2
                    NDMRS_PRB=4;
            end
    end
%     el overhead se calcula sobre 10 slots
%     PUCCH: 2 RB in 4 symbols in each slot in all subframes
%       PUCCH_RBs*12*PUCCH_symbols*10
%     SRS: 12 RE/RB in all RBs of 1 symbol each 10 slots
%       12*NRB*1
%     El total de REs disponibles en 10 slots es 12*NRB*14*10
%     OH_avg = ceil((12*NRB+PUCCH_RBs*12*PUCCH_symbols*10)*12*N_OS/(12*NRB*14*10));
    OH_avg = ceil((12*NRB+PUCCH_RBs*12*PUCCH_symbols*10)*N_OS/(NRB*14*10));
end   
    
Noh_PRE=0; % overhead configured by higher layer parameter xOverhead in 
           % PDSCH-ServingCellConfig          
           % If the xOverhead in PDSCH-ServingCellconfig is not configured 
           % (a value from 0, 6, 12, or 18), the   is set to 0. If the 
           % PDSCH is scheduled by PDCCH with a CRC scrambled by SI-RNTI, 
           % RA-RNTI, MsgB-RNTI or P-RNTI,   is assumed to be 0.
% nPRB=1; % total number of allocated PRBs for the UE
           
NREprima=Nsc_RB*Nsymb_sh-NDMRS_PRB-Noh_PRE-OH_avg;
NRE=min(156,NREprima)*nPRB;

Ninfo=NRE*R*Qm*v; % intermediate number of information bits
if Ninfo<=3824
    n=max(3,floor(log2(Ninfo))-6);
    Ninfoprima=max(24,(2^n)*floor(Ninfo/(2^n)));
    [xf]=find(TBS_1>=Ninfoprima);
    tbs=TBS_1(xf(1));
    index=Index_1(xf(1));
else
    n=floor(log2(Ninfo-24))-5;
    Ninfoprima=max(3840,(2^n)*round((Ninfo-24)/(2^n)));
    
    if R<=0.25
        C=ceil((Ninfoprima+24)/3816);
        tbs=8*C*ceil((Ninfoprima+24)/(8*C))-24;
    else
        if Ninfoprima>8424
            C=ceil((Ninfoprima+24)/8424);
            tbs=8*C*ceil((Ninfoprima+24)/(8*C))-24;
        else
            tbs=8*ceil((Ninfoprima+24)/8)-24;
        end
    end
end
