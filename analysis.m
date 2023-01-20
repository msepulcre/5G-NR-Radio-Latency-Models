function analysis(YToPrint,XToPrint,link_direction,BW,nRBperUE,data,MIMOlayers,Nmin,Nmax,SCS,escenario,density,MCS_table,traffic,Tp,N_MC,n_rep,maxN_retx,output,PDCCH_config,PUCCH_config,flag_control,minislot_config,hf)

if ~exist('results','dir')
    mkdir('results')
end

AnalysisMC=1;
RadioToE2E=0;

switch output
    case 'text'
        flag_fich=1;
        flag_fig=0;
    case 'figur'
        flag_fich=0;
        flag_fig=1;
end


if flag_fig==1
    aux=MCS_table;  %A new figure is created for each value of aux
                    %aux can take the value of different variables (SCS,
                    %n_rep...)
%     aux=SCS;
else
    aux=SCS;
end

for ifig=1:length(aux)
	if flag_fig==1
        % this must be adapted according to the variable assigned to aux in
        % line 17
		MCS_table=aux(ifig);
		varcol1='MCS table';
% 		SCS=aux(ifig);
% 		varcol1='SCS';
	else
		SCS=aux(ifig);
		varcol1='SCS';
	end
    
    if flag_fig==1
        if strcmp(YToPrint,'cdfLatency')
            if exist('hf','var')>0
                hcdf_latency=hf;
                hold on;
                hcdf_sPacket=figure;
                hold on;
                htbs=figure;
                hold on;
            else
                hcdf_latency=figure;
                hold on;
                hcdf_sPacket=figure;
                hold on;
                htbs=figure;
                hold on;
            end
            hfig=figure;
            hold on;
        else
            if exist('hf','var')>0
                hfig=hf;
                hold on;
            else
                hfig=figure;
                hold on;
            end
            hcdf_latency=figure;
            hold on;
        end    
    else
            hcdf_latency=figure;
            hold on;
    end
    
    flag=0;
    
    switch YToPrint
        case 'RadioToE2E'
            RadioToE2E=1;
            AnalysisMC=0;
        case '9999Latency'
            yname='Latency (ms)';
        case '90Latency'
            yname='Latency (ms)';
        case '50Latency'
            yname='Latency (ms)';
        case 'avgLatency'
            yname='Latency (ms)';
        case 'maxLatency'
            yname='Latency (ms)';
        case 'BoxPlotLatency'
            yname='Latency (ms)';
        case 'CBR'
            yname='% of RBs used';
        case 'NonRxPkts'
            yname='% of non-received packets';
        case 'AbortedByControlPkts'
            yname='% of discarded packets by control';
        case 'AbortedPkts'
            yname='% of discarded packets';
        case 'TxPkts'
            yname='% of Tx packets';
            hcdf_sPacket=figure;
            hold on;
        case 'ErroneousPkts'
            yname='% of erroneous packets';
        case 'Reliability5'
            yname='% of packets received before 5 ms';
        case 'Reliability10'
            yname='% of packets received before 10 ms';
        case 'Reliability25'
            yname='% of packets received before 25 ms';
	case 'PercPktsLatency25'
	    yname='% pkts';
        case 'PercPktsLatency10'
            yname='% pkts';
        case 'PercPktsLatency8'
            yname='% pkts';
        case 'PercPktsLatency6'
            yname='% pkts';
        case 'PercPktsLatency23'
            yname='% pkts';
        case 'cdfLatency'
            yname='Prob(latency<x)';
            xname='x (ms)';
    end
   
    if ~strcmp(YToPrint,'cdfLatency')
        switch XToPrint
            case 'SCS'
                xShowValue=SCS;
                xname='SCS (kHz)';
            case 'density'
%                     xvalue=1:length(density);
                xShowValue=density;
                xname='Density (veh/km/lane)';
            case 'BLER'
                xShowValue=[10e-1 10e-5];
                xname='MCS-BLER target';
            case 'MIMOlayers'
                xShowValue=MIMOlayers;
                xname='Tx MIMO layers';
            case 'Tp'
                xShowValue=Tp;
                xname='Tp (ms)';
            case 'krep'
                xShowValue=n_rep;
                xname='# of replicas';
            case 'HARQretx'
                xShowValue=maxN_retx;
                xname='Maximum # of HARQ retx';
            case 'DLUnicastTx'
                xShowValue=N_MC;
                xname='# of DL unicast tx';
            case 'BW'
                xShowValue=BW;
                xname='Bandwidth (MHz)';
            case 'N_MC'
                xShowValue=N_MC;
                xname='# of DL unicast tx';
        end    
    end    
    
    if ifig==1
        if flag_fig==1
            % a new plot is included in the figure for each value of aux2
           aux2=SCS;			
           varcol2='SCS';
%            aux2=N_MC;
%            varcol2='N_MC';
%             aux2=n_rep;
%             varcol2='n_rep';
%             aux2=maxN_retx;
%             varcol2='maxN_retx';
        else
            aux2=Tp;
            varcol2='Tp';	
        end
    end
    for iter=1:length(aux2)
	if flag_fig==1
        % adapt this instruction according to the assignment to aux2 in
        % line 164
		SCS=aux2(iter);     
% 		N_MC=aux2(iter);
% 		n_rep=aux2(iter);
%		maxN_retx=aux2(iter);
	else
		Tp=aux2(iter);
	end

        xvalue=[];
        yvalue=[];
        yvalue2=[];

        print_column=[];       
        k=1;
        for t=1:length(Tp)
            for idensity=1:length(density)
                for s=1:length(SCS)
                    for b=1:length(BW)
                        if SCS(s)==59 && BW(b)==10
                            continue;
                        end
                        for d=1:length(data)
                            for v=1:length(MIMOlayers)
                                for itable=1:length(MCS_table)
                                    for iMC=1:length(N_MC)
                                        for iretx=1:length(maxN_retx)
                                            maxN_retx_ori=maxN_retx(iretx);
                                            for irep=1:length(n_rep)
                                                if SCS(s)==15 && BW(b)>=60
                                                    yvalue=[yvalue -55];
                                                    break;
                                                end

                                                if n_rep(irep)==9
                                                    n_rep_ori=n_rep(irep);
                                                    n_rep(irep)=1;
                                                    maxN_retx(iretx)=3;
                                                end

                                                print_column=[print_column sprintf('\tdens%d-BW%d',density(idensity),BW(b))];
                                                dir='';
                                                script_directorios_ficheros;

                                                cd('results');
                                                if flag_fich==1 && ifig==1 && iter==1
                                                    fid=fopen(sprintf('%s_%s_%s_%s_%s.txt',YToPrint,XToPrint,dir1,carp,link),'a+');
                                                    pwd;
                                                end
                                                cd ..;

                                                if escenario==0
                                                    coletilla=sprintf('Tp%d_SCS%d_BW%d_%s_N%d_nDLTx%d_MCSTable%d_layers%d%s%s',Tp(t),SCS(s),BW(b),link,N,N_MC(iMC),MCS_table(itable),MIMOlayers(v),coletilla2,coletilla3);
                                                else
                                                    coletilla=sprintf('Tp%d_SCS%d_BW%d_%s_density%d_nDLTx%d_MCSTable%d_layers%d%s%s',Tp(t),SCS(s),BW(b),link,density(idensity),N_MC(iMC),MCS_table(itable),MIMOlayers(v),coletilla2,coletilla3);
                                                end
                                                if flag_control==1
                                                    coletilla=sprintf('%s_U%dD%d',coletilla,PUCCH_config,PDCCH_config);
                                                end
                                                if minislot_config>0
                                                    coletilla=sprintf('%s_MS%d',coletilla,minislot_config);
                                                end
                                                
                                                dir_current=cd();
                                                cd(dir);
                                                dir_results=cd();

                                                if flag==0
                                                    coletilla4=sprintf('%s_%s_%s_%s_%s',YToPrint,XToPrint,dir1,carp,link);
                                                    if length(BW)==1
                                                        coletilla4=sprintf('%s_BW%d',coletilla4,BW(1));
                                                    end
                                                    if length(MIMOlayers)==1
                                                        coletilla4=sprintf('%s_v%d',coletilla4,MIMOlayers(1));
                                                    end
                                                    if length(data)==1
                                                        coletilla4=sprintf('%s_pkt%d',coletilla4,data(1));
                                                    end
                                                    if length(SCS)==1
                                                        coletilla4=sprintf('%s_SCS%d',coletilla4,SCS(1));
                                                    end
                                                    if length(density)==1    
                                                        coletilla4=sprintf('%s_density%d',coletilla4,density(1));
                                                    end
                                                    if length(MCS_table)==1    
                                                        coletilla4=sprintf('%s_table%d',coletilla4,MCS_table(1));
                                                    end
                                                    if length(Tp)==1
                                                        coletilla4=sprintf('%s_Tp%d',coletilla4,Tp(1));
                                                    end
                                                    if length(N_MC)==1
                                                        coletilla4=sprintf('%s_MCTx%d',coletilla4,N_MC(1));
                                                    end
                                                    if length(maxN_retx)==1
                                                        coletilla4=sprintf('%s_maxReTx%d',coletilla4,maxN_retx(1));
                                                    end
                                                    if length(n_rep)==1
                                                       coletilla4=sprintf('%s_krep%d',coletilla4,n_rep(1));
                                                    end 
                                                
                                                    if flag_control==1
                                                        coletilla4=sprintf('%s_U%dD%d',coletilla4,PUCCH_config,PDCCH_config);
                                                    end
                                                    if minislot_config>0
                                                        coletilla4=sprintf('%s_MS%d',coletilla4,minislot_config);
                                                    end

                                                    
                                                    flag=1;
                                                    if flag_fich==1
                                                        fprintf(fid,'\t\t\n%s\n',coletilla4);
                                                        fprintf(fid,'\tSCS%d\t%s\n',SCS(s),varcol2);
                                                    end
                                                end
                                                                                                
                                                
                                                fich=sprintf('latency_matrix_%s.txt',coletilla);
                                                fich3=sprintf('UE_data_%s.txt',coletilla);
                                                if n_rep(irep)==1
                                                    fich2=sprintf('retx_matrix_%s.txt',coletilla);
                                                end
                                                fich4=sprintf('latency_%s.txt',coletilla);

                                                if strcmp(YToPrint,'CBR')==0
                                                    pwd;
                                                    disp(fich);
                                                    l=textread(fich);
%                                                     disp(cd);
%                                                     disp(fich);
                                                    [x,y]=size(l);
                                                    l=reshape(l,1,x*y);
                                                    totalPkt=length(l);
        %             if latency==100000, packet was dropped because the next packet was generated
        %             if latency==200000, has been received with error 
        %             if latency==300000, packet was dropped because the
        %             next packet was generated due to the high latency
        %             experienced to send the control messages related
        %             with the scheduling process
                                                    x=find(l==300000);
                                                    abortByControl=length(x);
                                                    x=find(l==100000);
                                                    abortPkt=length(x);
                                                    x=find(l==200000);
                                                    errorPkt=length(x);

                                                    abortContPerc(k)=abortByControl/totalPkt*100;
                                                    abortPerc(k)=abortPkt/totalPkt*100;
                                                    errorPerc(k)=errorPkt/totalPkt*100;
                                                    nonReceivedPerc(k)=(abortPkt+errorPkt+abortByControl)/totalPkt*100;

                                                    if RadioToE2E==1
%                                                         x=find(l<100000);
%                                                         l=l(x);
                                                        cd(dir_current);
                                                        RadioToE2Emodel(dir,dir_current,coletilla, Tp(t),escenario,...
                                                            link_direction,N_MC(iMC),traffic,SCS(s),BW(b),...
                                                            density(idensity),MCS_table(itable),MIMOlayers(v),...
                                                            n_rep(irep),maxN_retx(iretx),data(d));
                                                    end

                                                    if strcmp(YToPrint,'9999Latency')==1 || ...
                                                            strcmp(YToPrint,'90Latency')==1 || ...
                                                            strcmp(YToPrint,'Reliability10')==1 || ...
                                                            strcmp(YToPrint,'Reliability25')==1 || ...
                                                            strcmp(YToPrint,'Reliability5')==1 || ...
                                                            strcmp(YToPrint,'PercPktsLatency10')==1 || ...
                                                            strcmp(YToPrint,'PercPktsLatency25')==1 || ...
                                                            strcmp(YToPrint,'PercPktsLatency8')==1 || ...
                                                            strcmp(YToPrint,'PercPktsLatency6')==1 || ...
                                                            strcmp(YToPrint,'PercPktsLatency23')==1  || ...
                                                            strcmp(YToPrint,'cdfLatency')==1
                                                        x=find(l==200000);
                                                        l(x)=400000;
                                                    else                                                        
                                                        if AnalysisMC==1
                                                            sPacket=textread(fich3);
                                                            [msize,nsize]=size(sPacket);
                                                            irow=0:4:msize-1;
                                                            sPacket=sPacket(irow+3,:);
                                                            [msize,nsize]=size(sPacket);
                                                            aux=[];
                                                            for ii=1:msize
                                                                aux=[aux;sPacket(ii,:);sPacket(ii,:);sPacket(ii,:);sPacket(ii,:)];
                                                            end
                                                            sPacket=aux;
                                                            [msize,nsize]=size(sPacket);
                                                            sPacket=reshape(sPacket,1,msize*nsize);
                                                        end
                                                        x=find(l<100000);
                                                        l=l(x);
                                                        if strcmp(YToPrint,'TxPkts')==1
                                                            sPacket=sPacket(x);
                                                        end
                                                        x=find(l>0);
                                                        l=l(x);
                                                        if 0
                                                            sPacket=sPacket(x);
                                                            figure(hcdf_sPacket);
                                                            cdfplot(sPacket);
                                                        end
                                                        totalPkt=length(l);
                                                    end

                                                    cd(dir_current);
                                                    if AnalysisMC==1
                                                        if strcmp(YToPrint,'TxPkts')==1 
                                                            txPackets(k) = totalPkt;
                                                        end
                                                        if strcmp(YToPrint,'Reliability5')==1 
                                                            rel5(k) = percentil(l,5);
                                                        end
                                                        if strcmp(YToPrint,'Reliability10')==1 
                                                            rel10(k) = percentil(l,10);
                                                        end
                                                        if strcmp(YToPrint,'Reliability25')==1 
                                                            rel25(k) = percentil(l,25);
                                                        end
                                                        if strcmp(YToPrint,'PercPktsLatency25')==1
                                                            x=find(l<=25/2);
                                                            lat25(k) = length(x)/length(l)*100;
                                                        end
                                                        if strcmp(YToPrint,'PercPktsLatency10')==1
                                                            x=find(l<=10/2);
                                                            lat10(k) = length(x)/length(l)*100;
                                                        end
                                                        if strcmp(YToPrint,'PercPktsLatency8')==1
                                                            x=find(l<=8/2);
                                                            lat8(k) = length(x)/length(l)*100;
%                                                             disp(lat8);
                                                        end
                                                        if strcmp(YToPrint,'PercPktsLatency6')==1
                                                            x=find(l<=6/2);
                                                            lat6(k) = length(x)/length(l)*100;
                                                        end
                                                        if strcmp(YToPrint,'PercPktsLatency23')==1
                                                            x=find(l<=23/2);
                                                            lat23(k) = length(x)/length(l)*100;
                                                        end


                                                        val9999(k) = percentil_value(l,0.9999);
                                                        val90(k) = percentil_value(l,0.9);
                                                        val50(k) = percentil_value(l,0.5);                                                        
                                                        pp=1;
                                                        while val9999(k)==400000 && pp<=2
                                                            val9999(k) = percentil_value(l,0.9999-0.0001*pp);
                                                            pp=pp+1;
                                                        end
                                                        pp=1;
                                                        while val90(k)==400000 && pp<=2
                                                            val90(k) = percentil_value(l,0.9-0.01*pp);
                                                            pp=pp+1;
                                                        end

                                                        figure(hcdf_latency);
                                                        [h,statistics]=cdfplot(l);

                                                        avg(k)=statistics.mean;
                                                        maxv(k)=statistics.max;
                                                    end
                                                end
                                                
                                                if AnalysisMC==1
                                                    cd(dir_results);
                                                     disp(fich4);
                                                    a=textread(fich4);
                                                    CBR(k)=a(5);

                                                    switch iter
                                                        case 1
                                                            line='-';
                                                            color=[0 0 1];
%                                                             marker='x';
                                                            marker='*';
                                                        case 2
%                                                             line='--';
                                                            line='-';
                                                            color=[1 0 0];
%                                                             marker='^';
                                                            marker='o';
                                                        case 3
%                                                             line=':';
                                                            line='-';
                                                            color=[0 1 0];
%                                                             marker='o';
                                                            marker='^';
                                                        case 4
                                                            line='-.';
                                                            color=[0 0 1];
                                                            marker='s';
                                                        case 5
                                                            line='-';
                                                            color=[1 0 0];
                                                            marker='x';
                                                    end               

                                                    switch YToPrint
                                                        case '9999Latency'
                                                            yvalue=[yvalue val9999(k)];
                                                        case '90Latency'
                                                            yvalue=[yvalue val90(k)];
                                                        case '50Latency'
                                                            yvalue=[yvalue val50(k)];
                                                        case 'avgLatency'
                                                            yvalue=[yvalue avg(k)];
                                                        case 'maxLatency'
                                                            yvalue=[yvalue maxv(k)];
                                                        case 'CBR'
                                                            yvalue=[yvalue CBR(k)];
                                                        case 'NonRxPkts'
                                                            yvalue=[yvalue nonReceivedPerc(k)];
                                                        case 'AbortedByControlPkts'
                                                            yvalue=[yvalue abortContPerc(k)];
                                                        case 'AbortedPkts'
                                                            yvalue=[yvalue abortPerc(k)];
                                                        case 'TxPkts'
                                                            yvalue=[yvalue txPackets(k)];
                                                        case 'ErroneousPkts'
                                                            yvalue=[yvalue errorPerc(k)];
                                                        case 'Reliability5'
                                                            yvalue=[yvalue rel5(k)];
                                                        case 'Reliability10'
                                                            yvalue=[yvalue rel10(k)];
                                                        case 'Reliability25'
                                                            yvalue=[yvalue rel25(k)];
                                                        case 'PercPktsLatency25'
                                                            yvalue=[yvalue lat25(k)];
                                                        case 'PercPktsLatency10'
                                                            yvalue=[yvalue lat10(k)];
                                                        case 'PercPktsLatency8'
                                                            yvalue=[yvalue lat8(k)];
                                                        case 'PercPktsLatency6'
                                                            yvalue=[yvalue lat6(k)];
                                                        case 'PercPktsLatency23'
                                                            yvalue=[yvalue lat23(k)];
                                                        case 'BoxPlotLatency'
%                                                             yvalue=[yvalue l'];
                                                            yvalue=[yvalue [percentil_value(l,0.01) percentil_value(l,0.1) percentil_value(l,0.5) val90(k) val9999(k)]'];
                                                        case 'cdfLatency'
                                                            switch XToPrint
                                                                case 'SCS'
                                                                    set(h,'DisplayName',sprintf('%d',SCS(s)));
                                                                case 'density'
                                                                    set(h,'DisplayName',sprintf('%d',density(idensity)));
                                                                case 'BLER'
                                                                    if MCS_table(itable)==2
                                                                        set(h,'DisplayName',sprintf('%d',10e-1));
                                                                    elseif MCS_table(itable)==3
                                                                        set(h,'DisplayName',sprintf('%d',10e-5));
                                                                    end
                                                                case 'MIMOlayers'
                                                                    set(h,'DisplayName',sprintf('%d',MIMOlayers(v)));
                                                                case 'Tp'
                                                                    set(h,'DisplayName',sprintf('%d',Tp(t)));
                                                                case 'krep'
                                                                    set(h,'DisplayName',sprintf('%d',n_rep(irep)));
                                                                case 'HARQretx'
                                                                    set(h,'DisplayName',sprintf('%d',maxN_retx(iretx)));
                                                                case 'DLUnicastTx'
                                                                    set(h,'DisplayName',sprintf('%d',N_MC(iMC)));
                                                                case 'N_MC'
                                                                    set(h,'DisplayName',sprintf('%d',N_MC(iMC)));
                                                                case 'BW'
                                                                    set(h,'DisplayName',sprintf('%d',BW(b)));
                                                            end
                                                            set(h,'LineStyle',line);
                                                            set(h,'Color',color);
                                                    end
                                                    cd(dir_current);
                                                end
                                                k=k+1;
                                                if maxN_retx_ori~=maxN_retx(iretx)
                                                    maxN_retx(iretx)=maxN_retx_ori;
                                                    n_rep(irep)=n_rep_ori;
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
        end

        if AnalysisMC==1
            if ~strcmp(YToPrint,'cdfLatency')
                switch XToPrint
                    case 'SCS'
                        xvalue=1:length(SCS);
                    case 'density'
%                        xvalue=1:length(density);
                        xvalue=density;
%                         disp(xvalue);
%                         disp(yvalue);
                    case 'BLER'
                        xvalue=1:length(MCS_table);
                    case 'MIMOlayers'
                        xvalue=1:length(MIMOlayers);
                    case 'Tp'
                        xvalue=1:length(Tp);
                    case 'krep'
                        xvalue=1:length(n_rep);
                    case 'HARQretx'
                        xvalue=1:length(maxN_retx);
                    case 'DLUnicastTx'
                        xvalue=1:length(N_MC);
                    case 'N_MC'
                        xvalue=1:length(N_MC);
                    case 'BW'
                        xvalue=BW;%1:length(BW);
                end    
                if flag_fig==1 
                    figure(hfig);
                    if strcmp(YToPrint,'BoxPlotLatency')
                        xvalue=xvalue*0.7;
                            for indx=1:length(xvalue)
                                miboxplot2(yvalue(:,indx),xvalue(indx)-0.2+(iter-1)*0.2,0.15);
                            end
                    else
                        fp=plot(xvalue,yvalue,'DisplayName',sprintf('%s=%d',varcol2,aux2(iter)));
                        set(fp,'LineStyle',line);
                        set(fp,'Color',color);
                        set(fp,'Marker',marker);
                    end
                end                
            end
            if flag_fich==1
                if iter==1
                    fprintf(fid,'\n\t\t%s\t',xname);
                    fprintf(fid,'%s\n',print_column);
                end
                fprintf(fid,'\t\t%.4f\t',aux2(iter));
                for i=1:length(yvalue)
                    fprintf(fid,'%.4f\t',yvalue(i));
                end
                for i=1:length(yvalue2)
                    fprintf(fid,'%.4f\t',yvalue2(i));
                end
                fprintf(fid,'\n');
            end
        end
    end
    
    if AnalysisMC==1
        if ~strcmp(YToPrint,'cdfLatency')
            if flag_fig==1
                figure(hfig);
                box;
                set(gca,'FontSize',10);
                xlabel(xname,'FontSize',10);
                ylabel(yname,'FontSize',10);
                set(gcf,'Position',[500 500 330 230]);
                set(gca,'XTick',xvalue);
                set(gca,'XTickLabel',xShowValue);
%                 set(gca,'XLim',[xvalue(1)-xvalue(1)/3 xvalue(end)+xvalue(1)/3]);
                set(gca,'XLim',[xvalue(1)-xvalue(1)/2 xvalue(end)+xvalue(1)/2]);

%                 set(gca,'XTick',[20 25 30 40 50 60 70 80 90 100]);
%                 set(gca,'XTickLabel',{'20' ' ' '30' '40' '50' '60' '70' '80' '90' '100'});
%                 set(gca,'XLim',[10 110]);
                
                set(gca,'YScale','log');
                set(gca,'YLim',[0.1 50]);
                set(gca,'YTick',[0.1 0.5 1 5 10 50 100]);
                set(gca,'YTickLabel',[0.1 0.5 1 5 10 50 100]);
%                 set(gca,'YScale','linear');
%                 set(gca,'YLim',[0 100]);
%                 set(gca,'YTick',[0:20:100]);
                set(gca,'YGrid','On');
                legend off;
            end
        else
            figure(hcdf_latency);
            box;
            xlabel(xname);
            ylabel(yname);
            set(gca,'FontSize',10);
        end

        if flag_fig==1
            cd('results');
            if strcmp(YToPrint,'cdfLatency')
                hgsave(hcdf_latency,sprintf('%s.fig',coletilla4));
                disp(sprintf('%s.fig',coletilla4));
		hgsave(hcdf_sPacket,sprintf('cdf_%s.fig',coletilla4));
                disp(sprintf('cdf_%s.fig',coletilla4));
            else
                hgsave(hfig,sprintf('%s.fig',coletilla4));
                disp(sprintf('%s.fig',coletilla4));
                if strcmp(YToPrint,'TxPkts')
                    hgsave(hcdf_sPacket,sprintf('cdf_%s.fig',coletilla4));
                    disp(sprintf('cdf_%s.fig',coletilla4));
                end
            end
            cd ..; 
        end
%        close all;   
    end
end

if AnalysisMC==1
    if flag_fich==1
        fclose(fid);
    end
end



