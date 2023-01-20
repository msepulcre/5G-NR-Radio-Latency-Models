function [NRB,Tslot,num,N_OS,symbPerSlot]=RB_definition(FR,SCS,BW,minislot_config,CP)

% returns the number of RBs per slot (NRB) and the time duration of a slot 
% based on the numerology (Tslot), numerology (num), number of symbols used
% for transmit a packet (N_OS), number of OFDM symbols per slot
% (symbPerSlot)
% NRB is given by 3GPP TS 38.104 as a function of the BW and SCS

%FR
    %FR1: 410 MHz- 7125 MHz
    %FR2: 24250 MHz- 52600 MHz
%BW
    %FR1 (en MHz): 5, 10, 15, 20, 25, 30, 40, 50, 60, 70, 80, 90, 100
    %FR2 (en MHz): 50, 100, 200, 400
%SCS
    %FR1 (en kHz): 15, 30, 60
    %FR2 (en kHz): 60, 120


BWA1=[5, 10, 15, 20, 25, 30, 40, 50, 60, 70, 80, 90, 100];
BWA2=[50, 100, 200, 400];
SCSA1=[15, 30, 60];
SCSA2=[60, 120];
NRB1=[25 52 79 106 133 160 216 270 NaN NaN NaN NaN NaN;
      11 24 38 51 65 78 106 133 162 189 217 245 273;
      NaN 11 18 24 31 38 51 65 79 93 107 121 135];
NRB2=[66 132 264 NaN
      32 66 132 264];

Tslot1=[1 0.5 0.25];
Tslot2=[0.25 0.125];

num1=[0 1 2];
num2=[2 3];

if FR==1
    i=find(SCSA1==SCS);
    j=find(BWA1==BW);
    if isempty(i)
        disp('Non valid SCS value.');
        exit;
    end
    if isempty(j)
        disp('Non valid BW value.');
        exit;
    end
    num=num1(i);
    Tslot=Tslot1(i);
    NRB=NRB1(i,j);
    if isnan(NRB)
        disp('Non valid combination BW-SCS.');
        exit;
    end
elseif FR==2
    i=find(SCSA2==SCS);
    j=find(BWA2==BW);
    if isempty(i)
        disp('Non valid SCS value.');
        exit;
    end
    if isempty(j)
        disp('Non valid BW value.');
        exit;
    end
    num=num2(i);
    Tslot=Tslot2(i);
    NRB=NRB2(i,j);
    if isnan(NRB)
        disp('Non valid combination BW-SCS.');
        exit;
    end
else
    disp('Non valid FR value.');
    exit;
end

switch CP
    case 'NCP'
        symbPerSlot=14;
    case 'ECP'
        symbPerSlot=12;
end

% number of OFDM symbols (OS) used for the transmission of a packet based
% on the minislot_config
switch minislot_config
    case 0  % full-slot transmission
        switch CP
            case 'NCP'
                N_OS=14;
            case 'ECP'
                N_OS=12;
        end
    case 1  % mini-slot transmission with 7 (NCP) or 6 (ECP) OSs
        switch CP
            case 'NCP'
                N_OS=7;
            case 'ECP'
                N_OS=6;
        end
    case 2  % mini-slot transmission with 4 (NCP) or 2 (ECP) OSs
        N_OS=4;
    case 3
        N_OS=2;
end
