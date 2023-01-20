% singleTxSemiStaticSchwithHARQ

% this script contains the code for allocating radio resources for 
% transmissions using semi-static scheduling with HARQ 

for h=1:length(m)
    currentTime=current_time_frame(m(h));
    if ind(user)<iter && currentTime-TaOriginal(user,ind(user))>=deadtime
        flag=2;
        SegmentAllocated(user,iSegment(user,nUERx),nUERx)=0;
        while ind(user)<=iter && TaOriginal(user,ind(user))<=current_time_frame(end)
        %packet is dropped because a new packet is generated
            latency(user,ind(user))=100000; 
            ind(user)=ind(user)+segmentationFactor;
        end
        break;
    end 

% p indicates the number of non-allocated RBs in slot/minislot m(h)
    p=find(aux_frame(:,m(h))==0);
    if length(p)>=RBs_UEs(user)
        % check if there are RBs_UEs(user) RBs in slot/minislot m(h)
        % every i*Tp slots/minislots
        i=0;
        while m(h)+i*Tp/Tsymbol<=symbols_per_frame+Tp/Tsymbol
            if m(h)+i*Tp/Tsymbol<=symbols_per_frame
                flagMS=1;
                for k=0:N_OS-1
                    p=find(aux_frame(:,m(h)+k+i*Tp/Tsymbol)==0);
                    if length(p)<RBs_UEs(user)
                        flagMS=0;
                        break;
                    end
                end
            else
                flagMS=1;
                for k=0:N_OS-1
                    p=find(aux_nextframe(:,m(h)+k+i*Tp/Tsymbol-symbols_per_frame)==0);
                    if length(p)<RBs_UEs(user)
                        flagMS=0;
                        break;
                    end
                end
            end

            if flagMS==1
                i=i+1;
            else
                break;
            end
        end

        if m(h)+i*Tp/Tsymbol>symbols_per_frame
            flag=1;
            if nframes==0 && iSegment(user,nUERx)>=0
%                         disp([user,iSegment(user,nUERx), ind(user)]);
                SegmentAllocated(user,iSegment(user,nUERx),nUERx)=1;
            end
            i=0;
            % allocate radio resources
            while m(h)+i*Tp/Tsymbol<=symbols_per_frame+Tp/Tsymbol && ind(user)<=iter
                if m(h)+i*Tp/Tsymbol<=symbols_per_frame
                    for k=0:N_OS-1
                        p=find(aux_frame(:,m(h)+k+i*Tp/Tsymbol)==0);
                        aux_frame(p(1:RBs_UEs(user)),m(h)+k+i*Tp/Tsymbol)=1;
                    end
                    tend=current_time_frame(m(h)+i*Tp/Tsymbol)+N_OS*Tsymbol; %tend es igual al tiempo en que comienza el siguiente símbolo o slot según el caso
                else
                    for k=0:N_OS-1
                        p=find(aux_nextframe(:,m(h)+k+i*Tp/Tsymbol-symbols_per_frame)==0);
                        aux_nextframe(p(1:RBs_UEs(user)),m(h)+k+i*Tp/Tsymbol-symbols_per_frame)=1;
                    end
                    tend=current_time_frame(m(h)+i*Tp/Tsymbol-symbols_per_frame)+symbols_per_frame*Tsymbol+N_OS*Tsymbol; %tend es igual al tiempo en que comienza el siguiente símbolo o slot según el caso
                end
                %check if packet is received with error
                perror=rand();
                if perror<=BLER %error
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
                            [retx_time(user,ind(user),retx_index),latency(user,ind(user))]=DL_Scheduling_process(ACK_time,...
                                Tslot,TprocTx,TprocRx,TprocTxHARQ,TprocRxHARQ,...
                                latency(user,ind(user)),tsim,PDCCH_config,flag_control);
                        else
                            % NACK is transmitted in the PDCCH 
                            % PUCCH is transmitted in the first
                            % symbol of every slot
                            auxtime2=mod(auxtime,Tslot); %Tslot-auxtime2 is the allignment time
                            ACK_time=auxtime+(Tslot-auxtime2)+Tslot/14+TprocRxHARQ; %(Tslot-auxtime2) es el frame alignment hasta el siguiente slot
                            % we add the latency introduced by 
                            % the retransmission process using HARQ 
                            [retx_time(user,ind(user),retx_index),latency(user,ind(user))]=SR_Grant_process(ACK_time,...
                                Tslot,TprocTx,TprocRx,TprocTxHARQ,TprocRxHARQ,...
                                latency(user,ind(user)),tsim,PDCCH_config,PUCCH_config,flag_control);
                        end
                        t_ini(user,ind(user))=TaOriginal(user,ind(user));%nextT-TprocTx;
                        retx_index=retx_index+1;
                    else
                        latency(user,ind(user))=200000;
                    end
                else
                    % we save the latency of the last unicast transmission for a packet
                    % this is why the value of latency is overwrite with a new unicast transmission
                    latency(user,ind(user))=tend+TprocRx-TaOriginal(user,ind(user));
                end
                i=i+1;
                ind(user)=ind(user)+segmentationFactor;
                retx_index=1;
            end
            if indtoScheduleNextFrame>N*segmentationFactor*N_MC
                disp('error: cannot be higher than N');
            end
            toScheduleNextFrame(indtoScheduleNextFrame,:)=[user m(h)+i*Tp/Tsymbol-symbols_per_frame ind(user) nUERx];
            indtoScheduleNextFrame=indtoScheduleNextFrame+1;
            break;
        end
    end
end        
