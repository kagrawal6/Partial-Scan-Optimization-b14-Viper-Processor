read_file -format vhdl ../rtl/b14.vhd
compile 

get_cells –hierarchical

set_scan_configuration -style multiplexed_flip_flop
set_scan_element false {
reg1_reg[4]
reg1_reg[5]
reg1_reg[10]
reg1_reg[6]
reg1_reg[7]
reg1_reg[8]
reg1_reg[9]
reg1_reg[3]
reg1_reg[11]
reg1_reg[16]
reg1_reg[14]
reg1_reg[15]
reg1_reg[17]
reg1_reg[18]
reg1_reg[19]
reg1_reg[12]
reg1_reg[13]
B_reg
d_reg[0]
d_reg[1]
}
#remove lower scoap value dffs

#*?state_reg

# *?IR_reg[23]


set test_default_period 100
set_dft_signal -view existing_dft -type ScanClock -timing {45 55} -port clock
set_dft_signal -view existing_dft -type Reset -active_state 1 -port reset

set_dft_signal -view spec -type ScanDataIn -port SERIAL_IN
set_dft_signal -view spec -type ScanDataOut -port SERIAL_OUT
set_dft_signal -view spec -type ScanEnable -port SCAN_EN -active_state 1

create_test_protocol

compile_ultra -scan
compile -scan
preview_dft
dft_drc

set_scan_configuration -chain_count 1
set_scan_configuration -clock_mixing no_mix
set_scan_path chain1 -scan_data_in SERIAL_IN -scan_data_out SERIAL_OUT
insert_dft
set_scan_state scan_existing

report_area > reports/p2/area_b14_pscan.rpt
report_timing > reports/p2/timing_b14_pscan.rpt
report_power > reports/p2/power_b14_pscan.rpt
report_scan_path -view existing_dft -chain all > reports/p2/chain_b14_pscan.rep
report_scan_path -view existing_dft -cell all > reports/p2/cell_b14_pscan.rep

change_names -hierarchy -rule verilog
write -format verilog -hierarchy -out results/b14_pscan.vg
write -format ddc -hierarchy -output results/b14_pscan.ddc
write_scan_def -output results/b14_scan_pscan.def
set test_stil_netlist_format verilog
write_test_protocol -output results/b14_pscan.stil