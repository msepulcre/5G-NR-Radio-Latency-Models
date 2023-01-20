function RadioLatency(BW,SCS,traffic,Tp,nRBperUE,data,link_direction,...
    Nmin,Nmax,N_MC,n_rep,maxN_retx,MCS_table,v,escenario,...
    density,flagDiscardPkts,segmentationFactor,...
    PDCCH_config,PUCCH_config,flag_control,minislot_config)

% BW assigned in the cell
        %FR1 (en MHz): 5, 10, 15, 20, 25, 30, 40, 50, 60, 70, 80, 90, 100
        %FR2 (en MHz): 50, 100, 200, 400
% SCS
        %FR1 (en kHz): 15, 30, 60
        %FR2 (en kHz): 60, 120
        % SCS can take any value in [15, 30, 59, 60, 120]
        % SCS=[15, 30, 60, 120] kHz used Normal Cyclic Prefix
        % SCS=59 is used to select SCS=60 kHz with Extended Cyclic Prefix
% traffic=0 --> aperiodic; traffic=1 --> periodic
% Tp in ms --> periodic traffic: transmission period
             % aperiodic traffic: Tavg=Tp*2 Tavg=average time between packets 
% nRBperUE indicates a constant demand in terms of RBs for all UEs
            % the code allows to evaluate the scenario where all UEs demand
            % the same number of RBs
            %   if nRBperUE >0 --> data must be equal to 0
% data indicates the amount of data (in bytes) to be transmitted in a packet
            %   if data >0 --> nRBperUE must be equal to 0
            %   the number of RBs demanded by a UE (nRB) is calculated 
            %   based on the data to transmit and experienced CQI
% link_direction indicates if DL or UL 
            %   link_direction =1 --> DL
            %   link_direction =2 --> UL
% Nmin and Nmax, minimum and maximum number of UEs to simulate
% N_MC indicates the number of unicast tx performed in DL
            %     N_MC =1 if broadcast mode is considered in DL
            %     N_MC >1 if multiple unicast tx are considered in DL
% n_rep is the number of copies sent in consecutive slots (k_repetitions)
            %     n_rep=k_rep 
% maxN_retx is the maximum number of retx based on HARQ per packet
            %     if maxN_retx>0 --> n_rep=1
            %     if n_rep>1 --> maxN_retx=0
% MCS_table indicates the MCS table to use 
            %     MCS_table==1 or MCS_table==2 are used to achieve a BLER=0.1
            %     MCS_table==3 are used to achieve a BLER=0.00001
% v is the number of tx MIMO layers
% escenario 
            % 0 --> circular
            % 11 --> highway with diameter=1732m, 6 lanes per direction
            % 13 --> highway with diameter=1732m, 3 lanes per direction 
            % 12 --> highway with diameter=500m
            % 21 --> urban with diameter=500m
% density in veh/km/lane
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

    
% initial checks
if escenario==0 && Nmin==0
    disp('In scenario 0, N must be higher than 0.');
    return;
elseif escenario>0 && Nmin>0
    disp('N should be equal to 0, its value will not be considered.');
    return;
end

if escenario==21 && density==602
    density=60.2;
end

if n_rep>1 && maxN_retx>0
    disp('repetitions and retx cannot be configured at the same time');
    return;
end   
if N_MC<1
    disp('error: N_MC must equal to or higher than 1.');
    return;
%elseif N_MC>1 && n_rep>1
%    disp('error: Multiple unicast tx cannot be executed with krepetitions.');
%    return;
end    


% Initialization of other parameters
FR=1; %Frequency range
cap=2; %UE capability 

step=50;
n=Nmin:step:Nmax;

% initialize variables for results
latency_vector_avg=zeros(1,length(n));
latency_vector_max=zeros(1,length(n));
RButilization_avg_vector=zeros(1,length(n));


if traffic==0
    carp='aperiodic';
    seedMax=100; %10000
    rng('shuffle');
    flag_periodic=0;
elseif traffic==1
    carp='periodic';
    seedMax=100; %10000
    rng('shuffle');
    flag_periodic=1;
else
    disp('traffic not valid');
end

if link_direction==1
    link='DL';
elseif link_direction==2
    link='UL';
end

if MCS_table==1 || MCS_table==2
    BLER=0.1;
elseif MCS_table==3
    BLER=0.00001;
end

switch escenario
    case 0
        dir='circular';
    case 11
        if flag_control==0
            dir='highway1732';
        else
            dir='highway1732_control';
        end
    case 13
        if flag_control==0
            dir='highway1732_3lanesxdir';
        else
            dir='highway1732_3lanesxdir_control';
        end
    case 12
        dir='highway500';
    case 21
        dir='urban500';
end

if link_direction==2
%     UL is always unicast
    dir=sprintf('%s/ULUnicast',dir);
    N_MC=1;
    if maxN_retx>0
        coletilla2=sprintf('_retx%d',maxN_retx);
        dir=sprintf('%s/output_HARQ',dir);
    elseif n_rep>1
        coletilla2=sprintf('_rep%d',n_rep);
        dir=sprintf('%s/output_rep',dir);
    else
        coletilla2=sprintf('_rep%d',n_rep);
        dir=sprintf('%s/output',dir);
    end
else
    if N_MC==1
        dir=sprintf('%s/DLBroadcast',dir);
        if maxN_retx>0
            coletilla2=sprintf('_retx%d',maxN_retx);
            dir=sprintf('%s/output_HARQ',dir);
        else
            coletilla2=sprintf('_rep%d',n_rep);
            if n_rep>1
                dir=sprintf('%s/output_rep',dir);
            else
                dir=sprintf('%s/output',dir);
            end
        end
    else
        dir=sprintf('%s/multipleDLTx',dir);
        coletilla2=sprintf('_retx%d',maxN_retx);
        if maxN_retx>0
            dir=sprintf('%s/output_HARQ',dir);
        else
            dir=sprintf('%s/output',dir);
        end
    end
end

if nRBperUE>0
    if data>0
        disp('error: nRBperUE and data cannot be higher than zero in the same simulation run.');
        return;
    end
    coletilla3=sprintf('_nRBperUE%d',nRBperUE);
    dir=sprintf('%s/%s_Tp%d_nRB%d',dir,carp,Tp,nRBperUE);
else
    coletilla3=sprintf('_pkt%d',data);
    dir=sprintf('%s/%s_Tp%d_pkt%d',dir,carp,Tp,data);
end

i=0;
data=data*8; %bits
for N=Nmin:step:Nmax
    i=i+1;
    if escenario==0
        coletilla=sprintf('Tp%d_SCS%d_BW%d_%s_N%d_nDLTx%d_MCSTable%d_layers%d%s%s',Tp,SCS,BW,link,N,N_MC,MCS_table,v,coletilla2,coletilla3);
    else
        coletilla=sprintf('Tp%d_SCS%d_BW%d_%s_density%d_nDLTx%d_MCSTable%d_layers%d%s%s',Tp,SCS,BW,link,density,N_MC,MCS_table,v,coletilla2,coletilla3);
    end
    if flag_control==1
        coletilla=sprintf('%s_U%dD%d',coletilla,PUCCH_config,PDCCH_config);
    end
    if minislot_config>0
        coletilla=sprintf('%s_MS%d',coletilla,minislot_config);
    end

    dir_current=cd();
%     results are saved in dir folder
    cd(dir);

    fich=sprintf('latency_matrix_%s.txt',coletilla);
    fid=fopen(fich,'a+');
    fid3=fopen(sprintf('UE_data_%s.txt',coletilla),'a+');
    ferror=fopen(sprintf('error_%s.txt',coletilla),'a+');
    if n_rep==1
        fid2=fopen(sprintf('retx_matrix_%s.txt',coletilla),'a+');
    end
    if traffic==0
        fid4=fopen(sprintf('time_rx_pkts_%s.txt',coletilla),'a+');
        fid5=fopen(sprintf('time_sim_%s.txt',coletilla),'a+');
    end
    cd(dir_current);

    for seed=1:seedMax
        if flag_periodic==1
                [latency, RButilization_avg, retx, TRx, Tini, Tfinal]=latency_analysis_periodic(FR,...
                    BW,SCS, N, Tp, nRBperUE, link_direction, cap, seed,...
                    N_MC, n_rep, BLER, maxN_retx, traffic, MCS_table,...
                    v,data,escenario,density,fid3,flagDiscardPkts,...
                    segmentationFactor,PDCCH_config,PUCCH_config,...
                    flag_control,minislot_config,ferror);
        else
                [latency, RButilization_avg, retx, TRx, Tini, Tfinal]=latency_analysis_aperiodic(FR,...
                    BW,SCS, N, Tp, nRBperUE, link_direction, cap, seed,...
                    N_MC, n_rep, BLER, maxN_retx, traffic, MCS_table,...
                    v,data,escenario,density,fid3,flagDiscardPkts,...
                    segmentationFactor,PDCCH_config,PUCCH_config,...
                    flag_control,minislot_config,ferror);
        end
        
        latency=latency(:,1:end-1);
        [msize,nsize]=size(latency);
        for j=1:nsize
            [x,y]=find(latency(:,j)==-11);
            if length(x)==length(latency(:,j))
                continue;
            end
            fprintf(fid,'%.3f\t',latency(:,j));
            fprintf(fid,'\n');
        end
        if traffic==0
            for j=1:nsize
                [x,y]=find(TRx(:,j)==-11);
                if length(x)==length(TRx(:,j))
                    continue;
                end
                fprintf(fid4,'%.2f\t',TRx(:,j));
                fprintf(fid4,'\n');
            end
            fprintf(fid5,'%.3f\t%.3f\n',Tini,Tfinal);
        end

        if n_rep==1
            retx=retx(:,:,1);
            retx=retx(:,1:end-1);
            for j=1:nsize
                [x,y]=find(retx(:,j)==-11);
                if length(x)==length(retx(:,j))
                    continue;
                end
                fprintf(fid2,'%d\t',retx(:,j));
                fprintf(fid2,'\n');
            end
        end
        
        [x,y]=size(latency);
        latency=reshape(latency,1,x*y);
        x=find(latency>0);
        latency=latency(x);
        x=find(latency<100000);
        latency_vector_avg(i)=latency_vector_avg(i)+mean(latency(x));
        latency_vector_max(i)=max(latency_vector_max(i),max(latency(x)));
        abortedPackets(i)=(length(latency)-length(x))/length(latency)*100;
        RButilization_avg_vector(i)=RButilization_avg;
    end
    fclose(fid);
    if n_rep==1
	fclose(fid2);
    end
    fclose(fid3);
    latency_vector_avg(i)=latency_vector_avg(i)/seedMax;
    if traffic==0
        fclose(fid4);
        fclose(fid5);
    end
    
end

cd(dir);
l=textread(fich);
cd(dir_current);
[x,y]=size(l);
l=reshape(l,1,x*y);
RadioToE2Emodel(dir,dir_current,coletilla,Tp,escenario,link_direction,N_MC,traffic,...
    SCS,BW,density, MCS_table,v,n_rep,maxN_retx,data/8);

if n_rep>1
    cd(dir);
else
    cd(dir);
end
if escenario==0
    coletilla=sprintf('Tp%d_SCS%d_BW%d_%s_N%d-%d_nDLTx%d_MCSTable%d_layers%d%s%s',Tp,SCS,BW,link,Nmin,Nmax,N_MC,MCS_table,v,coletilla2,coletilla3);
else
    coletilla=sprintf('Tp%d_SCS%d_BW%d_%s_density%d_nDLTx%d_MCSTable%d_layers%d%s%s',Tp,SCS,BW,link,density,N_MC,MCS_table,v,coletilla2,coletilla3);
end
if flag_control==1
    coletilla=sprintf('%s_U%dD%d',coletilla,PUCCH_config,PDCCH_config);
end
if minislot_config>0
    coletilla=sprintf('%s_MS%d',coletilla,minislot_config);
end

% h=figure;
% hold on;
% plot(Nmin:Nmax,latency_vector_avg,'b');
% plot(Nmin:Nmax,latency_vector_max,'r');
% xlabel('Number of UE');
% ylabel('Latency (ms)');
% legend('avg','max');
% hgsave(h,sprintf('latency_%s.fig',coletilla));
fid=fopen(sprintf('latency_%s.txt',coletilla),'a+');
for i=1:length(n)
        fprintf(fid,'%d\t%.4f\t%.4f\t%.4f\t%.4f\n',n(i),latency_vector_avg(i),latency_vector_max(i),abortedPackets(i),RButilization_avg_vector(i));
end
fclose(fid);

% h=figure;
% plot(Nmin:Nmax,RButilization_avg_vector);
% xlabel('Number of UE');
% ylabel('% of RB used');
% hgsave(h,sprintf('RButilization_%s.fig',coletilla));
% fid=fopen(sprintf('RButilization_%s.txt',coletilla),'a+');
% for i=1:Nmax-Nmin+1
% 	fprintf(fid,'%d\t%.4f\n',i+Nmin-1,RButilization_avg_vector(i));
% end
% fclose(fid);
cd(dir_current);
