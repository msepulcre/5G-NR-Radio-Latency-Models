function CQI_UEs=calculate_CQI(UEdistToBS,Rcell)

% we use a propagation model based on concentric CQIs
% a ring defines the cell area where the UEs experienced an average channel
% quality given by the corresponding CQI

%nrings=15;
nrings=11;
N=length(UEdistToBS);
if Rcell==-1
    CQI_UEs=floor(rand([N,1])*nrings)+1;
    x=find(CQI_UEs>nrings);
    if ~isempty(x)
        CQI_UEs(x)=nrings;
    end
else
%    for i=1:nrings
%        if i==1
%            limRings=[3/2*Rcell/nrings];
%        elseif i<=5
%            limRings=[limRings limRings(end)+3/2*Rcell/nrings];
%        elseif i<=10
%            limRings=[limRings limRings(end)+Rcell/nrings];
%        else
%            limRings=[limRings limRings(end)+1/2*Rcell/nrings];
%        end
%    end
    limRings=Rcell/nrings:Rcell/nrings:Rcell;
    CQI_UEs=[];
    for i=1:N
        x=find(limRings>=UEdistToBS(i));
        if isempty(x)
            disp('error1');
        end
        CQI_UEs=[CQI_UEs;15-x(1)+1];
    end
end


