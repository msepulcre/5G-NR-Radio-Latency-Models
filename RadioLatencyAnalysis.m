function RadioLatencyAnalysis(YToPrint,XToPrint,output)
% YToPrint parameter to analyze as a function of parameter XToPrint
% output == 'texto' --> results are save in a file text
% output == 'figura' --> results are represented in a figure

% YToPrint='RadioToE2E';
% YToPrint='9999Latency'; %99.99th percentile
% YToPrint='90Latency';   %90th percentile
% YToPrint='50Latency';   %50th percentile
% YToPrint='avgLatency';  %average
% YToPrint='maxLatency';  %maximum 
% YToPrint='cdfLatency';  %cdf of the experienced latency for all packets
% YToPrint='BoxPlotLatency';  %boxplot
% YToPrint='CBR';         % % of channel utilization
% YToPrint='NonRxPkts';   % % of packets not received correctly (aborted
                            % + received with error)
% YToPrint='AbortedByControlPkts';    % % of packets dropped by the highe 
                                        % latency experienced by control messages 
% YToPrint='AbortedPkts';     % % of packets dropped
% YToPrint='ErroneousPkts';   % % of packets received with error
% YToPrint='Reliability10';
% YToPrint='Reliability25';
% YToPrint='Reliability5';
% YToPrint='PercPktsLatency10';
% YToPrint='PercPktsLatency25';
% YToPrint='PercPktsLatency8';
% YToPrint='PercPktsLatency6';

% XToPrint='SCS';
% XToPrint='density';
% XToPrint='BLER';
% XToPrint='MIMOlayers';
% XToPrint='Tp';
% XToPrint='krep';
% XToPrint='HARQretx';
% XToPrint='DLUnicastTx';
% XToPrint='BW';
% XToPrint='N_MC';

% output='text';
% output='figure';

BW=[20]; %10 20 30 40 50];
SCS=30;
link_direction=1;
MCS_table=[2 3];
n_rep=1;
v=2; 
N_MC=1;
density=[10 20 40 60 80];

% traffic=1 --> periodic
traffic=1;  
Tp=[100 20];
% traffic=0 --> aperiodic;
%   traffic=0;
%   Tp=[10 50];

nRBperUE=0;
data=[300];
Nmin=0;
Nmax=0;
escenario=13;
maxN_retx=[0]; %3  1, 2, 4

flag_control=0;
if link_direction==1
	PDCCH_config=1; 
	PUCCH_config=1;
elseif link_direction==2
	PDCCH_config=1; 
	PUCCH_config=1; 
end
minislot_config=0;


hf=figure;
dir_actual=cd();

for i_MCStable=1:length(MCS_table)
    analysis(YToPrint,XToPrint,link_direction,BW,nRBperUE,data,v,Nmin,Nmax,SCS,escenario,density,MCS_table(i_MCStable),traffic,Tp,N_MC,n_rep,maxN_retx,output,PDCCH_config,PUCCH_config,flag_control,minislot_config,hf);
    cd(dir_actual);
    close all;
end
           


        
        
        
        
        
        
        
        
