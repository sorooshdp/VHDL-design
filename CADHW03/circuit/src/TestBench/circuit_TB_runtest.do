SetActiveLib -work
comp -include "$dsn\src\circuit.vhd" 
comp -include "$dsn\src\TestBench\circuit_TB.vhd" 
asim +access +r TESTBENCH_FOR_circuit 
wave 
wave -noreg clk
wave -noreg reset
wave -noreg x
wave -noreg y
wave -noreg z
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\circuit_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_circuit 
