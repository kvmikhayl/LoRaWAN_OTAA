clearvars;
%load the configs
LoRaWAN_OTAA_config_basic;
%update the seed       
rng(conf_iter_rng_seed);

%and let's start
calc_timestamp=datetime('now');
fprintf('Experiments started at %s\n',calc_timestamp);
conf_iter_num_EDs_size = size(conf_iter_num_EDs_values,2);
conf_iter_num_timeperiods = size(conf_iter_timeperiod_values,2);

%iteration(s) & configs loops
for calc_iter_timeperiod=1:1:conf_iter_num_timeperiods
    for calc_iter_num_EDs=1:1:conf_iter_num_EDs_size
        clearvars -except calc_iter_* conf_iter_*
        calc_timestamp=datetime('now');
        input_playground_num_EDs=conf_iter_num_EDs_values(calc_iter_num_EDs);
        fprintf('%s: simulations for ED=%i started\n',calc_timestamp,input_playground_num_EDs);
        for calc_iter_i=1:1:conf_iter_num_iterations
            clearvars -except result_iter_* calc_iter_* conf_iter_*
            input_playground_num_EDs=conf_iter_num_EDs_values(calc_iter_num_EDs);
            input_DR_UL_Join=conf_iter_DR_UL_Join;
            input_DR_UL_Data=conf_iter_DR_UL_Data;
            input_LoRaWAN_RX2_DR=conf_iter_DR_RX2;
           
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %INPUTS
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %frequency related
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %h1.5 868-868.6 MHz 25 mW e.r.p. ? 1% duty cycle or LBT +AFA - ERC(70-03)
            %h1.7 869.4-869.65 MHz 500 mW e.r.p. ? 10% duty cycle or LBT+AFA - ERC(70-03)
                                                %band1  band2 ...
            %input_uplink_freq_DC_limit_per_band=[1   0];
            input_uplink_freq_DC_limit_per_band=conf_iter_uplink_freq_DC_limit_per_band;
            %size=(1,Nbands) where Nbands is the number of frequency bands; %100%=1,10%=0,1,1%=0,01
            %uplink channels: 868.1, 868.3, 868.5
            %downlink channels: 868.1, 868.3, 868.5, 869.5
                                                %ch1 ch2 ...
            %input_uplink_freq_map_channels_bands=[1 2 3 0; 0 0 0 0];
            %input_uplink_freq_map_channels_bands=[1 0 0 0; 0 0 0 0];
            input_uplink_freq_map_channels_bands=conf_iter_uplink_freq_map_channels_bands;
            %size=(Nbands,Nchannels) where Nchannels is the cumulative number of all
            %frequency channels (both uplink and downlink); values 0 - channel does not belong to band, 1 channel
            %belongs to a band, a channel may belong only to one band
            %input_downlink_RX1_freq_DC_limit_per_band=[0 0];
            %input_downlink_RX1_freq_map_channels_bands=[0 0 0 0; 0 0 0 0];
            %input_downlink_RX2_freq_DC_limit_per_band=[0 1];
            %input_downlink_RX2_freq_map_channels_bands=[0 0 0 0; 0 0 0 4];
            input_downlink_RX1_freq_DC_limit_per_band=conf_iter_uplink_freq_DC_limit_per_band;
            input_downlink_RX1_freq_map_channels_bands=conf_iter_downlink_RX1_freq_map_channels_bands;
            input_downlink_RX2_freq_DC_limit_per_band=conf_iter_downlink_RX2_freq_DC_limit_per_band;
            input_downlink_RX2_freq_map_channels_bands=conf_iter_downlink_RX2_freq_map_channels_bands;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %LoRaWAN protocol parameters (recommended valus from the spec)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %input_LoRaWAN_RECEIVE_DELAY1_seconds=1;
            %input_LoRaWAN_RECEIVE_DELAY2_seconds=2;
            %input_LoRaWAN_JOIN_ACCEPT_DELAY1_seconds=5;
            %input_LoRaWAN_JOIN_ACCEPT_DELAY2_seconds=6;
            input_LoRaWAN_RECEIVE_DELAY1_seconds=conf_iter_LoRaWAN_RECEIVE_DELAY1_seconds;
            input_LoRaWAN_RECEIVE_DELAY2_seconds=conf_iter_LoRaWAN_RECEIVE_DELAY2_seconds;
            input_LoRaWAN_JOIN_ACCEPT_DELAY1_seconds=conf_iter_LoRaWAN_JOIN_ACCEPT_DELAY1_seconds;
            input_LoRaWAN_JOIN_ACCEPT_DELAY2_seconds=conf_iter_LoRaWAN_JOIN_ACCEPT_DELAY2_seconds;
            
            %additional parameters based on LL
            %input_LoRaWAN_OTAA_join_request_MAC_payload_bytes=8+8+2;%AppEUI+DevEUI+DevNonce, LoRaWAN Spec. 1.0.3, page 34
            %km: NOTE: option CFList considered empty
            %input_LoRaWAN_OTAA_join_accept_MAC_payload_bytes=3+3+4+1+1;%AppNonce,NetID,DevAddr,DLSettings,RxDelay; CFList is empty
            %input_LoRaWAN_OTAA_data_MAC_payload_bytes=18;

            input_LoRaWAN_OTAA_join_request_MAC_payload_bytes=conf_iter_LoRaWAN_OTAA_join_request_MAC_payload_bytes;
            input_LoRaWAN_OTAA_join_accept_MAC_payload_bytes=conf_iter_LoRaWAN_OTAA_join_accept_MAC_payload_bytes;
            input_LoRaWAN_OTAA_data_MAC_payload_bytes=conf_iter_LoRaWAN_OTAA_data_MAC_payload_bytes;

            %input_LoRaWAN_GW_RX_priority=1;
            input_LoRaWAN_GW_RX_priority=conf_iter_LoRaWAN_GW_RX_priority;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %device-related & distribution-related
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %input_playground_num_EDs=250;%number of the EDs
            input_LoRaWAN_ED_DR_Join=ones(1,input_playground_num_EDs)*input_DR_UL_Join;
            input_LoRaWAN_ED_DR_Data=ones(1,input_playground_num_EDs)*input_DR_UL_Data;

            %ED uplink join traffic
            %start join
            %MAC/App timings
            input_connect_starttime_seconds=ones(1,input_playground_num_EDs)*conf_iter_Join_start_window_const_s(calc_iter_timeperiod);
            input_connect_starttime_randn_seconds=conf_iter_Join_start_window_randn_s(calc_iter_timeperiod);
            input_connect_starttime_rand_seconds=conf_iter_Join_start_window_rand_s(calc_iter_timeperiod);     
            %repeat in case join is not sucesful (after end of packet)
            input_connect_repeattime_seconds=ones(1,input_playground_num_EDs)*conf_iter_Join_repeat_window_const_s(calc_iter_timeperiod);
            input_connect_repeattime_randn_seconds=conf_iter_Join_repeat_window_randn_s(calc_iter_timeperiod);
            input_connect_repeattime_rand_seconds=conf_iter_Join_repeat_window_rand_s(calc_iter_timeperiod);
            %ED uplink start
            input_report_starttime_seconds=ones(1,input_playground_num_EDs)*conf_iter_Data_start_window_const_s(calc_iter_timeperiod);
            input_report_starttime_randn_seconds=conf_iter_Data_start_window_randn_s(calc_iter_timeperiod);
            input_report_starttime_rand_seconds=conf_iter_Data_start_window_rand_s(calc_iter_timeperiod);
            %ED uplink periodic traffic
            input_report_repeattime_seconds=ones(1,input_playground_num_EDs)*conf_iter_Data_repeat_window_const_s(calc_iter_timeperiod);
            input_report_repeattime_randn_seconds=conf_iter_Data_repeat_window_randn_s(calc_iter_timeperiod);
            input_report_repeattime_rand_seconds=conf_iter_Data_repeat_window_rand_s(calc_iter_timeperiod);           
            %Simulation end
            input_simulation_endtime_s=conf_iter_simulation_endtime_s(calc_iter_timeperiod);
            

            %ED number uplink packets
            input_report_num_packets=ones(1,input_playground_num_EDs)*(-1);

            input_uplink_num_data_packets_per_ED=ones(1,input_playground_num_EDs)*conf_iter_uplink_num_data_packets_per_ED(calc_iter_num_EDs);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %timing related
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %input_simulation_endtime_s=1000;    
            %input_report_packets_snapshot_timestamp=[input_simulation_endtime_s*1/3 input_simulation_endtime_s*1/2 input_simulation_endtime_s*2/3];
            %input_report_packets_snapshot_timestamp=[input_simulation_endtime_s*1/12 input_simulation_endtime_s*2/12 input_simulation_endtime_s*3/12 input_simulation_endtime_s*4/12 input_simulation_endtime_s*5/12 input_simulation_endtime_s*6/12 input_simulation_endtime_s*7/12 input_simulation_endtime_s*8/12 input_simulation_endtime_s*9/12 input_simulation_endtime_s*10/12 input_simulation_endtime_s*11/12];
            input_report_packets_snapshot_timestamp=conf_iter_packets_snapshot_wrt_simtime*input_simulation_endtime_s;
            
            DEF_time_infinity=1000*input_simulation_endtime_s;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %results storing
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            result_ED_num_JoinRequest_messages_transmitted_perED=zeros(1,input_playground_num_EDs);
            result_ED_num_Data_messages_transmitted_perED=zeros(1,input_playground_num_EDs);
            result_ED_num_Data_messages_transmitted_perED_all_connected=zeros(1,input_playground_num_EDs);
            result_GW_num_JoinRequest_messages_received_perED=zeros(1,input_playground_num_EDs);
            result_GW_num_Data_messages_received_perED=zeros(1,input_playground_num_EDs);
            result_GW_num_Data_messages_received_perED_all_connected=zeros(1,input_playground_num_EDs);
            result_GW_num_JoinAccept_messages_scheduled_RX1_perED=zeros(1,input_playground_num_EDs);
            result_GW_num_JoinAccept_messages_scheduled_RX2_perED=zeros(1,input_playground_num_EDs);
            result_GW_num_JoinAccept_messages_transmitted_perED=zeros(1,input_playground_num_EDs);
            result_ED_connected_timestamp_perED=zeros(1,input_playground_num_EDs);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %create the basic matrices
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %create the matrix of status
            DEF_state_mtrx_status_joining=1;
            DEF_state_mtrx_status_reporting=2;
            calc_ED_states=ones(1,input_playground_num_EDs)*DEF_state_mtrx_status_joining;
            %calc_pkt_matrix=ones(input_playground_num_EDs,1)*DEF_state_mtrx_status_joining;

            %create the initial matrix of packets
            DEF_pkt_mtrx_column_source=1;
            DEF_pkt_mtrx_column_destination=2;
            DEF_pkt_mtrx_column_pkttype=3;
            DEF_pkt_mtrx_column_channel=4;
            DEF_pkt_mtrx_column_DR=5;
            DEF_pkt_mtrx_column_starttime=6;
            DEF_pkt_mtrx_column_endtime=7;
            DEF_pkt_mtrx_numcolumns=7;
            DEF_pkt_mtrx_pkttype_JoinRequest=1;
            DEF_pkt_mtrx_pkttype_JoinAccept=2;
            DEF_pkt_mtrx_pkttype_Data=3;
            DEF_pkt_proc_result_dropped=0;
            DEF_pkt_proc_result_delivered=1;
            DEF_pkt_mtrx_numlines=input_playground_num_EDs*2;

            calc_pkt_matrix=zeros(DEF_pkt_mtrx_numlines,DEF_pkt_mtrx_numcolumns);%km:*2 - to account for uplink & downlink
            calc_pkt_matrix_GW_shift=input_playground_num_EDs;
            calc_pkt_matrix_shadow_shift=calc_pkt_matrix_GW_shift+input_playground_num_EDs;
            calc_pkt_matrix_shadow_ED_shift=calc_pkt_matrix_shadow_shift;
            calc_pkt_matrix_shadow_GW_shift=calc_pkt_matrix_shadow_ED_shift+input_playground_num_EDs;

            calc_devices_connected=0;
            
            %result_cells_packets_snapshots=cell(DEF_pkt_mtrx_numlines,DEF_pkt_mtrx_numcolumns,size(input_report_packets_snapshot_timestamp,2));

            clearvars -except input_* DEF_* calc_* result_* conf_*

            for i_ED=1:1:input_playground_num_EDs
                %uplink
                calc_pkt_matrix(i_ED,DEF_pkt_mtrx_column_source)=i_ED;
                calc_pkt_matrix(i_ED,DEF_pkt_mtrx_column_starttime)=input_simulation_endtime_s+1;%km: just to be after the end of the time
                calc_pkt_matrix(i_ED,DEF_pkt_mtrx_column_endtime)=input_simulation_endtime_s+2;%km: just to be after the end of the time
                %downlink
                calc_pkt_matrix(i_ED+calc_pkt_matrix_GW_shift,DEF_pkt_mtrx_column_destination)=i_ED;
                calc_pkt_matrix(i_ED+calc_pkt_matrix_GW_shift,DEF_pkt_mtrx_column_starttime)=input_simulation_endtime_s+1;%km: just to be after the end of the time
                calc_pkt_matrix(i_ED+calc_pkt_matrix_GW_shift,DEF_pkt_mtrx_column_endtime)=input_simulation_endtime_s+2;%km: just to be after the end of the time
                %infterferences uplink
                calc_pkt_matrix(i_ED+calc_pkt_matrix_shadow_ED_shift,DEF_pkt_mtrx_column_source)=i_ED;
                calc_pkt_matrix(i_ED+calc_pkt_matrix_shadow_ED_shift,DEF_pkt_mtrx_column_starttime)=input_simulation_endtime_s+1;%km: just to be after the end of the time
                calc_pkt_matrix(i_ED+calc_pkt_matrix_shadow_ED_shift,DEF_pkt_mtrx_column_endtime)=input_simulation_endtime_s+2;%km: just to be after the end of the time
                %infterferences downlink
                calc_pkt_matrix(i_ED+calc_pkt_matrix_shadow_GW_shift,DEF_pkt_mtrx_column_destination)=i_ED;
                calc_pkt_matrix(i_ED+calc_pkt_matrix_shadow_GW_shift,DEF_pkt_mtrx_column_starttime)=input_simulation_endtime_s+1;%km: just to be after the end of the time
                calc_pkt_matrix(i_ED+calc_pkt_matrix_shadow_GW_shift,DEF_pkt_mtrx_column_endtime)=input_simulation_endtime_s+2;%km: just to be after the end of the time 
            end
            clearvars -except input_* DEF_* calc_* result_* conf_*

            %create the initial matrix of frequency resources
            DEF_freq_mtrx_column_ED=1;
            DEF_freq_mtrx_column_band=2;
            DEF_freq_mtrx_column_releasetime=3;
            DEF_freq_mtrx_numcolumns=3;
            calc_num_freq_bands=size(input_uplink_freq_DC_limit_per_band,2);
            calc_freq_matrix_GW_shift=input_playground_num_EDs*calc_num_freq_bands;
            calc_freq_matrix=zeros((input_playground_num_EDs+1)*calc_num_freq_bands,DEF_freq_mtrx_numcolumns);
            %EDs
            for i_ED=1:1:input_playground_num_EDs
                for i_band=1:1:calc_num_freq_bands
                    calc_freq_matrix((i_ED-1)*calc_num_freq_bands+i_band,DEF_freq_mtrx_column_ED)=i_ED;
                    calc_freq_matrix((i_ED-1)*calc_num_freq_bands+i_band,DEF_freq_mtrx_column_band)=i_band;
                    calc_freq_matrix((i_ED-1)*calc_num_freq_bands+i_band,DEF_freq_mtrx_column_releasetime)=-1;
                end
            end
            %GW
            for i_band=1:1:calc_num_freq_bands
                calc_freq_matrix(calc_freq_matrix_GW_shift+i_band,DEF_freq_mtrx_column_band)=i_band;
                calc_freq_matrix(calc_freq_matrix_GW_shift+i_band,DEF_freq_mtrx_column_releasetime)=-1;
            end
            clearvars -except input_* DEF_* calc_* result_* conf_*




            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %CALCULATIONS
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %calculate the on-air times for different SFs (based on Riccardo's code)
            SF=[12 11 10 9 8 7]; %DR0...5 respectively
            H=1; %0 or 1, presence of header
            CR=1; %Coding rate = 4/CR+4;
            BW=125000; %Bandwidth, Hz
            n_preamble=8; %symbols

            calc_ToA_join_request_seconds=zeros(1,6);
            B_total_payload_join_request=input_LoRaWAN_OTAA_join_request_MAC_payload_bytes;
            B_total_payload_join_accept=input_LoRaWAN_OTAA_join_accept_MAC_payload_bytes;
            B_total_payload_uplink_data=input_LoRaWAN_OTAA_data_MAC_payload_bytes;

            
            %ToA_tx computation [s]
            DE=[1 1 0 0 0 0];
            for i=1:1:size(SF,2)
                Tsym_tx(i)=(2.^SF(i))/BW;
                Tpreamble_tx(i)=(n_preamble+4.25)*Tsym_tx(i);
                CRC=1;
                Himpl=0;
                CR=1;
                PayloadSymbNb_tx_join_request=8+max(ceil((8*B_total_payload_join_request-4*SF(i)+28+16*CRC-20*Himpl)/(4*(SF(i)-2*DE(i))))*(CR+4));
                PayloadSymbNb_tx_uplink_data=8+max(ceil((8*B_total_payload_uplink_data-4*SF(i)+28+16*CRC-20*Himpl)/(4*(SF(i)-2*DE(i))))*(CR+4));
                Tpayload_tx_join_request(i)=PayloadSymbNb_tx_join_request*Tsym_tx(i);
                Tpayload_tx_uplink_data(i)=PayloadSymbNb_tx_uplink_data*Tsym_tx(i);
                calc_ToA_join_request_seconds(i)=Tpreamble_tx(i)+Tpayload_tx_join_request(i); 
                calc_ToA_uplink_data_seconds(i)=Tpreamble_tx(i)+Tpayload_tx_uplink_data(i); 
            end

            %ToA_rx computation [s]
            for i=1:1:size(SF,2)
                Tsym_rx(i)=(2.^SF(i))/BW;
                Tpreamble_rx(i)=(n_preamble+4.25)*Tsym_rx(i);
                CRC=0;
                Himpl=0;
                CR=1;
                PayloadSymbNb_rx=8+max(ceil((8*B_total_payload_join_accept-4*SF(i)+28+16*CRC-20*Himpl)/(4*(SF(i)-2*DE(i))))*(CR+4));
                Tpayload_rx_join_accept(i)=PayloadSymbNb_rx*Tsym_rx(i);
                calc_ToA_rx_join_accept(i)=Tpreamble_rx(i)+Tpayload_rx_join_accept(i); %time on air of a packet received with SFi
            end
            clearvars -except input_* DEF_* calc_* result_* conf_*

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Fill the matrix for the initial uplink traffic
            
            
            if conf_iter_start_all_connected==0
                for i_ED=1:1:input_playground_num_EDs    
                    %randomly select the channel for tranmission among the allowed and
                    %rename the variables       
                    temp_freq_DC_limit_per_band=input_uplink_freq_DC_limit_per_band;
                    temp_freq_map_channels_bands=input_uplink_freq_map_channels_bands;
                    temp_freq_matrix=calc_freq_matrix;
                    temp_i_ED=i_ED;
                    temp_current_timestamp=input_connect_starttime_seconds(1,i_ED)+rand*input_connect_starttime_rand_seconds+randn*input_connect_starttime_randn_seconds;
                    temp_selected_channel=km_LoRaWAN_OTAA_find_free_channel(temp_current_timestamp, temp_freq_DC_limit_per_band, temp_freq_map_channels_bands, temp_i_ED, temp_freq_matrix);
                    while temp_selected_channel==-1
                        temp_current_timestamp=temp_current_timestamp+input_connect_repeattime_seconds(1,i_ED)+rand*input_connect_repeattime_rand_seconds+randn*input_connect_repeattime_randn_seconds;
                        temp_selected_channel=km_LoRaWAN_OTAA_find_free_channel(temp_current_timestamp, temp_freq_DC_limit_per_band, temp_freq_map_channels_bands, temp_i_ED, temp_freq_matrix);
                    end  
                    temp_DR=input_LoRaWAN_ED_DR_Join(1,i_ED);
                    temp_ToA_s=calc_ToA_join_request_seconds(temp_DR+1);
                    %src and dst do not change
                    calc_pkt_matrix(i_ED,DEF_pkt_mtrx_column_pkttype)=DEF_pkt_mtrx_pkttype_JoinRequest;
                    calc_pkt_matrix(i_ED,DEF_pkt_mtrx_column_channel)=temp_selected_channel;
                    calc_pkt_matrix(i_ED,DEF_pkt_mtrx_column_DR)=temp_DR;
                    calc_pkt_matrix(i_ED,DEF_pkt_mtrx_column_starttime)=temp_current_timestamp;
                    calc_pkt_matrix(i_ED,DEF_pkt_mtrx_column_endtime)=temp_current_timestamp+temp_ToA_s;
                    %update the release time for the band to be used 
                    [temp_band, ~] = find(temp_freq_map_channels_bands == temp_selected_channel);
                    [temp_band_entry,~] = find(calc_freq_matrix(:,1)==i_ED & calc_freq_matrix(:,2)==temp_band);
                    temp_DC_limit=input_uplink_freq_DC_limit_per_band(temp_band);
                    temp_release_time=temp_current_timestamp+temp_ToA_s/temp_DC_limit;
                    calc_freq_matrix(temp_band_entry,3)=temp_release_time;
                end
            elseif conf_iter_start_all_connected==1
                calc_devices_connected=input_playground_num_EDs;
                result_ED_connected_timestamp_perED(1,:)=0;%log the connection time
                calc_ED_states(:)=DEF_state_mtrx_status_reporting;
                for i_ED=1:1:input_playground_num_EDs    
                    %randomly select the channel for tranmission among the allowed and
                    %rename the variables       
                    temp_freq_DC_limit_per_band=input_uplink_freq_DC_limit_per_band;
                    temp_freq_map_channels_bands=input_uplink_freq_map_channels_bands;
                    temp_freq_matrix=calc_freq_matrix;
                    temp_i_ED=i_ED;
                    temp_timestamp=input_report_starttime_seconds(1,temp_i_ED)+rand*input_report_starttime_rand_seconds+randn*input_report_starttime_randn_seconds;
                    %find the channel
                    temp_selected_channel=km_LoRaWAN_OTAA_find_free_channel(temp_timestamp, temp_freq_DC_limit_per_band, temp_freq_map_channels_bands, temp_i_ED, temp_freq_matrix); 
                    while temp_selected_channel==-1 %if channel is not available for this time, schedule later
                        temp_timestamp=temp_timestamp+input_report_starttime_seconds(1,temp_i_ED)+input_report_repeattime_seconds(1,temp_i_ED)+rand*input_report_repeattime_rand_seconds+randn*input_report_repeattime_randn_seconds;
                        temp_selected_channel=km_LoRaWAN_OTAA_find_free_channel(temp_timestamp, temp_freq_DC_limit_per_band, temp_freq_map_channels_bands, temp_i_ED, temp_freq_matrix);
                    end  
                    %define the DR
                    temp_DR=input_LoRaWAN_ED_DR_Data(1,temp_i_ED);
                    temp_ToA_s=calc_ToA_uplink_data_seconds(temp_DR+1);
                    %fill the packet
                    calc_pkt_matrix(temp_i_ED,DEF_pkt_mtrx_column_pkttype)=DEF_pkt_mtrx_pkttype_Data;
                    calc_pkt_matrix(temp_i_ED,DEF_pkt_mtrx_column_channel)=temp_selected_channel;
                    calc_pkt_matrix(temp_i_ED,DEF_pkt_mtrx_column_DR)=temp_DR;
                    calc_pkt_matrix(temp_i_ED,DEF_pkt_mtrx_column_starttime)=temp_timestamp;
                    calc_pkt_matrix(temp_i_ED,DEF_pkt_mtrx_column_endtime)=temp_timestamp+temp_ToA_s;
                    %update the release time
                    [temp_band, ~] = find(temp_freq_map_channels_bands == temp_selected_channel);
                    [temp_band_entry,~] = find(calc_freq_matrix(:,1)==temp_i_ED & calc_freq_matrix(:,2)==temp_band);
                    temp_DC_limit=input_uplink_freq_DC_limit_per_band(temp_band);
                    temp_release_time=temp_timestamp+temp_ToA_s/temp_DC_limit;
                    calc_freq_matrix(temp_band_entry,3)=temp_release_time;       
                    if(input_uplink_num_data_packets_per_ED(temp_i_ED)>0)
                        input_uplink_num_data_packets_per_ED(temp_i_ED)=input_uplink_num_data_packets_per_ED(temp_i_ED)-1;
                    end                                                        
                    if((conf_iter_debug_stop_on_all_connected==1)&&(calc_devices_connected==input_playground_num_EDs))
                        return;
                    end
                end                    
            end
            clearvars -except input_* DEF_* calc_* result_* conf_*

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %CORE CODE
            %process the packets one after another 

            calc_previous_timestamp_s=-1;
            calc_val_timestamp_current_s=min(calc_pkt_matrix(1:calc_pkt_matrix_shadow_shift,DEF_pkt_mtrx_column_endtime));
            while(calc_val_timestamp_current_s<input_simulation_endtime_s)
               clearvars -except input_* DEF_* calc_* result_* conf_*
               %process the next packet and see whether it gets received or not
               temp_calc_pkt_matrix=calc_pkt_matrix;
               [temp_pkt_device_src, temp_pkt_device_dst, temp_pkt_packet_type, temp_pkt_packet_result] = km_LoRaWAN_OTAA_process_next_packet_v3(temp_calc_pkt_matrix(:,:));    
               %find the packet row (work only with the non-shadow region)
               [temp_row_current_packet,~] = find(calc_pkt_matrix(1:calc_pkt_matrix_shadow_shift,DEF_pkt_mtrx_column_source)==temp_pkt_device_src & calc_pkt_matrix(1:calc_pkt_matrix_shadow_shift,DEF_pkt_mtrx_column_destination)==temp_pkt_device_dst);
               temp_pkt_start_time=calc_pkt_matrix(temp_row_current_packet,DEF_pkt_mtrx_column_starttime);
               temp_pkt_end_time=calc_pkt_matrix(temp_row_current_packet,DEF_pkt_mtrx_column_endtime);
               temp_pkt_channel=calc_pkt_matrix(temp_row_current_packet,DEF_pkt_mtrx_column_channel);
               temp_pkt_DR=calc_pkt_matrix(temp_row_current_packet,DEF_pkt_mtrx_column_DR);
               %copy the packet to the shadow part of the matrix
               calc_pkt_matrix(temp_row_current_packet+calc_pkt_matrix_shadow_shift,:)=calc_pkt_matrix(temp_row_current_packet,:);
               %fill the place of the packet with a placeholder
               calc_pkt_matrix(temp_row_current_packet,DEF_pkt_mtrx_column_starttime)=DEF_time_infinity;
               calc_pkt_matrix(temp_row_current_packet,DEF_pkt_mtrx_column_endtime)=DEF_time_infinity+1;

               %some recordings for statistics
               if(temp_pkt_device_src==0 & temp_pkt_packet_type==DEF_pkt_mtrx_pkttype_JoinAccept)
                  result_GW_num_JoinAccept_messages_transmitted_perED(1,temp_pkt_device_dst)=result_GW_num_JoinAccept_messages_transmitted_perED(1,temp_pkt_device_dst)+1;
               end
               if(temp_pkt_device_src~=0 & temp_pkt_packet_type==DEF_pkt_mtrx_pkttype_JoinRequest)
                  result_ED_num_JoinRequest_messages_transmitted_perED(1,temp_pkt_device_src)=result_ED_num_JoinRequest_messages_transmitted_perED(1,temp_pkt_device_src)+1;
                  if(temp_pkt_packet_result==DEF_pkt_proc_result_delivered)
                      result_GW_num_JoinRequest_messages_received_perED(1,temp_pkt_device_src)=result_GW_num_JoinRequest_messages_received_perED(1,temp_pkt_device_src)+1;
                  end
               end
               if(temp_pkt_device_src~=0 & temp_pkt_packet_type==DEF_pkt_mtrx_pkttype_Data)
                  result_ED_num_Data_messages_transmitted_perED(1,temp_pkt_device_src)=result_ED_num_Data_messages_transmitted_perED(1,temp_pkt_device_src)+1;
                  if(calc_devices_connected==input_playground_num_EDs)
                      result_ED_num_Data_messages_transmitted_perED_all_connected(1,temp_pkt_device_src)=result_ED_num_Data_messages_transmitted_perED_all_connected(1,temp_pkt_device_src)+1;
                  end
                  if(temp_pkt_packet_result==DEF_pkt_proc_result_delivered)
                      result_GW_num_Data_messages_received_perED(1,temp_pkt_device_src)=result_GW_num_Data_messages_received_perED(1,temp_pkt_device_src)+1;
                       if(calc_devices_connected==input_playground_num_EDs)&&(result_ED_num_Data_messages_transmitted_perED_all_connected(1,temp_pkt_device_src)>result_GW_num_Data_messages_received_perED_all_connected(1,temp_pkt_device_src))
                           result_GW_num_Data_messages_received_perED_all_connected(1,temp_pkt_device_src)=result_GW_num_Data_messages_received_perED_all_connected(1,temp_pkt_device_src)+1;
                       end
                  end      
               end

               %process the packet 
               if(temp_pkt_device_src==0)
                  %the packet has been sent by the GW 
                  if(temp_pkt_packet_result==DEF_pkt_proc_result_dropped)
                      %the packet has not been received - ED does not need to do anything
                  elseif(temp_pkt_packet_result==DEF_pkt_proc_result_delivered)
                      %the packet has been received correctly
                      switch temp_pkt_packet_type%check the type of the received packet
                          case DEF_pkt_mtrx_pkttype_JoinAccept
                              %this is a JoinAccept
                              if(calc_ED_states(temp_pkt_device_dst)==DEF_state_mtrx_status_joining)
                                  %change the state of the ED
                                  calc_ED_states(temp_pkt_device_dst)=DEF_state_mtrx_status_reporting;
                                  result_ED_connected_timestamp_perED(1,temp_pkt_device_dst)=temp_pkt_end_time;%log the connection time
                                  %reschedule and fill the new uplink packet
                                  if(input_uplink_num_data_packets_per_ED(temp_pkt_device_dst)~=0)
                                      %rename the variables       
                                      temp_freq_DC_limit_per_band=input_uplink_freq_DC_limit_per_band;
                                      temp_freq_map_channels_bands=input_uplink_freq_map_channels_bands;
                                      temp_freq_matrix=calc_freq_matrix;
                                      temp_i_ED=temp_pkt_device_dst;
                                      %NOTE: the end of the JoinRequest packet is used as
                                      %the new reference point                      
                                      temp_timestamp=temp_pkt_end_time+input_report_starttime_seconds(1,temp_i_ED)+rand*input_report_starttime_rand_seconds+randn*input_report_starttime_randn_seconds;
                                      %find the channel
                                      temp_selected_channel=km_LoRaWAN_OTAA_find_free_channel(temp_timestamp, temp_freq_DC_limit_per_band, temp_freq_map_channels_bands, temp_i_ED, temp_freq_matrix);
                                      while temp_selected_channel==-1 %if channel is not available for this time, schedule later
                                          temp_timestamp=temp_timestamp+input_report_starttime_seconds(1,temp_i_ED)+input_report_repeattime_seconds(1,temp_i_ED)+rand*input_report_repeattime_rand_seconds+randn*input_report_repeattime_randn_seconds;
                                          temp_selected_channel=km_LoRaWAN_OTAA_find_free_channel(temp_timestamp, temp_freq_DC_limit_per_band, temp_freq_map_channels_bands, temp_i_ED, temp_freq_matrix);
                                      end  
                                      %define the DR
                                      temp_DR=input_LoRaWAN_ED_DR_Data(1,temp_i_ED);
                                      temp_ToA_s=calc_ToA_uplink_data_seconds(temp_DR+1);
                                      %fill the packet
                                      calc_pkt_matrix(temp_i_ED,DEF_pkt_mtrx_column_pkttype)=DEF_pkt_mtrx_pkttype_Data;
                                      calc_pkt_matrix(temp_i_ED,DEF_pkt_mtrx_column_channel)=temp_selected_channel;
                                      calc_pkt_matrix(temp_i_ED,DEF_pkt_mtrx_column_DR)=temp_DR;
                                      calc_pkt_matrix(temp_i_ED,DEF_pkt_mtrx_column_starttime)=temp_timestamp;
                                      calc_pkt_matrix(temp_i_ED,DEF_pkt_mtrx_column_endtime)=temp_timestamp+temp_ToA_s;
                                      %update the release time
                                      [temp_band, ~] = find(temp_freq_map_channels_bands == temp_selected_channel);
                                      [temp_band_entry,~] = find(calc_freq_matrix(:,1)==temp_i_ED & calc_freq_matrix(:,2)==temp_band);
                                      temp_DC_limit=input_uplink_freq_DC_limit_per_band(temp_band);
                                      temp_release_time=temp_timestamp+temp_ToA_s/temp_DC_limit;
                                      calc_freq_matrix(temp_band_entry,3)=temp_release_time;       
                                      if(input_uplink_num_data_packets_per_ED(temp_i_ED)>0)
                                          input_uplink_num_data_packets_per_ED(temp_i_ED)=input_uplink_num_data_packets_per_ED(temp_i_ED)-1;
                                      end
                                  end
                                  calc_devices_connected=calc_devices_connected+1;
                                  if((conf_iter_debug_stop_on_all_connected==1)&&(calc_devices_connected==input_playground_num_EDs))
                                      return;
                                  end
                              end
                          otherwise
                              %ignore
                      end
                  end       
               else
                  %the packet has been sent by an ED
                  if(temp_pkt_packet_result==DEF_pkt_proc_result_dropped)
                      %the packet has not been received - GW does not need to do anything
                  elseif(temp_pkt_packet_result==DEF_pkt_proc_result_delivered)       
                      %the packet has been received by the GW
                      switch temp_pkt_packet_type%check the type of the received packet
                          case DEF_pkt_mtrx_pkttype_JoinRequest
                              %JoinRequest packet - attempt to schedule a response
                              temp_freq_matrix=calc_freq_matrix;
                              temp_i_GW=0;%the GW       
                              temp_i_ED=temp_pkt_device_src;
                              if(input_LoRaWAN_GW_RX_priority==1)
                                  %RX1 has priority - start by checking the RX1
                                  temp_timestamp=temp_pkt_end_time+input_LoRaWAN_JOIN_ACCEPT_DELAY1_seconds;
                                  temp_freq_DC_limit_per_band=input_downlink_RX1_freq_DC_limit_per_band;
                                  temp_freq_map_channels_bands=input_downlink_RX1_freq_map_channels_bands;
                                  [temp_band, ~] = find(temp_freq_map_channels_bands == temp_pkt_channel);
                                  if(input_downlink_RX1_freq_DC_limit_per_band(temp_band)>0)
                                      [temp_band_entry,~] = find(calc_freq_matrix(:,1)==temp_i_GW & calc_freq_matrix(:,2)==temp_band);
                                      temp_band_release_time=calc_freq_matrix(temp_band_entry,3);
                                      if(temp_band_release_time<=temp_timestamp)
                                          temp_selected_channel=temp_pkt_channel;
                                          result_GW_num_JoinAccept_messages_scheduled_RX1_perED(1,temp_i_ED)=result_GW_num_JoinAccept_messages_scheduled_RX1_perED(1,temp_i_ED)+1;
                                      else
                                          temp_selected_channel=-1;
                                      end
                                  else
                                      temp_selected_channel=-1;
                                  end
                                  temp_DR=temp_pkt_DR;
                                  if(temp_selected_channel==-1)%if impossible, try RX2
                                      temp_timestamp=temp_pkt_end_time+input_LoRaWAN_JOIN_ACCEPT_DELAY2_seconds;
                                      temp_freq_DC_limit_per_band=input_downlink_RX2_freq_DC_limit_per_band;
                                      temp_freq_map_channels_bands=input_downlink_RX2_freq_map_channels_bands;
                                      temp_selected_channel=km_LoRaWAN_OTAA_find_free_channel(temp_timestamp, temp_freq_DC_limit_per_band, temp_freq_map_channels_bands, temp_i_GW, temp_freq_matrix); 
                                      if(temp_selected_channel~=-1)
                                          result_GW_num_JoinAccept_messages_scheduled_RX2_perED(1,temp_i_ED)=result_GW_num_JoinAccept_messages_scheduled_RX2_perED(1,temp_i_ED)+1;
                                      end
                                      temp_DR=input_LoRaWAN_RX2_DR;
                                  end
                                  if(temp_selected_channel~=-1)%a channel has been found
                                      temp_ToA_s=calc_ToA_rx_join_accept(temp_DR+1);
                                      calc_pkt_matrix(calc_pkt_matrix_GW_shift+temp_i_ED,DEF_pkt_mtrx_column_channel)=temp_selected_channel;
                                      calc_pkt_matrix(calc_pkt_matrix_GW_shift+temp_i_ED,DEF_pkt_mtrx_column_DR)=temp_DR;
                                      calc_pkt_matrix(calc_pkt_matrix_GW_shift+temp_i_ED,DEF_pkt_mtrx_column_pkttype)=DEF_pkt_mtrx_pkttype_JoinAccept;
                                      calc_pkt_matrix(calc_pkt_matrix_GW_shift+temp_i_ED,DEF_pkt_mtrx_column_starttime)=temp_timestamp;
                                      calc_pkt_matrix(calc_pkt_matrix_GW_shift+temp_i_ED,DEF_pkt_mtrx_column_endtime)=temp_timestamp+temp_ToA_s;
                                      [temp_band, ~] = find(temp_freq_map_channels_bands == temp_selected_channel);
                                      [temp_band_entry,~] = find(calc_freq_matrix(:,1)==temp_i_GW & calc_freq_matrix(:,2)==temp_band);
                                      temp_DC_limit=temp_freq_DC_limit_per_band(temp_band);
                                      temp_release_time=temp_timestamp+temp_ToA_s/temp_DC_limit;
                                      calc_freq_matrix(temp_band_entry,3)=temp_release_time;
                                  end
                              elseif(input_LoRaWAN_GW_RX_priority==2)
                                  %RX2 has priority - start by checking the RX2
                                  temp_timestamp=temp_pkt_end_time+input_LoRaWAN_JOIN_ACCEPT_DELAY2_seconds;
                                  temp_freq_DC_limit_per_band=input_downlink_RX2_freq_DC_limit_per_band;
                                  temp_freq_map_channels_bands=input_downlink_RX2_freq_map_channels_bands;
                                  temp_selected_channel=km_LoRaWAN_OTAA_find_free_channel(temp_timestamp, temp_freq_DC_limit_per_band, temp_freq_map_channels_bands, temp_i_GW, temp_freq_matrix);
                                  if(temp_selected_channel~=-1)
                                      result_GW_num_JoinAccept_messages_scheduled_RX2_perED(1,temp_i_ED)=result_GW_num_JoinAccept_messages_scheduled_RX2_perED(1,temp_i_ED)+1;
                                  end
                                  temp_DR=input_LoRaWAN_RX2_DR;
                                  if(temp_selected_channel==-1)%if impossible, try RX1
                                      temp_timestamp=temp_pkt_end_time+input_LoRaWAN_JOIN_ACCEPT_DELAY1_seconds;
                                      temp_freq_DC_limit_per_band=input_downlink_RX1_freq_DC_limit_per_band;
                                      temp_freq_map_channels_bands=input_downlink_RX1_freq_map_channels_bands;
                                      [temp_band, ~] = find(temp_freq_map_channels_bands == temp_pkt_channel);
                                      if(input_downlink_RX1_freq_DC_limit_per_band(temp_band)>0)
                                          [temp_band_entry,~] = find(calc_freq_matrix(:,1)==temp_i_GW & calc_freq_matrix(:,2)==temp_band);
                                          temp_band_release_time=calc_freq_matrix(temp_band_entry,3);
                                          if(temp_band_release_time<=temp_timestamp)
                                              temp_selected_channel=temp_pkt_channel;
                                              result_GW_num_JoinAccept_messages_scheduled_RX1_perED(1,temp_i_ED)=result_GW_num_JoinAccept_messages_scheduled_RX1_perED(1,temp_i_ED)+1;
                                          else
                                              temp_selected_channel=-1;
                                          end
                                      else
                                          temp_selected_channel=-1;
                                      end
                                      temp_DR=temp_pkt_DR;
                                  end
                                  if(temp_selected_channel~=-1)%a channel has been found
                                      temp_ToA_s=calc_ToA_rx_join_accept(temp_DR+1);
                                      calc_pkt_matrix(calc_pkt_matrix_GW_shift+temp_i_ED,DEF_pkt_mtrx_column_channel)=temp_selected_channel;
                                      calc_pkt_matrix(calc_pkt_matrix_GW_shift+temp_i_ED,DEF_pkt_mtrx_column_DR)=temp_DR;
                                      calc_pkt_matrix(calc_pkt_matrix_GW_shift+temp_i_ED,DEF_pkt_mtrx_column_pkttype)=DEF_pkt_mtrx_pkttype_JoinAccept;
                                      calc_pkt_matrix(calc_pkt_matrix_GW_shift+temp_i_ED,DEF_pkt_mtrx_column_starttime)=temp_timestamp;
                                      calc_pkt_matrix(calc_pkt_matrix_GW_shift+temp_i_ED,DEF_pkt_mtrx_column_endtime)=temp_timestamp+temp_ToA_s;
                                      [temp_band, ~] = find(temp_freq_map_channels_bands == temp_selected_channel);
                                      [temp_band_entry,~] = find(calc_freq_matrix(:,1)==temp_i_GW & calc_freq_matrix(:,2)==temp_band);
                                      temp_DC_limit=temp_freq_DC_limit_per_band(temp_band);
                                      temp_release_time=temp_timestamp+temp_ToA_s/temp_DC_limit;
                                      calc_freq_matrix(temp_band_entry,3)=temp_release_time;
                                  end                  
                              end
                          otherwise
                          %ignore
                      end                  
                  end
                  clearvars temp_timestamp;
                  %in any case schedule for this ED the next packet
                  temp_timestamp=temp_pkt_start_time;
                  %rename the variables       
                  temp_freq_DC_limit_per_band=input_uplink_freq_DC_limit_per_band;
                  temp_freq_map_channels_bands=input_uplink_freq_map_channels_bands;
                  temp_freq_matrix=calc_freq_matrix;
                  temp_i_ED=temp_pkt_device_src;
                  if(calc_ED_states(temp_i_ED)==DEF_state_mtrx_status_joining)
                      temp_timestamp=temp_timestamp+input_connect_repeattime_seconds(1,temp_i_ED)+rand*input_connect_repeattime_rand_seconds+randn*input_connect_repeattime_randn_seconds;
                  elseif(calc_ED_states(temp_i_ED)==DEF_state_mtrx_status_reporting)
                      temp_timestamp=temp_timestamp+input_report_repeattime_seconds(1,temp_i_ED)+rand*input_report_repeattime_rand_seconds+randn*input_report_repeattime_randn_seconds;
                  end
                  %find the channel
                  %TODO: check the number of report packets
                  temp_selected_channel=km_LoRaWAN_OTAA_find_free_channel(temp_timestamp, temp_freq_DC_limit_per_band, temp_freq_map_channels_bands, temp_i_ED, temp_freq_matrix);
                  while temp_selected_channel==-1 %if channel is not available for this time, schedule later
                      if(calc_ED_states(temp_i_ED)==DEF_state_mtrx_status_joining)
                          temp_timestamp=temp_timestamp+input_connect_repeattime_seconds(1,temp_i_ED)+rand*input_connect_repeattime_rand_seconds+randn*input_connect_repeattime_randn_seconds;
                      elseif(calc_ED_states(temp_i_ED)==DEF_state_mtrx_status_reporting)
                          temp_timestamp=temp_timestamp+input_report_repeattime_seconds(1,temp_i_ED)+rand*input_report_repeattime_rand_seconds+randn*input_report_repeattime_randn_seconds;
                      end
                      temp_selected_channel=km_LoRaWAN_OTAA_find_free_channel(temp_timestamp, temp_freq_DC_limit_per_band, temp_freq_map_channels_bands, temp_i_ED, temp_freq_matrix);
                  end  
                  %fill the packet
                  if(calc_ED_states(temp_i_ED)==DEF_state_mtrx_status_joining)
                      temp_DR=input_LoRaWAN_ED_DR_Join(1,temp_i_ED);
                      calc_pkt_matrix(temp_i_ED,DEF_pkt_mtrx_column_pkttype)=DEF_pkt_mtrx_pkttype_JoinRequest;
                      temp_ToA_s=calc_ToA_join_request_seconds(temp_DR+1);
                      calc_pkt_matrix(temp_i_ED,DEF_pkt_mtrx_column_channel)=temp_selected_channel;
                      calc_pkt_matrix(temp_i_ED,DEF_pkt_mtrx_column_DR)=temp_DR;
                      calc_pkt_matrix(temp_i_ED,DEF_pkt_mtrx_column_starttime)=temp_timestamp;
                      calc_pkt_matrix(temp_i_ED,DEF_pkt_mtrx_column_endtime)=temp_timestamp+temp_ToA_s;
                       %update the release time
                      [temp_band, ~] = find(temp_freq_map_channels_bands == temp_selected_channel);
                      [temp_band_entry,~] = find(calc_freq_matrix(:,1)==temp_i_ED & calc_freq_matrix(:,2)==temp_band);
                      temp_DC_limit=input_uplink_freq_DC_limit_per_band(temp_band);
                      temp_release_time=temp_timestamp+temp_ToA_s/temp_DC_limit;
                      calc_freq_matrix(temp_band_entry,3)=temp_release_time;           
                  elseif(calc_ED_states(temp_i_ED)==DEF_state_mtrx_status_reporting)
                      if(input_uplink_num_data_packets_per_ED(temp_i_ED)~=0)
                        temp_DR=input_LoRaWAN_ED_DR_Data(1,temp_i_ED);
                        calc_pkt_matrix(temp_i_ED,DEF_pkt_mtrx_column_pkttype)=DEF_pkt_mtrx_pkttype_Data;
                        temp_ToA_s=calc_ToA_uplink_data_seconds(temp_DR+1);
                        calc_pkt_matrix(temp_i_ED,DEF_pkt_mtrx_column_channel)=temp_selected_channel;
                        calc_pkt_matrix(temp_i_ED,DEF_pkt_mtrx_column_DR)=temp_DR;
                        calc_pkt_matrix(temp_i_ED,DEF_pkt_mtrx_column_starttime)=temp_timestamp;
                        calc_pkt_matrix(temp_i_ED,DEF_pkt_mtrx_column_endtime)=temp_timestamp+temp_ToA_s;
                        %update the release time
                        [temp_band, ~] = find(temp_freq_map_channels_bands == temp_selected_channel);
                        [temp_band_entry,~] = find(calc_freq_matrix(:,1)==temp_i_ED & calc_freq_matrix(:,2)==temp_band);
                        temp_DC_limit=input_uplink_freq_DC_limit_per_band(temp_band);
                        temp_release_time=temp_timestamp+temp_ToA_s/temp_DC_limit;
                        calc_freq_matrix(temp_band_entry,3)=temp_release_time;   
                        if(input_uplink_num_data_packets_per_ED(temp_i_ED)>0)
                            input_uplink_num_data_packets_per_ED(temp_i_ED)=input_uplink_num_data_packets_per_ED(temp_i_ED)-1;
                        end            
                      end
                  end     
               end   
               %record
               if(isempty(input_report_packets_snapshot_timestamp)==0)
                   for i_num_entry=1:1:size(input_report_packets_snapshot_timestamp,2)
                      if(calc_previous_timestamp_s<=input_report_packets_snapshot_timestamp(1,i_num_entry))&&(calc_val_timestamp_current_s>input_report_packets_snapshot_timestamp(1,i_num_entry))
                          result_cells_packets_snapshots(:,:,i_num_entry)=calc_pkt_matrix;
                          %result_cells_packets_snapshots=cell(DEF_pkt_mtrx_numlines,DEF_pkt_mtrx_numcolumns,size(input_report_packets_snapshot_timestamp,2));
                      end
                   end
               end
               %update the timestamp
               calc_previous_timestamp_s=calc_val_timestamp_current_s;
               calc_val_timestamp_current_s=min(calc_pkt_matrix(1:calc_pkt_matrix_shadow_shift,DEF_pkt_mtrx_column_endtime));
            end

            clearvars -except input_* DEF_* calc_* result_* conf_*

            %save results per iteration
            result_iter_ED_connected_timestamp_perED(calc_iter_i,:)=result_ED_connected_timestamp_perED(1,:);
            result_iter_ED_num_Data_messages_transmitted_perED(calc_iter_i,:)=result_ED_num_Data_messages_transmitted_perED(1,:);
            result_iter_ED_num_Data_messages_transmitted_perED_all_connected(calc_iter_i,:)=result_ED_num_Data_messages_transmitted_perED_all_connected(1,:);
            result_iter_ED_num_JoinRequest_messages_transmitted_perED(calc_iter_i,:)=result_ED_num_JoinRequest_messages_transmitted_perED(1,:);
            result_iter_GW_num_Data_messages_received_perED(calc_iter_i,:)=result_GW_num_Data_messages_received_perED(1,:);
            result_iter_GW_num_Data_messages_received_perED_all_connected(calc_iter_i,:)=result_GW_num_Data_messages_received_perED_all_connected(1,:);
            result_iter_GW_num_JoinAccept_messages_scheduled_RX1_perED(calc_iter_i,:)=result_GW_num_JoinAccept_messages_scheduled_RX1_perED(1,:);
            result_iter_GW_num_JoinAccept_messages_scheduled_RX2_perED(calc_iter_i,:)=result_GW_num_JoinAccept_messages_scheduled_RX2_perED(1,:);
            result_iter_GW_num_JoinAccept_messages_transmitted_perED(calc_iter_i,:)=result_GW_num_JoinAccept_messages_transmitted_perED(1,:);
            result_iter_GW_num_JoinRequest_messages_received_perED(calc_iter_i,:)=result_GW_num_JoinRequest_messages_received_perED(1,:);
            if conf_iter_start_all_connected==0
                result_iter_cells_packets_snapshots(calc_iter_i,:,:,:)=result_cells_packets_snapshots(:,:,:);
            else
                result_iter_cells_packets_snapshots(calc_iter_i,:,:,:)=calc_pkt_matrix;
            end

            calc_timestamp=datetime('now');
            fprintf('%s: iteration %d of %d completed!\n',calc_timestamp,calc_iter_i,conf_iter_num_iterations);
        end
        temp_filename = sprintf('%s_%i_ED_%i_seconds.mat',conf_iter_filename_beginning,input_playground_num_EDs,conf_iter_timeperiod_values(calc_iter_timeperiod));
        save(temp_filename);
        calc_timestamp=datetime('now');
        fprintf('%s: simulations for ED=%i and period=%i seconds completed\n',calc_timestamp,input_playground_num_EDs,conf_iter_timeperiod_values(calc_iter_timeperiod)); 
    end
end
calc_timestamp=datetime('now');
fprintf('%s: thats all folks!\n',calc_timestamp); 



%histogram(result_cells_packets_snapshots(1:input_playground_num_EDs,6,3),nbins);
%result_cells_packets_snapshots(1:input_playground_num_EDs,6,2);

%nbins=input_Data_period_time_s/2;
%iteration=1;
%histogram(result_iter_cells_packets_snapshots(iteration,1:input_playground_num_EDs,6,3),nbins);
