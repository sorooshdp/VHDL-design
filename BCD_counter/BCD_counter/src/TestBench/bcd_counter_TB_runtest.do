SetActiveLib -work
comp -include "$dsn\src\counter.vhd" 
comp -include "$dsn\src\TestBench\bcd_counter_TB.vhd" 
asim +access +r TESTBENCH_FOR_bcd_counter 
wave 
wave -noreg clk
wave -noreg reset
wave -noreg en
wave -noreg Q
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\bcd_counter_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_bcd_counter 
