function [retx,retx_time,current_frame,latency,flag,fretx]=schedule_retxs(retx,retx_time,current_frame,current_time_frame,next_frame,frame_l,Tb,latency,t_ini,nRBperUE,Tslot,iter,TprocRx,TprocTx,BLER,N_MC,maxN_retx,Tp,flagDiscardPkts,deadtime,scheduling,N_OS,symbPerSlot)
% this function schedules pending retransmissions of packets received with
% error if HARQ is used

if N_MC>1
    [x,y]=find(retx_time(:,:,2)<100000);
else
    x=[];
    y=[];
end
% We order from lowest to largest according to the time of retx
% of each copy sent for different unicast tx for a UE
for i=1:length(x)
    [retx_time(x(i),y(i),:),ind]=sort(retx_time(x(i),y(i),:));
    retx(x(i),y(i),:)=retx(x(i),y(i),ind);
end
aux_time=retx_time;
aux=aux_time(:,:,1);
flag=0;
fretx=0;
while 1
    [x,i]=min(aux);
    [y,ind_user]=min(x);
    if y==100000
        return;
    end
    user=i(ind_user);
    nextT=aux(user,ind_user);
    
    flag=0;
    if flagDiscardPkts==1
        deadtime=Tb(ind_user+1,user)-Tb(ind_user,user);
    end
%     transmit the packet
    [current_frame,tend,flag,fretx]=schedule_tx(nextT,ind_user,user,current_frame,current_time_frame,Tb,nRBperUE(user),Tslot/symbPerSlot,iter,BLER,Tp,deadtime,N_OS);

    if flag==0
        if strcmp(scheduling,'GF')
            if N_MC>1 && aux_time(user,ind_user,2)<100000
                aux_time(user,ind_user,1)=100000;
                [aux_time(user,ind_user,:),ind]=sort(aux_time(user,ind_user,:));
                retx_time(user,ind_user,:)=retx_time(user,ind_user,ind);
                retx(user,ind_user,:)=retx(user,ind_user,ind);
                aux(user,ind_user)=aux_time(user,ind_user,1);
            else            
                aux(user,ind_user)=100000;
            end
        else
            [current_frame,tend,flag,fretx]=schedule_tx(nextT,ind_user,user,next_frame,current_time_frame+frame_l,Tb,nRBperUE(user),Tslot/symbPerSlot,iter,BLER,Tp,deadtime,N_OS);
            if flag==0
                disp('flag is equal to zero. Error \n');
            end
        end
    end
    if flag==2
        latency(user,ind_user)=100000;
        i=2;
        while i<=N_MC
            if aux_time(user,ind_user,i)<100000
                retx_time(user,ind_user,i)=100000;
                aux_time(user,ind_user,i)=100000;
            else
                break;
            end
        end
        retx_time(user,ind_user,1)=100000;
        aux_time(user,ind_user,1)=100000;
        aux(user,ind_user)=100000;
    end
    if flag==1
        if fretx==1
            retx(user,ind_user,1)=retx(user,ind_user,1)+1;
            if retx(user,ind_user,1)<=maxN_retx
                auxtime=tend+TprocRx+TprocRx;
                auxtime2=mod(auxtime,Tslot);
                ACK_time=auxtime+(Tslot-auxtime2)+Tslot/14; %(Tslot-auxtime2) is the frame allignment until the next slot
                retx_time(user,ind_user,1)=ACK_time+TprocTx;
                if strcmp(scheduling,'GF')
                    aux_time(user,ind_user,1)=ACK_time+TprocTx;
                else
                    aux_time(user,ind_user,1)=100000;
                end
            else
                retx_time(user,ind_user,1)=100000;
                aux_time(user,ind_user,1)=100000;
                latency(user,ind_user)=200000;
                fretx=0;
            end                
            if N_MC>1 && aux_time(user,ind_user,2)<100000
                [aux_time(user,ind_user,:),ind]=sort(aux_time(user,ind_user,:));
                retx_time(user,ind_user,:)=retx_time(user,ind_user,ind);
                retx(user,ind_user,:)=retx(user,ind_user,ind);
            end
            aux(user,ind_user)=aux_time(user,ind_user,1);
        else
            retx_time(user,ind_user,1)=100000;
            aux_time(user,ind_user,1)=100000;
            if N_MC>1 && aux_time(user,ind_user,2)<100000
                [aux_time(user,ind_user,:),ind]=sort(aux_time(user,ind_user,:));
                retx_time(user,ind_user,:)=retx_time(user,ind_user,ind);
                retx(user,ind_user,:)=retx(user,ind_user,ind);
            end 
            aux(user,ind_user)=aux_time(user,ind_user,1);
            latency_aux=(tend-t_ini(user,ind_user))+TprocRx;
            if latency(user,ind_user)<latency_aux
                latency(user,ind_user)=latency_aux;
            end
        end        
    end
%     [x,y]=find(aux>0);
%     if isempty(x)
%         return;
%     end
end
