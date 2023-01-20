% krepetitionsDynamicSch

% retx indicates if a packet is retransmitted
retx=zeros(N,iter,N_MC);

RButilization_avg=0;
nframes=0;
currentTime=0;
flag=0;
while 1
    i=iter*((1:N)-1)+ind(1:N);
    nextPacketperUser=Tb(i);
        
    [nextT,user]=min(nextPacketperUser);

    for nUERx=1:N_MC
        if 1    %all RBs are allocated in the same symbols
            flag=0;
            while 1
                m=find(current_time_frame>=nextT);
                [n,p]=find(current_frame(:,m)==0);
                if isempty(m) || isempty(n)
                    past_frame=current_frame;
                    current_frame=next_frame;
                    next_frame=zeros(NRB,symbols_per_frame); %slots_per_frame
                    current_time_frame=current_time_frame+frame_l;
                    if traffic==0 && nframes<limInf
                        nframes=nframes+1;
                    else
                        nframes=nframes+1;
                        RButilization_avg=RButilization_avg+sum(sum(past_frame))/(slots_per_frame*symbPerSlot*NRB); %slots_per_frame*NRB
                    end
                    if flagControl
                        if link_direction==1
                        %     we reserve RBs for the SS/PBCH --> 1 block transmitted each 20
                        %     slots. Each block is composed of 240 subcarriers x 4 OFDM symbols
                            i_SSB=i_SSB-symbols_per_frame; %slots_per_frame
                            while i_SSB<=symbols_per_frame %slots_per_frame
                                next_frame(1:20,i_SSB:i_SSB+factor)=1;
                                i_SSB=i_SSB+20*symbPerSlot;
                            end
                        elseif link_direction==2
                            i_RACH=i_RACH-slots_per_frame;
                            while i_RACH<=slots_per_frame
                                iaux=0;
                                while iaux<slotsperms
                                    i_RACHaux=(i_RACH-1+iaux)*symbPerSlot+1;
                                    next_frame(1:12,i_RACHaux:i_RACHaux+factor)=1;
                                    iaux=iaux+1;
                                end
                                %next_frame(1:12,i_RACH:i_RACH+slotsperms-1)=1;
                                i_RACH=i_RACH+5*slotsperms;
                            end
                        end
                    end
                else
                    % this part must be adapted to work with minislots
                    for h=1:length(m)
                        if m(h)<=slots_per_frame-(n_rep-1)
                            cons=0;
                            while cons<n_rep
                            	p=find(current_frame(:,m(h)+cons)==0);
                                if length(p)>=RBs_UEs(user)
                                    cons=cons+1;
                                else
                                    break;
                                end
                            end
                            if cons<n_rep
                                continue;
                            end
                            currentTime=current_time_frame(m(h));
                            if ind(user)<iter && TaOriginal(user,ind(user)+1)<=currentTime
                                latency(user,ind(user))=100000;
                                ind(user)=ind(user)+1;
                                if ind(user)>iter
                                    return;
                                end
                                flag=2;
                                break;
                            end
                            for cons=0:n_rep-1
                                p=find(current_frame(:,m(h)+cons)==0);
                                for k=1:RBs_UEs(user)
                                    current_frame(p(k),m(h)+cons)=1;
                                end
                            end
                            perr=rand(1,n_rep);
                            [x,y]=find(perr>BLER);
                            if isempty(x)
                                tend=200000;
                            else
                                tend=current_time_frame(m(h))+Tslot*n_rep; 
                            end
                            flag=1;
                            break;
                        else
                            cons=0;
                            while cons<n_rep
                                if m(h)+cons<=slots_per_frame
                                    p=find(current_frame(:,m(h)+cons)==0);
                                    if length(p)>=RBs_UEs(user)
                                        cons=cons+1;
                                    else
                                        break;
                                    end
                                else
                                    p=find(next_frame(:,m(h)+cons-slots_per_frame)==0);
                                    if length(p)>=RBs_UEs(user)
                                        cons=cons+1;
                                    else
                                        break;
                                    end
                                end
                            end
                            if cons<n_rep
                                continue;
                            end
                            currentTime=current_time_frame(m(h));
                            if ind(user)<iter && TaOriginal(user,ind(user)+1)<=currentTime
                                latency(user,ind(user))=100000;
                                ind(user)=ind(user)+1;
                                if ind(user)>iter
                                    return;
                                end
                                flag=2;
                                break;
                            end
                            for cons=0:n_rep-1
                                if m(h)+cons<=slots_per_frame
                                    p=find(current_frame(:,m(h)+cons)==0);
                                    for k=1:RBs_UEs(user)
                                        current_frame(p(k),m(h)+cons)=1;
                                    end
                                else
                                    p=find(next_frame(:,m(h)+cons-slots_per_frame)==0);
                                    for k=1:RBs_UEs(user)
                                        next_frame(p(k),m(h)+cons-slots_per_frame)=1;
                                    end
                                end
                            end
                            perr=rand(1,n_rep);
                            [x,y]=find(perr>BLER);
                            if isempty(x)
                                tend=200000;
                            else
                                tend=current_time_frame(m(h))+Tslot*n_rep; 
                            end
                            flag=1;
                            break;
                        end
                    end
                    if flag==2
                        break;
                    end
                    if flag==0
                         for h=1:slots_per_frame
                            currentTime=current_time_frame(end)+Tslot+Tslot*(h-1);
                            if ind(user)<iter && TaOriginal(user,ind(user)+1)<=currentTime
                                latency(user,ind(user))=100000;
                                ind(user)=ind(user)+1;
                                if ind(user)>iter
                                    return;
                                end
                                flag=2;
                                break;
                            end
                            cons=0;
                            while cons<n_rep
                                p=find(next_frame(:,h+cons)==0);
                                if length(p)>=RBs_UEs(user)
                                    cons=cons+1;
                                else
                                    break;
                                end
                            end
                            if cons<n_rep
                                continue;
                            end
                            for cons=0:n_rep-1                                
                                p=find(next_frame(:,h+cons)==0);
                                for k=1:RBs_UEs(user)
                                    next_frame(p(k),h+cons)=1;
                                end
                            end
                            perr=rand(1,n_rep);
                            [x,y]=find(perr>BLER);
                            if isempty(x)
                                tend=200000;
                            else
                                tend=current_time_frame(end)+Tslot+Tslot*(h+n_rep-1);
                            end
                            flag=1;
                            break;
                         end
                    end
                    if flag==2
                        break;
                    end
                    if flag==0
                        disp('error: no debería estar aquí');
                    end
                    break;
                end
            end
        end
        if flag==2
            break;
        end
    end
    if flag==2
        continue;
    end
    if tend==200000
        latency(user,ind(user))=200000;
    else
        latency(user,ind(user))=TprocTx+(tend-nextT)+TprocRx;
    end
    ind(user)=ind(user)+1;
    if ind(user)>iter
        break;
    end
end