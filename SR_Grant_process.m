function [Taux,latency]=SR_Grant_process(Ta,Tslot,TprocTx,TprocRx,TprocTxHARQ,TprocRxHARQ,latency,tsim,PDCCH_config,PUCCH_config,flag_control)
% this function accounts for the delay added by the SR-Grant handshaking
% process
% we consider that:
% 1. the SR message includee in the PUCCH is transmitted in the last 
%    symbol of every slot
% 2. the Grant included in the PDCCH is transmitted in the first symbol
%    of every slot

[x,y]=size(Ta);
Tsymbol=Tslot/14;

if flag_control==0  %unlimited capacity to transmit the control messages
    for i=1:x
        for j=1:y
            Taux(i,j)=Ta(i,j)+TprocTxHARQ;
            resto=mod(Taux(i,j),Tslot);
            if resto<13*Tsymbol %sum Talligment + Tsymbol (time duration of PUCCH)
                Taux(i,j)=ceil(Taux(i,j)/Tslot)*Tslot;
            else
                Taux(i,j)=ceil(Taux(i,j)/Tslot)*Tslot+Tslot;
            end
            Taux(i,j)=Taux(i,j)+TprocRxHARQ+TprocTxHARQ;
            %sum Talligment + Tsymbol (time duration of PDCCH)
            Taux(i,j)=ceil(Taux(i,j)/Tslot)*Tslot+Tsymbol;
            Taux(i,j)=Taux(i,j)+TprocRxHARQ+TprocTx; 
            % the next Talligment is calculated based on the radio 
            % resources allocated in the scheduling
        end
    end
else
    %limited capacity to transmit the control messages
    switch PDCCH_config
        case 1
            NofGrantsperSlot=2;%Number of DCI messages with format 1_0 that can be transmitted per slot
        case 2
            NofGrantsperSlot=4; %Number of DCI messages with format 1_0 that can be transmitted per slot
        case 3
            NofGrantsperSlot=12; %Number of DCI messages with format 1_0 that can be transmitted per slot
        case 4
            NofGrantsperSlot=18; %Number of DCI messages with format 1_0 that can be transmitted per slot
        case 5
            NofGrantsperSlot=24; %Number of DCI messages with format 1_0 that can be transmitted per slot
        case 9
            NofGrantsperSlot=500; %unlimited capacity
    end
    switch PUCCH_config
        case 1
            SRperSlot=48;%Number of SR messages that can be transmitted per slot
        case 2
            SRperSlot=96; %Number of DCI messages that can be transmitted per slot
        case 3
            SRperSlot=192; %Number of DCI messages that can be transmitted per slot
    end

    % SRperSlot=48;
    nUEs=x;
    SRperiod=ceil(nUEs/SRperSlot);

    % NofGrantsperSlot=2;
    % first, we add the time required to transmit the SR to all transmissions
    Taux=Ta+TprocTxHARQ;

    for i=1:x
        for j=1:y
            probAccess=rand();
            k=1;
            while probAccess>k/SRperiod
                k=k+1;
                if k>SRperiod
                    disp('tendría que salir antes');
                    break;
                end
            end

            resto=mod(Taux(i,j),Tslot);
            if resto<13*Tsymbol %sum Talligment + Tsymbol (time duration of PUCCH)
                %Taux(i,j)=ceil(Taux(i,j)/Tslot)*Tslot+(k-1)*Tslot;
                Taux(i,j)=(ceil(Taux(i,j)/Tslot)+k-1)*Tslot;
            else
                %Taux(i,j)=ceil(Taux(i,j)/Tslot)*Tslot+Tslot+(k-1)*Tslot;
                Taux(i,j)=(ceil(Taux(i,j)/Tslot)+k)*Tslot;
            end
            Taux(i,j)=Taux(i,j)+TprocRxHARQ;
        end
    end

    Taux=Taux+TprocTxHARQ;
    Tb=Taux';
    imax=floor(tsim/Tslot);
    queue=zeros(1,imax);

    while 1
        [nextPacketperUser,iTb]=min(Tb,[],1);
        [nextT,user]=min(nextPacketperUser);
        if nextT>=tsim
          return;
        end
        ind_user=iTb(user);

        ind_ini=ceil(Taux(user,ind_user)/Tslot);
        i=0;
        while ind_ini+i<=imax && queue(ind_ini+i)>=NofGrantsperSlot
            i=i+1;
        end

        Taux(user,ind_user)=(ind_ini+i)*Tslot;
        if Taux(user,ind_user)>=Ta(user,ind_user+1) || (ind_ini+i)>imax
            %indicates that the packet is not transmitted due to the high 
            %latency experienced in the transmission of the control messages
            latency(user,ind_user)=300000;  
        else
            queue(ind_ini+i)=queue(ind_ini+i)+1;
        end

        Taux(user,ind_user)=Taux(user,ind_user)+Tsymbol; % transmission time
        %sum Talligment + Tsymbol (time duration PDCCH)
        Taux(user,ind_user)=Taux(user,ind_user)+TprocRxHARQ+TprocTx;
            % the next Talligment is calculated based on the radio 
            % resources allocated in the scheduling
        Tb(ind_user,user)=tsim*2;
    end
end
