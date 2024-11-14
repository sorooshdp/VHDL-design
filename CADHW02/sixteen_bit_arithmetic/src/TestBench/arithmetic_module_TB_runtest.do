SetActiveLib -work
comp -include "$dsn\src\arithmetic_module.vhd" 
comp -include "$dsn\src\TestBench\arithmetic_module_TB.vhd" 
asim +access +r TESTBENCH_FOR_arithmetic_module 
wave 
wave -noreg A
wave -noreg B
wave -noreg fn
wave -noreg Cin
wave -noreg R
wave -noreg Cout
wave -noreg F_O
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\arithmetic_module_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_arithmetic_module 
