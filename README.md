# LoRaWAN_OTAA
MATLAB simulation model for LoRaWAN: OTAA and subsequent data communication.

The codes have been used in the paper:
K. Mikhaylov, "On the Uplink Traffic Distribution in Time for Duty-Cycle Constrained LoRaWAN Networks," in Proc. ICUMT 2021.

In case you use the codes, please refer to the paper above.

Code structure (example for the baseline scenario):
OTAA_v19_base.m - main file to be run (for baseline scenario);
LoRaWAN_OTAA_config_basic.m - file containing the config (automatically run by the main file);
km_LoRaWAN_OTAA_find_free_channel - helper function used by the main file;
km_LoRaWAN_OTAA_process_next_packet - helper function used by the main file;

