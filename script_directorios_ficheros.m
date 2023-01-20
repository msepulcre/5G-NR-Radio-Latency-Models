if traffic==0
    carp='aperiodic';
elseif traffic==1
    carp='periodic';
else
    disp('traffic not valid');
end
if link_direction==1
    link='DL';
elseif link_direction==2
    link='UL';
end
if MCS_table(itable)==1 || MCS_table(itable)==2
    BLER=0.1;
elseif MCS_table(itable)==3
    BLER=0.00001;
end
switch escenario
    case 0
        dir='circular';
        dir1='circular';
    case 11
        if flag_control==0
            dir='highway1732';
            dir1='highway1732';
        else
            dir='highway1732_control';
            dir1='highway1732_control';
        end
    case 13
        if flag_control==0
            dir='highway1732_3lanesxdir';
            dir1='highway1732_3lanesxdir';
        else
            dir='highway1732_3lanesxdir_control';
            dir1='highway1732_3lanesxdir_control';
        end
    case 12
        dir='highway500';
        dir1='highway500';
    case 21
        dir='urban500';
        dir1='urban500';
end
if link_direction==2
    dir=sprintf('%s/ULUnicast',dir);
    N_MC=1;
    if maxN_retx(iretx)>0
        coletilla2=sprintf('_retx%d',maxN_retx(iretx));
        dir=sprintf('%s/output_HARQ',dir);
    elseif n_rep(irep)>1
        coletilla2=sprintf('_rep%d',n_rep(irep));
        dir=sprintf('%s/output_rep',dir);
    else
        coletilla2=sprintf('_rep%d',n_rep(irep));
        dir=sprintf('%s/output',dir);
    end
else
    if N_MC(iMC)==1
        dir=sprintf('%s/DLBroadcast',dir);
        if maxN_retx(iretx)>0
            coletilla2=sprintf('_retx%d',maxN_retx(iretx));
            dir=sprintf('%s/output_HARQ',dir);
        elseif n_rep(irep)>1
            coletilla2=sprintf('_rep%d',n_rep(irep));
            dir=sprintf('%s/output_rep',dir);
        else
            coletilla2=sprintf('_rep%d',n_rep(irep));
            dir=sprintf('%s/output',dir);
        end
    else
        dir=sprintf('%s/multipleDLTx',dir);
        coletilla2=sprintf('_retx%d',maxN_retx(iretx));
        if maxN_retx(iretx)>0
            dir=sprintf('%s/output_HARQ',dir);
        else
            dir=sprintf('%s/output',dir);
        end
    end
end

if nRBperUE>0
    coletilla3=sprintf('_nRBperUE%d',nRBperUE);
    dir=sprintf('%s/%s_Tp%d_nRB%d',dir,carp,Tp(t),nRBperUE);
else
    coletilla3=sprintf('_pkt%d',data(d));
    dir=sprintf('%s/%s_Tp%d_pkt%d',dir,carp,Tp(t),data(d));
end


