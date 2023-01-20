function [current_frame,tend,flag,fretx]=schedule_tx(nextT,ind_user,user,current_frame,current_time_frame,Tb,nRBperUE,Tslot,iter,BLER,Tp,deadtime,N_OS)

fretx=0;
tend=0;
flag=0;
m=find(current_time_frame>=nextT);

for h=1:length(m)
%     p=find(current_frame(:,m(h))==0);
    currentTime=current_time_frame(m(h));
%     if flagDiscardPkts==1
%         if length(Tb)>1
%             if ind_user<iter && Tb(ind_user+1,user)<=currentTime
%         %             latency(user,ind_user)=100000;
%         %             ind_user=ind_user+1;
%         %             if ind_user>iter
%         %                 return;
%         %             end
%                 flag=2;
%                 break;
%             end 
%         end
%     else
%         if ind_user<iter && Tb(ind_user+1,user)<=currentTime
%             disp('se hubiera descartado');
%         end
        if length(Tb)>1
           if ind_user<iter && currentTime-Tb(ind_user,user)>=deadtime
        %             latency(user,ind_user)=100000;
        %             ind_user=ind_user+1;
        %             if ind_user>iter
        %                 return;
        %             end
                flag=2;
                break;
           end 
        end
%     end 
    for k=0:N_OS-1
        p=find(current_frame(:,m(h)+k)==0);
        if length(p)<nRBperUE
            flag=0;
            break;
        end
        flag=1;
    end
       
    if flag==1
        for k=0:N_OS-1
            p=find(current_frame(:,m(h)+k)==0);
            current_frame(p(1:nRBperUE),m(h)+k)=1;
        end
        tend=current_time_frame(m(h))+N_OS*Tslot; %tend is equal to the start 
            % time of the next symbol or slot based on the corresponding case
        perror=rand();
        if perror<=BLER % packet is correctly received 
            fretx=1;
        end
        break;
    end
%     if length(p)>=nRBperUE
%         current_frame(p(1:nRBperUE),m(h))=1;
%         tend=current_time_frame(m(h))+Tslot; 
%         flag=1;
%         perror=rand();
%         if perror<=BLER % packet is correctly received 
%             fretx=1;
%         end
%         break;
%     end
end
