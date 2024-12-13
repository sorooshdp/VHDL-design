SetActiveLib -work
comp -include "$dsn\src\sequence_generator.vhd" 
comp -include "$dsn\src\TestBench\sequence_generator_TB.vhd" 
asim +access +r TESTBENCH_FOR_sequence_generator 
wave 
wave -noreg clk
wave -noreg reset
wave -noreg y
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\sequence_generator_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_sequence_generator 
