SetActiveLib -work
comp -include "$dsn\src\firewall.vhd" 
comp -include "$dsn\src\TestBench\firewall_TB.vhd" 
asim +access +r TESTBENCH_FOR_firewall 
wave 
wave -noreg clk
wave -noreg reset
wave -noreg frame_in
wave -noreg frame_out
wave -noreg valid_out
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\firewall_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_firewall 
