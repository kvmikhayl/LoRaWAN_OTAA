%basic configs
conf_iter_num_iterations=100;
conf_iter_num_EDs_values = [1 2 4 8 16 32 64 128 256];
%conf_iter_num_EDs_values = [16];
%conf_iter_timeperiod_values = [164 184 204];
conf_iter_timeperiod_values = [160 200 240];
conf_iter_filename_beginning = 'LoRaWAN_OTAA_connected_1ch';

%some settings
conf_iter_debug_stop_on_all_connected=0;
conf_iter_start_all_connected=1;

%LoRaWAN DRs
conf_iter_DR_UL_Join=0;
conf_iter_DR_UL_Data=0;
conf_iter_DR_RX2=0;

%MAC/App timings
%Tx=Tx_const+rand*Tx_rand+randn*Tx_randn
%Join start
conf_iter_Join_start_window_const_s=ones(1,size(conf_iter_timeperiod_values,2))*0;
conf_iter_Join_start_window_rand_s=ones(1,size(conf_iter_timeperiod_values,2))*0;
conf_iter_Join_start_window_randn_s=ones(1,size(conf_iter_timeperiod_values,2))*0;
%Join repeat
conf_iter_Join_repeat_window_const_s=ones(1,size(conf_iter_timeperiod_values,2))*0;
conf_iter_Join_repeat_window_rand_s=ones(1,size(conf_iter_timeperiod_values,2))*0;
conf_iter_Join_repeat_window_randn_s=ones(1,size(conf_iter_timeperiod_values,2))*0;
%Data start
conf_iter_Data_start_window_const_s=ones(1,size(conf_iter_timeperiod_values,2))*0;
conf_iter_Data_start_window_rand_s=conf_iter_timeperiod_values;
conf_iter_Data_start_window_randn_s=ones(1,size(conf_iter_timeperiod_values,2))*0;
%Data repeat
conf_iter_Data_repeat_window_const_s=conf_iter_timeperiod_values;
conf_iter_Data_repeat_window_rand_s=ones(1,size(conf_iter_timeperiod_values,2))*0;
conf_iter_Data_repeat_window_randn_s=ones(1,size(conf_iter_timeperiod_values,2))*0;
%Simulation end
conf_iter_simulation_endtime_s=conf_iter_timeperiod_values+2;

%frequency configs
conf_iter_uplink_freq_DC_limit_per_band=        [1 0];
conf_iter_uplink_freq_map_channels_bands=       [1 0 0 0; 0 0 0 0];
conf_iter_downlink_RX1_freq_DC_limit_per_band=  [0 0];
conf_iter_downlink_RX1_freq_map_channels_bands= [0 0 0 0; 0 0 0 0];
conf_iter_downlink_RX2_freq_DC_limit_per_band=  [0 1];
conf_iter_downlink_RX2_freq_map_channels_bands= [0 0 0 0; 0 0 0 4];

%LoRaWAN timing parameters
conf_iter_LoRaWAN_RECEIVE_DELAY1_seconds=1;
conf_iter_LoRaWAN_RECEIVE_DELAY2_seconds=2;
conf_iter_LoRaWAN_JOIN_ACCEPT_DELAY1_seconds=5;
conf_iter_LoRaWAN_JOIN_ACCEPT_DELAY2_seconds=6;

%data packet payload 
conf_iter_LoRaWAN_OTAA_join_request_MAC_payload_bytes=23;
%km: NOTE: option CFList considered empty
conf_iter_LoRaWAN_OTAA_join_accept_MAC_payload_bytes=29;
conf_iter_LoRaWAN_OTAA_data_MAC_payload_bytes=22;
%input_uplink_num_data_packets_per_ED=ones(1,size(conf_iter_num_EDs_values,2))*(-1); %-1 means unlimited
conf_iter_uplink_num_data_packets_per_ED=ones(1,size(conf_iter_num_EDs_values,2))*(1); %-1 means unlimited

%other
conf_iter_packets_snapshot_wrt_simtime=[1/12 2/12 3/12 4/12 5/12 6/12 7/12 8/12 9/12 10/12 11/12];
conf_iter_LoRaWAN_GW_RX_priority=1;

%for tracktability
conf_iter_rng_seed=1234567890;