function MCS=link_adaptation(CQI, MCS_table)
% this function returns the index to the position of the vector containing 
% the iMCS in the MCS table
% table 2

% link adaptation is based on CQI tables in 3GPP TS 38.214 V16.4.0 (2020-12)
% Table 5.2.2.1-3: 4-bit CQI Table 2, Table 5.2.2.1-4: 4-bit CQI Table 3
% ind_MCS indicates the index of the MCS in Table 5.1.3.1-2: MCS index 
% table 2 for PDSCH and Table 5.1.3.1-3: MCS index table 3 for PDSCH
% respectively
if MCS_table==2
    ind_MCS=[1 2 4 6 8 10 12 14 16 18 20 22 24 26 28];
elseif MCS_table==3
    ind_MCS=[1 3 5 7 9 11 13 15 17 19 21 23 25 27 29];
end

MCS=ind_MCS(CQI);
