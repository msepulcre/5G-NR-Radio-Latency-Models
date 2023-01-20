function RadioToE2Emodel(dir,dir_current,fich,Tp,escenario,link_direction,N_MC,traffic,...
    SCS,BW,density, MCS_table,MIMOlayers,n_rep,maxN_retx,data)
    % This script prepares the files with the results of the radio latency
% analysis that are used as input for the E2E latency model

% l=textread(fichero);
% [x,y]=size(l);
% l=reshape(l,1,x*y);
% x=find(l>0);
% l=l(x);
% x=find(l<100000);
% l=l(x);

% radio latency values are in ms

if ~exist('RadioToE2Emodel','dir')
    mkdir('RadioToE2Emodel')
end

cd(dir);
l=textread(sprintf('latency_matrix_%s.txt',fich));
lA=l;
[x,y]=size(l);
l=reshape(l,1,x*y);
cd(dir_current);

if traffic == 1                   

    iterE2E=3;
    [x,y]=size(lA);
    if x==500*iterE2E
        simE2E=500;
    else
        simE2E=x/iterE2E;
        if mod(x,iterE2E)~=0
            disp('warning 1!!\n');
        end
    end

    ri_gNB_RANradio = ceil(length(l) / (iterE2E*Tp/1000) / simE2E); %500 simulations
    ri_gNB_RANradioMAX = ri_gNB_RANradio;
    ri_gNB_RANradioMIN = ri_gNB_RANradio;
    
    ri_gNB_RANradio2 = ri_gNB_RANradio;
    ri_gNB_RANradioMAX2 = ri_gNB_RANradio;
    ri_gNB_RANradioMIN2 = ri_gNB_RANradio;
else %Aperiodic
    cd(dir);
    
    % arrival time of each packet to the gNB
    l3=textread(sprintf('time_rx_pkts_%s.txt',fich)); 
    % initial and end time 
    l2=textread(sprintf('time_sim_%s.txt',fich)); 
    % radio latency experienced by each packet
    lA=textread(sprintf('latency_matrix_%s.txt',fich)); 

    cd(dir_current);
    
	[x,y]=size(lA);
    PktsA = 50 -1; 
    Iter = 200;

    if x~=Iter*PktsA
        PktsA = 30 -1; 
        Iter = 100;
        if x~=Iter*PktsA
            PktsA = 20 -1; 
            Iter = 100;
            if x~=Iter*PktsA
                disp('warning 2\n');
            end
        end
    end
        
        
    %50 pkts, 200 simulaciones
    ri_Iter = NaN(Iter,1);
    ri_Iter2 = NaN(Iter,1);
    ri_Iter2max = NaN(Iter,1);
    ri_Iter2min = NaN(Iter,1);
    [x,y]=size(l2);
    if x == Iter && y == 2
        [x,~]=size(l3);
        if x == (PktsA * Iter) 
            for iIter = 1 : Iter
                tSim = l2(iIter, 2) - l2(iIter, 1); %ms
                
                %Opcion 1: valores de latencia de 1 simulacion
                lASim=lA(1+(iIter-1)*PktsA : iIter*PktsA, :); 
                [x,y]=size(lASim);
                lASim=reshape(lASim,1,x*y);
                x=find(lASim>0);
                lASim=lASim(x);
                x=find(lASim<100000);
                lASim=lASim(x);
                
                ri_Iter(iIter) = length(lASim) / (tSim / 1000);
                
                %Opcion 2: por cada simulacion buscamos picos en periodos AvgP
                l3Sim=l3(1+(iIter-1)*PktsA : iIter*PktsA, :);
                AvgP = 2*Tp;
                Periodos = l2(iIter, 1) : AvgP : l2(iIter, 2);
                riIter_P = NaN(length(Periodos) - 1, 1);
                for iPeriodos = 1 : length(Periodos) - 1;
                    [x, ~] = size(find(l3Sim > Periodos(iPeriodos) & l3Sim < Periodos(iPeriodos+1)));
                    riIter_P(iPeriodos) = x/(AvgP/1e3);
                end
                ri_Iter2(iIter) = ceil(mean(riIter_P));
                ri_Iter2max(iIter) = ceil(max(riIter_P));
                ri_Iter2min(iIter) = ceil(min(riIter_P));
            end
        else
            warning('Warning 1 ...')
        end
    else
        warning('Warning 2 ....')
    end
    ri_gNB_RANradio = ceil(mean(ri_Iter));
    ri_gNB_RANradioMAX = ceil(max(ri_Iter)); 
    ri_gNB_RANradioMIN = ceil(min(ri_Iter));
    
    
    ri_gNB_RANradio2 = ceil(mean(ri_Iter2));
    ri_gNB_RANradioMAX2 = ceil(max(ri_Iter2max)); 
    ri_gNB_RANradioMIN2 = ceil(min(ri_Iter2min));
end

% cdf is calculated considering all packets (transmitted+aborted)
[YCDF,XCDF] = cdfcalc(l);

% the average value is calculated only considering transmitted packets
x=find(l<100000);
l=l(x);
RANradio_LatMean=mean(l);

cd 'RadioToE2Emodel'

save(['latency_RANradio_scen' num2str(escenario) '_LnkDir' num2str(link_direction) '_nDLTx' num2str(N_MC) '_traffic' num2str(traffic) ...
    '_Tp' num2str(Tp) '_SCS' num2str(SCS) '_BW' num2str(BW) '_density' num2str(density) '_MCSTable' num2str(MCS_table) ...
    '_layers' num2str(MIMOlayers) '_rep' num2str(n_rep) '_retx' num2str(maxN_retx) '_pkt' num2str(data) '.mat'],...
                                                              'YCDF',...
                                                              'XCDF',...
                                                              'RANradio_LatMean',...
                                                              'ri_gNB_RANradio', 'ri_gNB_RANradio2',...
                                                              'ri_gNB_RANradioMAX','ri_gNB_RANradioMAX2',...
                                                              'ri_gNB_RANradioMIN', 'ri_gNB_RANradioMIN2')

clear lA l2 l3;
cd ..

