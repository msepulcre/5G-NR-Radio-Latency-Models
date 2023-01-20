function [UEdistToBS,nUE,Rcell]=set_user_location(escenario,N,density)

% escenario 0
%   N is passed as an argument to the main function
%   no location is assigned to the UEs
% escenario 1 --> Highway
%   escenario 11 --> ISD= 1732
%   escenario 12 --> ISD= 500
%       Free flow conditions: 20 veh/(km*lane)
%       Stop-&-go situations: 60 veh/(km*lane)
%       Congestion: 80 veh/(km*lane)
% escenario 2 --> Urban Grid
%	Avg distance between veh= 1s*avg_speed with avg speed 15-120km/h
%   escenario 21 -->  ISD= 500m
%       we are considering 40 km/h ? 11.1m ? 90 veh/(km*lane)
%                          60 km/h ? 16.6m ? 60.2 veh/(km*lane)


Rcell=-1;
esc=floor(escenario/10);
resto=mod(escenario,10);
if esc==0
    nUE=N;
    UEdistToBS=zeros(N,1);
    return;
elseif esc==1
    if resto==1
        Rcell=1732/2;
        lanesxdir=6;
    elseif resto==3
        Rcell=1732/2;
        lanesxdir=3;
    elseif resto==2
        Rcell=500/2;
        lanesxdir=6;
    else
        disp('Invalid scenario.');
    end
    vehperlaneandkm=density;
elseif esc==2
    if resto==1
        Rcell=500/2;
    else
        disp('Invalid scenario.');
    end
    vehperlaneandkm=density;
else
    disp('Invalid scenario.');
end
    
UEdistToBS=[];
switch esc
    case 1
        BS_x=2*(3.7*lanesxdir+1); %lane width=3.7m (EEUU), 1m separation between directions and up to the BS
        BS_y=Rcell;
        nUE=0;
        nUEinLane=floor(vehperlaneandkm/1000*Rcell*2);
        for i=1:lanesxdir*2 %lanesxdir lanes x 2 directions
            for j=1:nUEinLane
                UE_x=3.7/2+3.7*(i-1)+floor((i-1)/lanesxdir)*1;
                UE_y=rand()*Rcell*2;
                distToBS=sqrt((UE_x-BS_x)^2+(UE_y-BS_y)^2);
                if distToBS<=Rcell
                    nUE=nUE+1;
                    UEdistToBS=[UEdistToBS;distToBS];
                end
            end
        end
    case 2
        BS_x=253; %lane width=3.7m (EEUU), 1m separation between directions and up to the BS
        BS_y=436;
        nUE=0;
        nUEinLane=floor(vehperlaneandkm/1000*Rcell*2);
        %vertical lanes
        for i=1:8 %2 lanes x 2 directions x 2 streets
            for j=1:nUEinLane
                UE_x=236+3.5/2+3.5*(i-1)+floor((i-1)/4)*236;
                UE_y=rand()*Rcell*2+(433-250);
                distToBS=sqrt((UE_x-BS_x)^2+(UE_y-BS_y)^2);
                if distToBS<=Rcell
                    nUE=nUE+1;
                    UEdistToBS=[UEdistToBS;distToBS];
                end
            end
        end
        %horizontal lanes
        for i=1:4 %2 lanes x 2 directions x 2 streets
            for j=1:nUEinLane
                UE_x=rand()*Rcell*2;
                UE_y=419+3.5/2+3.5*(i-1);
                distToBS=sqrt((UE_x-BS_x)^2+(UE_y-BS_y)^2);
                if distToBS<=Rcell
                    nUE=nUE+1;
                    UEdistToBS=[UEdistToBS;distToBS];
                end
            end
        end
end

