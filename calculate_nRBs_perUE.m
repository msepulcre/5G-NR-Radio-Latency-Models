function [tbs_UEs, RBs_UEs]=calculate_nRBs_perUE(data,N,CQI_UEs,MCS_table,v,link,SCS,BW,CP,PDCCH_config,PUCCH_config,N_OS,NRB)

% this function returns the transport block size (tbs) for each UE and the
% number of RBs needed for each UE transmit a packet of size data

flag=0;
tbs_UEs=zeros(N,1);
RBs_UEs=zeros(N,1);

if link==2 || (link==1 && flag==0)
    %link==2 --> UL
    %link==1 --> DL
    for i=1:N
        MCS=link_adaptation(CQI_UEs(i),MCS_table);
        [tbs_UEs(i), RBs_UEs(i)]=tbs_packet(data,MCS,MCS_table,v,link,SCS,BW,CP,PDCCH_config,PUCCH_config,N_OS,NRB);
    end
elseif link==1 && flag==1
    for i=1:N
        MCS=link_adaptation(CQI_UEs(i),MCS_table);
        % seleccionamos un MCS más robusto 
        MCS=max(MCS-2,1);
        [tbs_UEs(i), RBs_UEs(i)]=tbs_packet(data,MCS,MCS_table,v,link,SCS,BW,CP,PDCCH_config,PUCCH_config,N_OS,NRB);
    end
elseif link==1 && flag==2
    MCS=4;
    for i=1:N
        [tbs_UEs(i), RBs_UEs(i)]=tbs_packet(data,MCS,MCS_table,v,link,SCS,BW,CP,PDCCH_config,PUCCH_config,N_OS,NRB);
    end
end

