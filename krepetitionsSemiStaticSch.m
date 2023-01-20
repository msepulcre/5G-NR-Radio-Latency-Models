% krepetitionsSemiStaticSch

% this script contains the code for allocating radio resources for 
% transmissions using semi-static scheduling with k-repetitions 

for h=1:length(m)
    currentTime=current_time_frame(m(h));
    if ind(user)<iter && currentTime-TaOriginal(user,ind(user))>=deadtime
        flag=2;
        SegmentAllocated(user,iSegment(user,nUERx),nUERx)=0;
        while ind(user)<=iter && TaOriginal(user,ind(user))<=current_time_frame(end)
        %packet is dropped because a new packet is generated
            latency(user,ind(user))=100000; %aborted packet
            ind(user)=ind(user)+segmentationFactor;
        end
        break;
    end 

    cons=0;
    while cons<n_rep
        % p indicates the number of non-allocated RBs in slot/minislot m(h)
        p=find(aux_frame(:,m(h)+cons)==0);
        if length(p)>=RBs_UEs(user)
        % check if there are RBs_UEs(user) RBs in slot/minislot m(h)
        % every i*Tp slots/minislots and in consecutive slots/minislots for n_rep repetitions
            i=0;
            while m(h)+cons+i*Tp/Tsymbol<=symbols_per_frame+Tp/Tsymbol+cons
                if m(h)+cons+i*Tp/Tsymbol<=symbols_per_frame
                    flagMS=1;
                    for k=0:N_OS-1
                        p=find(aux_frame(:,m(h)+cons+k+i*Tp/Tsymbol)==0);
                        if length(p)<RBs_UEs(user)
                            flagMS=0;
                            break;
                        end
                    end
                else
                    flagMS=1;
                    for k=0:N_OS-1
                        p=find(aux_nextframe(:,m(h)+cons+k+i*Tp/Tsymbol-symbols_per_frame)==0);
                        if length(p)<RBs_UEs(user)
                            flagMS=0;
                            break;
                        end
                    end
                end

                if flagMS==1
                    i=i+1;
                else
                    break;
                end
            end
            if m(h)+cons+i*Tp/Tsymbol>symbols_per_frame
                cons=cons+1;
            else
                break;
            end
        else
            break;
        end
    end
    if cons<n_rep
        continue;
    else
        flag=1;
        if nframes==0 && iSegment(user,nUERx)>=0
%                         disp([user,iSegment(user,nUERx), ind(user)]);
            SegmentAllocated(user,iSegment(user,nUERx),nUERx)=1;
        end
    end
    ind_rep=ind(user);
    for cons=0:n_rep-1
        % allocate radio resources
        i=0;
        ind(user)=ind_rep;
        while m(h)+cons+i*Tp/Tsymbol<=symbols_per_frame+Tp/Tsymbol+cons && ind(user)<=iter
            if m(h)+cons+i*Tp/Tsymbol<=symbols_per_frame
                for k=0:N_OS-1
                    p=find(aux_frame(:,m(h)+cons+k+i*Tp/Tsymbol)==0);
                    aux_frame(p(1:RBs_UEs(user)),m(h)+cons+k+i*Tp/Tsymbol)=user;
                end
                if cons==n_rep-1
                    tend=current_time_frame(m(h)+cons+i*Tp/Tsymbol)+N_OS*Tsymbol; %tend is equal to the start time of the next symbol or slot based on the corresponding case
                end
            else
                for k=0:N_OS-1
                    p=find(aux_nextframe(:,m(h)+cons+k+i*Tp/Tsymbol-symbols_per_frame)==0);
                    aux_nextframe(p(1:RBs_UEs(user)),m(h)+cons+k+i*Tp/Tsymbol-symbols_per_frame)=user;
                end
                if cons==n_rep-1
                    tend=current_time_frame(m(h)+cons+i*Tp/Tsymbol-symbols_per_frame)+symbols_per_frame*Tsymbol+N_OS*Tsymbol; %tend is equal to the start time of the next symbol or slot based on the corresponding case
                end
            end
            %check if packet is received with error
            if cons==n_rep-1
                perr=rand(1,n_rep);
                [x,y]=find(perr>BLER);
                if isempty(x)   %all packets are received with error
                    latency(user,ind(user))=200000; %packet received with error
                else
                    % we save the latency of the last unicast transmission for a packet
                    % this is why the value of latency is overwrite with a new unicast transmission
                    latency(user,ind(user))=tend+TprocRx-TaOriginal(user,ind(user));
                end
            end                       
            i=i+1;
            ind(user)=ind(user)+segmentationFactor;
        end
    end
    if cons==n_rep-1
        if indtoScheduleNextFrame>N*segmentationFactor*N_MC
            disp('error: iSchedule cannot be higher than N');
        end
        toScheduleNextFrame(indtoScheduleNextFrame,:)=[user m(h)+i*Tp/Tsymbol-symbols_per_frame ind(user) nUERx];
        indtoScheduleNextFrame=indtoScheduleNextFrame+1;
        break;
    end
end        
