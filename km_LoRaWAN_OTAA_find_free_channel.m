function output_channel = km_LoRaWAN_OTAA_find_free_channel(temp_current_timestamp, ...
    temp_freq_DC_limit_per_band, temp_freq_map_channels_bands, temp_i_ED, temp_freq_matrix)
    %description: the function finds and randomly selects an available
    %frequency channel considering the allowed bands and the DC limit
    %NOTE: the function returns -1 if no channels exist, and number of a
    %channel [1...] otherwise

    %inputs
    DEF_freq_mtrx_column_ED=1;
    DEF_freq_mtrx_column_band=2;
    DEF_freq_mtrx_column_releasetime=3;
    DEF_freq_mtrx_numcolumns=3;

    %find the allowed (i.e., nonzero) bands
    temp_alloweduplink_bands = find(temp_freq_DC_limit_per_band(1,:));
    %check which bands can be used now in accordance to DC limit
    temp_DCallowed_band_indeces_thisED = find(temp_freq_matrix(:,DEF_freq_mtrx_column_ED)==temp_i_ED);
    temp_DCallowed_band_indeces=find(temp_freq_matrix(temp_DCallowed_band_indeces_thisED,DEF_freq_mtrx_column_releasetime)<=temp_current_timestamp);
    temp_DCallowed_bands=temp_freq_matrix(temp_DCallowed_band_indeces,DEF_freq_mtrx_column_band);
    %specify bands which can be used
    [temp_allowed_bands,~]=intersect(temp_alloweduplink_bands,temp_DCallowed_bands);
    
    if (isempty(temp_allowed_bands)==1)%no intersections
        output_channel=-1;
    else
        %specify the number of channels belonging to these bands
        temp_i_num_bands=size(temp_allowed_bands,1);
        %compose array of the unique frequency channels
        temp_uplink_freq_map_channels_bands_copy=temp_freq_map_channels_bands;    
        for temp_i_band=1:1:temp_i_num_bands
            if(ismember(temp_i_band,temp_allowed_bands(:)) == 1)
               %do nothing
            else
                temp_uplink_freq_map_channels_bands_copy(temp_i_band,:)=0;
            end
        end
        [~,~,temp_nonzero_channel_values] = find(temp_uplink_freq_map_channels_bands_copy);
        temp_i_num_channels=size(temp_nonzero_channel_values,1);
        %randomly select a channel
        temp_rand_idx=floor(rand()*temp_i_num_channels)+1;
        temp_rand_chan=temp_nonzero_channel_values(temp_rand_idx,1);
        output_channel=temp_rand_chan;
    end 

end