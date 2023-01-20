function [latency, RButilization_avg, retx, TRx, Tini, Tfinal]=latency_analysis_aperiodic(FR,BW,SCS,...
    N, Tp, nRBperUE,link_direction, cap, seed,...
    N_MC, n_rep, BLER, maxN_retx, traffic, MCS_table,...
    v,data,escenario,density,fidUE,...
    flagDiscardPkts,segmentationFactor,...
    PDCCH_config,PUCCH_config,flag_control,minislot_config,ferror)
%FR
    %FR1: 410 MHz- 7125 MHz
    %FR2: 24250 MHz- 52600 MHz
% BW assigned in the cell
    %FR1 (en MHz): 5, 10, 15, 20, 25, 30, 40, 50, 60, 70, 80, 90, 100
    %FR2 (en MHz): 50, 100, 200, 400
%SCS
    %FR1 (en kHz): 15, 30, 60
    %FR2 (en kHz): 60, 120
        % SCS can take any value in [15, 30, 59, 60, 120]
        % SCS=[15, 30, 60, 120] kHz used Normal Cyclic Prefix
        % SCS=59 is used to select SCS=60 kHz with Extended Cyclic Prefix
% N is the number of UEs
% Tp in ms --> periodic traffic: transmission period
             % aperiodic traffic: Tavg=Tp*2 Tavg=average time between packets 
% nRBperUE indicates a constant demand in terms of RBs for all UEs
    % the code allows to evaluate the scenario where all UEs demand
    % the same number of RBs
    %   if nRBperUE >0 --> data must be equal to 0
% link_direction indicates if DL or UL comm
    %   link_direction=1 --> DL
    %   link_direction=2 --> UL
% cap is the UE processing capability 1 or 2
% seed for random numbers
% N_MC indicates the number of unicast tx performed in DL
    %     N_MC =1 if broadcast mode is considered in DL
    %     N_MC >1 if multiple unicast tx are considered in DL
% n_rep is the number of copies sent in consecutive slots (k_repetitions)
    %     n_rep=k_rep 
% BLER
% maxN_retx is the maximum number of retx based on HARQ per packet
    %     if maxN_retx>0 --> n_rep=1
    %     if n_rep>1 --> maxN_retx=0
% traffic --> aperiodic; traffic=1 --> periodic
% MCS_table indicates the MCS table to use 
    %     MCS_table==1 or MCS_table==2 are used to achieve a BLER=0.1
    %     MCS_table==3 are used to achieve a BLER=0.00001
% v is the number of tx MIMO layers
% data indicates the amount of data (in bits) to be transmitted in a packet
    %   if data >0 --> nRBperUE must be equal to 0
    %   the number of RBs demanded by a UE (nRB) is calculated 
    %   based on the data to transmit and experienced CQI
% escenario 
    % 0 --> circular
    % 11 --> highway with diameter=1732m, 6 lanes per direction
    % 13 --> highway with diameter=1732m, 3 lanes per direction 
    % 12 --> highway with diameter=500m
    % 21 --> urban with diameter=500m
% density in veh/km/lane
% fidUE: file to save data
% flagDiscardPkts=1, packets are discarded when the next packet is
            % generated
% segmentationFactor don't used yet
% PDCCH_config,PUCCH_config
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
% flag_control
            % =0 there are infinite capacity to transmit control messages
            % =1 we reserve a finite number of radio resources for the
            % transmission of control messages based on values 
            % PDCCH_config and PUCCH_config
            % see function TBS_calculation.m for additional details on the
            % configuration of PDCCH_config,PUCCH_config, and flag_control
% minislot_config
    % 0: full-slot tx
    % 1: 7-OS non-slot tx (NCP) or 6-OS non-slot tx (ECP)
    % 2: 4-OS non-slot tx
    % 3: 2-OS non-slot tx
% ferror: file to log errors


deadtime=Tp;
iter=30;
tsim=Tp*iter*4;
scheduling='GB'; %Grant-based (Dynamic)
limInf=1;
Tini=limInf*Tp;
frame_l=8*Tp;    


if SCS==59
    SCS=60;
    CP='ECP';
else
    CP='NCP';
end
            
            
% number of RBs per slot (NRB) and the time duration of a slot 
% based on the numerology (Tslot), numerology (num), number of symbols used
% for transmit a packet (N_OS), number of OFDM symbols per slot
% (symbPerSlot)
[NRB,Tslot,num,N_OS,symbPerSlot]=RB_definition(FR,SCS,BW,minislot_config,CP);
slots_per_frame=frame_l/Tslot;

% To estimate processing times at the rx and tx
[Tproc1,Tproc2]=processingTimeParameters(num,cap);

if link_direction==1
    link='DL';
    % Tproc,2 is defined in Section 6.4 of TS 38.214 v16.4.0 (12-2020): d2,1= d2,2= d2,3=0
    TprocTx=Tproc2/2;
    TprocRx=Tproc1/2;
    TprocTxHARQ=Tproc1/2;
    TprocRxHARQ=Tproc2/2;
elseif link_direction==2
    link='UL';
    TprocTx=Tproc2/2;
    TprocRx=Tproc1/2;
    TprocTxHARQ=Tproc1/2;
    TprocRxHARQ=Tproc2/2;
else
    disp('please, indicate a good link option DL (1) or UL (2)');
    return;
end

if data>0
%     distribute vehicles in the cell
    [UEdistToBS,N,Rcell]=set_user_location(escenario,N,density);
%     established experienced CQI based on the distance of the UE to the gNB
    CQI_UEs=calculate_CQI(UEdistToBS,Rcell);
%     calculate the transport block size and number of RBs necessary for
%     each packet to transmit a packet with data
    [tbs_UEs, RBs_UEs]=calculate_nRBs_perUE(data,N,CQI_UEs,MCS_table,v,link_direction,SCS,BW,CP,PDCCH_config,PUCCH_config,N_OS,NRB);
    x=find(RBs_UEs>NRB);
    if ~isempty(x)
        fprintf(ferror,'UEs demand a higher number of RBs than available per slot\n');
        fprintf(ferror,'%d\t',x);
        fprintf(ferror,'\n');
    end
    fprintf(fidUE,'%d\t',UEdistToBS);
	fprintf(fidUE,'\n');
    fprintf(fidUE,'%d\t',CQI_UEs);
	fprintf(fidUE,'\n');
    fprintf(fidUE,'%d\t',tbs_UEs);
	fprintf(fidUE,'\n');
    fprintf(fidUE,'%d\t',RBs_UEs);
	fprintf(fidUE,'\n');
else
    RBs_UEs=nRBperUE*ones(N,1);
end

% ind indicates the next packet to allocate resources for each user
ind=ones(1,N);
% latency save the latency experienced by each packet
latency=-11*ones(N,iter);

% Ta contains the generation time instant for the packets for all UEs
Ta=packet_gen(N,Tp,iter,seed,Tslot,traffic,density,segmentationFactor);
Ta=[Ta tsim*2*ones(N,1)];
% TaOriginal saves the generation time instant for the packets for all UEs
% because Ta will be modified
TaOriginal=Ta;
switch scheduling
    case 'GF'
%         if semi-static (or grant-free) scheduling is used, we sum the
%         processing time in the transmitter
        Ta=Ta+TprocTx;
    case 'GB'
        % we add the latency introduced in the dynamic scheduling process
        if link_direction==2 %'UL'
            [Ta,latency]=SR_Grant_process(Ta,Tslot,TprocTx,TprocRx,TprocTxHARQ,TprocRxHARQ,latency,tsim,PDCCH_config,PUCCH_config,flag_control);
        else %'DL'
            [Ta,latency]=DL_Scheduling_process(Ta,Tslot,TprocTx,TprocRx,TprocTxHARQ,TprocRxHARQ,latency,tsim,PDCCH_config,flag_control);
        end
end
Tb=Ta';

%initialize variables based on minislot_config
set_frames_variables;

flagControl=1;
if flagControl
    if link_direction==1
    %     we reserve radio resources for control channels and phy signals
    %     SS/PBCH --> 1 block transmitted each 20 slots. 
    %     Each block is composed of 240 subcarriers x 4 OFDM symbols
    %     worse case: we reserve one slot in 240 subcarriers
        if minislot_config==0
            N_OS=1;
            symbPerSlot=1;
            factor=0;
        else
            factor=4-1;
        end
        symbols_per_frame=slots_per_frame*symbPerSlot;
        i_SSB=1;
        if NRB>=20
            while i_SSB<=symbols_per_frame
                current_frame(1:20,i_SSB:i_SSB+factor)=1;
                i_SSB=i_SSB+20*symbPerSlot;
            end
            i_SSB=i_SSB-symbols_per_frame;
            while i_SSB<=symbols_per_frame
                next_frame(1:20,i_SSB:i_SSB+factor)=1;
                i_SSB=i_SSB+20*symbPerSlot;
            end
        else
            disp('There is not enough RBs for the SS/PCBH block');
        end
    elseif link_direction==2
%         reserve radio resources for RACH
        if minislot_config==0
            N_OS=1;
            symbPerSlot=1;
            factor=0;
        else
            factor=6-1;
        end
        symbols_per_frame=slots_per_frame*symbPerSlot;
        i_RACH=1;
        if NRB>=12
            slotsperms=1/Tslot; %number of slots per subframe of duration 1ms
            while i_RACH+slotsperms-1<=slots_per_frame
                iaux=0;
                while iaux<slotsperms
                    i_RACHaux=(i_RACH-1+iaux)*symbPerSlot+1;
                    current_frame(1:12,i_RACHaux:i_RACHaux+factor)=1;
                    iaux=iaux+1;
                end
                %current_frame(1:12,i_RACH:i_RACH+slotsperms-1)=1;
                i_RACH=i_RACH+5*slotsperms;
            end
            i_RACH=i_RACH-slots_per_frame;
            while i_RACH<=slots_per_frame
                iaux=0;
                while iaux<slotsperms
                    i_RACHaux=(i_RACH-1+iaux)*symbPerSlot+1;
                    next_frame(1:12,i_RACHaux:i_RACHaux+factor)=1;
                    iaux=iaux+1;
                end
%                 next_frame(1:12,i_RACH:i_RACH+slotsperms-1)=1;
                i_RACH=i_RACH+5*slotsperms;
            end
        else
            disp('There is not enough RBs for the PRACH block');
        end
    end
end

%%%%%%%%%%%%
if n_rep>1
    krepetitionsDynamicSch;
else
    singleTxDynamicSchwithHARQ;
end
%%%%%%%%%%%%


%%%%%%%%%
if traffic==0
	nframes=nframes-limInf; 
end
RButilization_avg=RButilization_avg/nframes*100;

TaOriginal=TaOriginal(:,1:end-1);
TRx=TaOriginal+latency;
    
[x,y]=find(latency==300000);
for i=1:length(x)
    TRx(x(i),y(i))=300000;
end

[x,y]=find(latency==200000);
for i=1:length(x)
    TRx(x(i),y(i))=200000;
end
[x,y]=find(latency==100000);
for i=1:length(x)
    TRx(x(i),y(i))=100000;
end
[x,y]=find(latency==-11);
for i=1:length(x)
    TRx(x(i),y(i))=-11;
end
[x,y]=find(TaOriginal<limInf*Tp);
for i=1:length(x)
    TRx(x(i),y(i))=-11;
    latency(x(i),y(i))=-11;
    retx(x(i),y(i))=-11;
end
[x,y]=size(TRx);
tt=reshape(TRx,1,x*y);
[x,y]=find(tt<100000);
Tfinal=max(tt(y));
