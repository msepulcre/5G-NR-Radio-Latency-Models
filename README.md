# 5G-NR-Radio-Latency-Models
Latency models of the 5G NR radio network

This code implements in Matlab the latency models for 5G NR described in the following paper:

> M. C. Lucas-Estañ et al., "An Analytical Latency Model and Evaluation of the Capacity of 5G NR to Support V2X Services using V2N2V Communications," in IEEE Transactions on Vehicular Technology, 2022, doi: 10.1109/TVT.2022.3208306.
 
> Final version available at: https://ieeexplore.ieee.org/document/9897006

> Pre-print version available at: https://arxiv.org/abs/2201.06082

In order to comply with our sponsor guidelines, we would appreciate if any publication using this code references the above-mentioned publication.

The paper presents an analytical model that estimates the latency of 5G at the radio network level. The model accounts for the use of different numerologies (SCS, slot durations and Cyclic Prefixes), modulation and coding schemes, full-slots or mini-slots, semi-static and dynamic scheduling, different retransmission mechanisms, and broadcast/multicast or unicast transmissions. The model has been used to first analyze the impact of different 5G NR radio configurations on the latency. We then identify which radio configurations and scenarios can 5G NR satisfy the latency and reliability requirements of V2X services using V2N2V communications. The paper considers cooperative lane changes as a case study.

# Models 

RadioLatency.m is the main script you must run to get the latency performance of 5G NR

## Output

The output is saved in several files stored in the ./results folder:
* latency_matrix_xxx.txt: this is the main output file. It saves the latency experienced by each packet.
* latency_xxx.txt: this file saves number of the current iteration, the average latency, the maximum value of the experienced latency, percentage of the aborted packets, and percentage of RBs used.
* UE_data_xxx.txt: this file saves for each UE the distance to the gNb, the experienced CQI, and the Transport Block Size and number of RBs used to transmit the data packet
* Retx_matrix_xxx.txt: this file saves the number of times a packet has been retransmitted

The RadioToE2Emodel function is called at the end of the RadioLatency.m script. RadioToE2Emodel calculates the CDF and average value of the experienced latency. These parameters are saved in the ‘latency_RANradio_xxx.mat’ file that is used as input to calculate the end-to-end latency experienced in a 5G network using the end-to-end 5G latency model presented in:

> B. Coll-Perales et al., "End-to-End V2X Latency Modeling and Analysis in 5G Networks," in IEEE Transactions on Vehicular Technology, doi: 10.1109/TVT.2022.3224614.
 
> Final version available at: https://ieeexplore.ieee.org/document/9964110

> Pre-print version available at: https://arxiv.org/abs/2201.06082

> The code is available at https://github.com/msepulcre/5G-E2E-V2N2V-Latency-Models
 
You can also use the RadioLatencyAnalysis.m function to analyze the latency results achieved with the 5G NR radio latency model.
 
If you want to run the same configurations than the ones in the paper, you could simply run the scripts:

The output is saved in several files stored in the ./results folder:

* Transmission of periodic traffic using semi-static scheduling (SPS in DL and Configured Grant in UL) with k-repetitions: lanzar_RANlatency_highway_periodic_repetitions.m.
* Transmission of periodic traffic using semi-static scheduling (SPS in DL and Configured Grant in UL) with HARQ: lanzar_RANlatency_highway_periodic_HARQ.m 
* Transmission of aperiodic traffic using Dynamic Grant with HARQ: lanzar_RANlatency_highway_aperiodic_HARQ.m 

# Licence 
This code is licenced under the GNU GPLv2 license
