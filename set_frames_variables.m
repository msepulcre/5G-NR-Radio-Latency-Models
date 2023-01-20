if minislot_config==0
    current_time_frame=Tslot*[0:slots_per_frame-1];
    current_frame=zeros(NRB,slots_per_frame);
    past_frame=zeros(NRB,slots_per_frame);
    next_frame=zeros(NRB,slots_per_frame);
else
    symbols_per_frame=slots_per_frame*symbPerSlot;
    current_frame=zeros(NRB,symbols_per_frame);
    past_frame=zeros(NRB,symbols_per_frame);
    next_frame=zeros(NRB,symbols_per_frame);

    current_time_frame=zeros(1,symbols_per_frame);
    frame_aux=zeros(1,symbols_per_frame);

    Tsymbol=Tslot/symbPerSlot;
    switch minislot_config
        case 1
            %7-OS non-slot tx (NCP) or 6-OS non-slot tx (ECP)
            switch CP
                case 'NCP'
                    isymbol=1:7:symbols_per_frame;
                    current_time_frame(isymbol)=Tsymbol.*(isymbol-1);
                    frame_aux(isymbol)=1;
                case 'ECP'
                    isymbol=1:6:symbols_per_frame;
                    current_time_frame(isymbol)=Tsymbol.*(isymbol-1);
                    frame_aux(isymbol)=1;
            end
        case 2
            %4-OS non-slot tx 
            switch CP
                case 'NCP'
                    islot=1;
                    while islot<=slots_per_frame
                        isymbol=(islot-1)*symbPerSlot;
                        vsymbol=isymbol+[1 2 3 5 6 7 9 10 11];
                        current_time_frame(vsymbol)=Tsymbol.*(vsymbol-1);
                        frame_aux(vsymbol)=1;
                        islot=islot+1;
                    end
                case 'ECP'
                    isymbol=1:4:symbols_per_frame;
                    current_time_frame(isymbol)=Tsymbol.*(isymbol-1);
                    frame_aux(isymbol)=1;
            end
        case 3
            %2-OS non-slot tx 
            isymbol=1:2:symbols_per_frame;
            current_time_frame(isymbol)=Tsymbol.*(isymbol-1);
            frame_aux(isymbol)=1;
    end
    frame_l=frame_l*frame_aux;
end

clear isymbol vsymbol;

