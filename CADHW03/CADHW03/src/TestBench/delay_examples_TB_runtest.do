SetActiveLib -work
comp -include "$dsn\src\delay.vhd" 
comp -include "$dsn\src\TestBench\delay_examples_TB.vhd" 
asim +access +r TESTBENCH_FOR_delay_examples 
wave 
wave -noreg qin
wave -noreg Y1
wave -noreg Y2
wave -noreg Y3
wave -noreg Y4
wave -noreg Y5
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\delay_examples_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_delay_examples 
