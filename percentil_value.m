function [val] = percentil_value(vector,P)
% P debe ser un valor entre 0 y 1
%	[val] = percentil(vector,P)

    [m,n]=size(vector);
    vector=reshape(vector,1,m*n);
    [m,n]=cdfcalc(vector);
    x=find(m>=P);
    val=n(x(1)-1);

end

