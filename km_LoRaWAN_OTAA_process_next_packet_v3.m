function [output_device_src, output_device_dst, output_packet_type, output_packet_result] = km_LoRaWAN_OTAA_process_next_packet_v2(temp_calc_pkt_matrix)            
    %description: the function processes the next packet and makes a
    %decision whether it has been received or not
    
    %defines
    DEF_pkt_mtrx_column_source=1;
    DEF_pkt_mtrx_column_destination=2;
    DEF_pkt_mtrx_column_pkttype=3;
    DEF_pkt_mtrx_column_channel=4;
    DEF_pkt_mtrx_column_DR=5;
    DEF_pkt_mtrx_column_starttime=6;
    DEF_pkt_mtrx_column_endtime=7;
    DEF_pkt_mtrx_numcolumns=7;

    DEF_pkt_proc_result_dropped=0;
    DEF_pkt_proc_result_delivered=1;    
    
    
    %CODE
    %find the smallest value (note: if several identical values - returns the first)
    [~,temp_next_time_index] = min(temp_calc_pkt_matrix(1:size(temp_calc_pkt_matrix,1)/2,DEF_pkt_mtrx_column_endtime));
    temp_current_packet_channel=temp_calc_pkt_matrix(temp_next_time_index,DEF_pkt_mtrx_column_channel);
    temp_current_packet_DR=temp_calc_pkt_matrix(temp_next_time_index,DEF_pkt_mtrx_column_DR);
    temp_current_packet_starttime=temp_calc_pkt_matrix(temp_next_time_index,DEF_pkt_mtrx_column_starttime);
    temp_current_packet_endtime=temp_calc_pkt_matrix(temp_next_time_index,DEF_pkt_mtrx_column_endtime);
    %NOTE: by the very logic of operation - if another packet is still in the
    %table, it will interfere
    temp_other_packets_started_during_current_one=find(temp_calc_pkt_matrix(:,DEF_pkt_mtrx_column_starttime)<temp_current_packet_endtime & temp_calc_pkt_matrix(:,DEF_pkt_mtrx_column_starttime)>temp_current_packet_starttime);
    temp_other_packets_ending_during_current_one=find(temp_calc_pkt_matrix(:,DEF_pkt_mtrx_column_endtime)<temp_current_packet_endtime & temp_calc_pkt_matrix(:,DEF_pkt_mtrx_column_endtime)>temp_current_packet_starttime);
    temp_other_packets_accomodating_current_one=find(temp_calc_pkt_matrix(:,DEF_pkt_mtrx_column_starttime)<temp_current_packet_starttime & temp_calc_pkt_matrix(:,DEF_pkt_mtrx_column_endtime)>temp_current_packet_endtime);
    temp_other_packets_equal_current_one=find(temp_calc_pkt_matrix(:,DEF_pkt_mtrx_column_starttime)==temp_current_packet_starttime & temp_calc_pkt_matrix(:,DEF_pkt_mtrx_column_endtime)==temp_current_packet_endtime);
    
    %cat(1,temp_other_packets_started_during_current_one,temp_other_packets_ending_during_current_one,temp_other_packets_accomodating_current_one);
    temp_interfering_packets=cat(1,temp_other_packets_started_during_current_one,temp_other_packets_ending_during_current_one,temp_other_packets_accomodating_current_one,temp_other_packets_equal_current_one);
    %temp_interfering_packets=[temp_other_packets_started_during_current_one temp_other_packets_ending_during_current_one temp_other_packets_accomodating_current_one];
    
    if(size(temp_interfering_packets,1)>1)%there are overlaps
        %see if there are overlaps in channel
        temp_other_packets_overlapping_in_channel=find(temp_calc_pkt_matrix(:,DEF_pkt_mtrx_column_channel)==temp_current_packet_channel);
        [temp_packets_overlapping_time_and_frequency,~]=intersect(temp_other_packets_overlapping_in_channel,temp_interfering_packets);
        if(size(temp_packets_overlapping_time_and_frequency,1)>1)
            temp_other_packets_overlapping_in_DR=find(temp_calc_pkt_matrix(:,DEF_pkt_mtrx_column_DR)==temp_current_packet_DR);
            [temp_packets_overlapping_time_frequency_and_DR,~]=intersect(temp_packets_overlapping_time_and_frequency,temp_other_packets_overlapping_in_DR);
            if(size(temp_packets_overlapping_time_frequency_and_DR,1)>1)
                output_packet_result=DEF_pkt_proc_result_dropped;
            else
                %1 is ok since we have this packet itself
                output_packet_result=DEF_pkt_proc_result_delivered;
            end
        else
            %1 is ok since we have this packet itself
            output_packet_result=DEF_pkt_proc_result_delivered;
        end
    else%no overlaps
        output_packet_result=DEF_pkt_proc_result_delivered;
    end
    output_device_src=temp_calc_pkt_matrix(temp_next_time_index,DEF_pkt_mtrx_column_source);
    output_device_dst=temp_calc_pkt_matrix(temp_next_time_index,DEF_pkt_mtrx_column_destination);
    output_packet_type=temp_calc_pkt_matrix(temp_next_time_index,DEF_pkt_mtrx_column_pkttype);
end