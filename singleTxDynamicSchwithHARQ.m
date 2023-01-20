% singleTxDynamicSchwithHARQ

% retx indicates if a packet is retransmitted
retx=zeros(N,iter,N_MC);
% retx_time indicates the time when a packet is retransmitted
retx_time=100000*ones(N,iter,N_MC);
fretx_GB=zeros(N,iter);
t_ini=-1000*ones(N,iter);

RButilization_avg=0;
nframes=0;
currentTime=0;
flag=0;
while 1
%   the next UE to be served is the one that generates the next packet  
    [nextPacketperUser,iTb]=min(Tb,[],1);
    [nextT,user]=min(nextPacketperUser);
    if nextT>=tsim
      break;
    end
    if flagDiscardPkts==1 && TaOriginal(user,ind(user)+1)>=tsim
      break;
    end
    ind(user)=iTb(user);
    if ind(user)>=iter
      break;
    end

    retx_index=1;
    if latency(user,ind(user))>=300000
        Tb(ind(user),user)=4*tsim;
        continue;
    end

    for nUERx=1:N_MC
        if 1    %all RBs are allocated in the same symbols
            fretx=0;
            flag=0;
            while 1
                m=find(current_time_frame>=nextT);
                [n,p]=find(current_frame(:,m)==0);
                if isempty(m) || isempty(n)
                    if strcmp(scheduling,'GF')
                        [retx,retx_time,current_frame,latency,flag,fretx]=schedule_retxs(retx,...
                            retx_time,current_frame,current_time_frame,...
                            next_frame,frame_l,TaOriginal',latency,t_ini,...
                            RBs_UEs,Tslot,iter,TprocRx,TprocTx,BLER,N_MC,...
                            maxN_retx,Tp,flagDiscardPkts,deadtime,scheduling,...
                            N_OS,symbPerSlot);
                    end
                    past_frame=current_frame;
                    current_frame=next_frame;
                    next_frame=zeros(NRB,symbols_per_frame);%remember that 
                        % symbols_per_frame is equal to symbols_per_frame 
                        % when full-slot txs are considered
                    current_time_frame=current_time_frame+frame_l;
                    if traffic==0 && nframes<limInf
                        nframes=nframes+1;
                    else
                        nframes=nframes+1;
                        RButilization_avg=RButilization_avg+sum(sum(past_frame))/(slots_per_frame*symbPerSlot*NRB);
                    end
                    if flagControl
                        if link_direction==1
                        %     we reserve RBs for the SS/PBCH --> 1 block transmitted each 20
                        %     slots. Each block is composed of 240 subcarriers x 4 OFDM symbols
                            i_SSB=i_SSB-symbols_per_frame;
                            while i_SSB<=symbols_per_frame
                                next_frame(1:20,i_SSB:i_SSB+factor)=1;
                                i_SSB=i_SSB+20*symbPerSlot;
                            end
                        elseif link_direction==2
                            i_RACH=i_RACH-slots_per_frame;
                            while i_RACH<=slots_per_frame
                                iaux=0;
                                while iaux<slotsperms
                                    i_RACHaux=(i_RACH-1+iaux)*symbPerSlot+1;
                                    next_frame(1:12,i_RACHaux:i_RACHaux+factor)=1;
                                    iaux=iaux+1;
                                end
                                %next_frame(1:12,i_RACH:i_RACH+slotsperms-1)=1;
                                i_RACH=i_RACH+5*slotsperms;
                            end
                        end
                    end
                else
                    if strcmp(scheduling,'GB') && nUERx==1 && fretx_GB(user,ind(user))==1
                        fretx_GB(user,ind(user))=0;
                        [retx(user,ind(user),:), retx_time(user,ind(user),:),...
                            current_frame, latency(user,ind(user)), flag,...
                            fretx]=schedule_retxs(retx(user,ind(user),:),...
                            retx_time(user,ind(user),:), current_frame,...
                            current_time_frame, next_frame, frame_l,...
                            TaOriginal(user,ind(user):end)', latency(user,ind(user)),...
                            t_ini(user,ind(user)), RBs_UEs(user), Tslot,...
                            iter, TprocRx, TprocTx, BLER, N_MC, maxN_retx, Tp,...
                            flagDiscardPkts, deadtime, scheduling, N_OS, symbPerSlot);
                        if flag==2 || sum(retx_time(user,ind(user),:))==N_MC*100000
                            Tb(ind(user),user)=4*tsim;
                        else
                        	Tb(ind(user),user)=retx_time(user,ind(user),1);
                            fretx_GB(user,ind(user))=1;
                        end
                        flag=2;
                        break;
                    else
                        if flagDiscardPkts==1
                            deadtime=TaOriginal(user,ind(user)+1)-TaOriginal(user,ind(user));
                        end
                        [current_frame,tend,flag,fretx]=schedule_tx(nextT,ind(user),...
                            user,current_frame,current_time_frame,TaOriginal',...
                            RBs_UEs(user),Tslot/symbPerSlot,iter,BLER,Tp,deadtime,N_OS);
                        if flag==2
                            latency(user,ind(user))=100000;
%                             ind(user)=ind(user)+1;
%                             if ind(user)>iter
%                                 return;
%                             end
                            Tb(ind(user),user)=4*tsim;
                            break;
                        end
                    
                        if fretx==1
                            retx(user,ind(user),retx_index)=retx(user,ind(user),retx_index)+1;
                            if retx(user,ind(user),retx_index)<=maxN_retx
                                auxtime=tend+TprocRx+TprocTxHARQ;
                                if link_direction==1
                                    % NACK is transmitted in the PUCCH 
                                    % PUCCH is transmitted in the last
                                    % symbol of every slot
                                    ACK_time=ceil(auxtime/Tslot)*Tslot+TprocRxHARQ;
                                    % we add the latency introduced by 
                                    % the retransmission process using HARQ 
                                    [retx_time(user,ind(user),retx_index),latency(user,ind(user))]=DL_Scheduling_process(ACK_time,Tslot,TprocTx,TprocRx,TprocTxHARQ,TprocRxHARQ,latency(user,ind(user)),tsim,PDCCH_config,flag_control);
                                else
                                    % NACK is transmitted in the PDCCH 
                                    % PUCCH is transmitted in the first
                                    % symbol of every slot
                                    auxtime2=mod(auxtime,Tslot); %Tslot-auxtime2 is the allignment time
                                    ACK_time=auxtime+(Tslot-auxtime2)+Tslot/14+TprocRxHARQ; %(Tslot-auxtime2) es el frame alignment hasta el siguiente slot
                                    % we add the latency introduced by 
                                    % the retransmission process using HARQ 
                                    [retx_time(user,ind(user),retx_index),latency(user,ind(user))]=SR_Grant_process(ACK_time,Tslot,TprocTx,TprocRx,TprocTxHARQ,TprocRxHARQ,latency(user,ind(user)),tsim,PDCCH_config,PUCCH_config,flag_control);
                                end
                                t_ini(user,ind(user))=TaOriginal(user,ind(user));%nextT-TprocTx;
                                if strcmp(scheduling,'GB')
                                    Tb(ind(user),user)=retx_time(user,ind(user),retx_index);
                                    fretx_GB(user,ind(user))=1;
                                end
                                retx_index=retx_index+1;
                            end
                        end
                        if flag==0
                            if flagDiscardPkts==1
                                deadtime=TaOriginal(user,ind(user)+1)-TaOriginal(user,ind(user));
                            end
                            [next_frame,tend,flag,fretx]=schedule_tx(nextT,ind(user),user,next_frame,current_time_frame+frame_l,TaOriginal',RBs_UEs(user),Tslot/symbPerSlot,iter,BLER,Tp,deadtime,N_OS);
                            if flag==2
                                latency(user,ind(user))=100000;
                                Tb(ind(user),user)=4*tsim;
                                break;
                            end
                            if fretx==1
                                retx(user,ind(user),retx_index)=retx(user,ind(user),retx_index)+1;
                                if retx(user,ind(user),retx_index)<=maxN_retx
                                    auxtime=tend+TprocRx+TprocTxHARQ;
                                    if link_direction==1
                                        % NACK is transmitted in the PUCCH 
                                        % PUCCH is transmitted in the last
                                        % symbol of every slot
                                        ACK_time=ceil(auxtime/Tslot)*Tslot+TprocRxHARQ;
                                        % we add the latency introduced by 
                                        % the retransmission process using HARQ 
                                        [retx_time(user,ind(user),retx_index),latency(user,ind(user))]=DL_Scheduling_process(ACK_time,Tslot,TprocTx,TprocRx,TprocTxHARQ,TprocRxHARQ,latency(user,ind(user)),tsim,PDCCH_config,flag_control);
                                    else
                                        % NACK is transmitted in the PDCCH 
                                        % PUCCH is transmitted in the first
                                        % symbol of every slot
                                        auxtime2=mod(auxtime,Tslot);
                                        ACK_time=auxtime+(Tslot-auxtime2)+Tslot/14+TprocRxHARQ; %(Tslot-auxtime2) es el frame alignment hasta el siguiente slot
                                        % we add the latency introduced by 
                                        % the retransmission process using HARQ 
                                        [retx_time(user,ind(user),retx_index),latency(user,ind(user))]=SR_Grant_process(ACK_time,Tslot,TprocTx,TprocRx,TprocTxHARQ,TprocRxHARQ,latency(user,ind(user)),tsim,PDCCH_config,PUCCH_config,flag_control);
                                    end
                                    t_ini(user,ind(user))=TaOriginal(user,ind(user));%nextT-TprocTx;
                                    if strcmp(scheduling,'GB')
                                        Tb(ind(user),user)=retx_time(user,ind(user),retx_index);
                                        fretx_GB(user,ind(user))=1;
                                    end
                                    retx_index=retx_index+1;
                                end
                            end
                        end
                        if flag==0
                            disp('error: you should not be here');
                        end
                    end
                    break;
                end
            end
        end
        if flag==2
            break;
        end
    end
    if flag==2
        continue;
    end
    aux=0;
    if fretx_GB(user,ind(user))==0
        retx_index=1;
        while retx_index<=N_MC && retx(user,ind(user),retx_index)<=maxN_retx
            retx_index=retx_index+1;
        end
        if retx_index<=N_MC
            latency(user,ind(user))=200000;
        else
    %         latency(user,ind(user))=TprocTx+(tend-nextT)+TprocRx;
            latency(user,ind(user))=tend+TprocRx-TaOriginal(user,ind(user));
        end
        Tb(ind(user),user)=4*tsim;
    end
end
