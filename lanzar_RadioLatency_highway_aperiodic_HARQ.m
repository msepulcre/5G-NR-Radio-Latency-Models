% lanzar_RadioLatency_highway_aperiodic_HARQ

minislot_config=[0]; %0 1 2
escenario=[13]; %11 12
density=[60]; %10 20 40 60 80]; 
traffic=0; 		% traffic=1 --> periodic % traffic=0 --> aperiodic;
Tp=[10]; % 50]; %50 
nRBperUE=0;
data=300;
MCS_table=[2 3];
v=2; %4
BW=[20]; %30 50 10 20 40
SCS=[30]; %30 #60 15;
N_MC=[1]; % N_MC must equal to or higher than 1. N_MC =1 --> broadcast mode in DL
n_rep=[1]; %1 2 4
maxN_retx=[3]; %retx basadas en HARQ

flagDiscardPkts=1;
segmentationFactor=1;
Nmin=0;
Nmax=0;

flag_control=0;
PDCCH_config=1;
PUCCH_config=1;

for i_minislot=1:length(minislot_config)
    for i_escenario=1:length(escenario)
        for i_density=1:length(density)
            for i_Tp=1:length(Tp)
                for i_MCStable=1:length(MCS_table)
                    for i_BW=1:length(BW)
                        for i_SCS=1:length(SCS)
                            for i_NMC=1:length(N_MC)
                                for i_nrep=1:length(n_rep)
                                    for i_maxNretx=1:length(maxN_retx)
                                        link_direction=2; 	%direction=1 --> DL, direction=2 --> UL
                                        RadioLatency(BW(i_BW),SCS(i_SCS),traffic,...
                                            Tp(i_Tp),nRBperUE,data,link_direction,...
                                            Nmin,Nmax,N_MC(i_NMC),n_rep(i_nrep),...
                                            maxN_retx(i_maxNretx),MCS_table(i_MCStable),...
                                            v,escenario(i_escenario),density(i_density),...
                                            flagDiscardPkts,segmentationFactor,...
                                            PDCCH_config,PUCCH_config,flag_control,minislot_config(i_minislot))

                                        link_direction=1; 	%direction=1 --> DL, direction=2 --> UL
                                        RadioLatency(BW(i_BW),SCS(i_SCS),traffic,...
                                            Tp(i_Tp),nRBperUE,data,link_direction,...
                                            Nmin,Nmax,N_MC(i_NMC),n_rep(i_nrep),...
                                            maxN_retx(i_maxNretx),MCS_table(i_MCStable),...
                                            v,escenario(i_escenario),density(i_density),...
                                            flagDiscardPkts,segmentationFactor,...
                                            PDCCH_config,PUCCH_config,flag_control,minislot_config(i_minislot))
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
