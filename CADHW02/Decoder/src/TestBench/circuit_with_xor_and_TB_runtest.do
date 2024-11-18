SetActiveLib -work
comp -include "$dsn\src\custom_circuit.vhd" 
comp -include "$dsn\src\TestBench\circuit_with_xor_and_TB.vhd" 
asim +access +r TESTBENCH_FOR_circuit_with_xor_and 
wave 
wave -noreg en
wave -noreg sel
wave -noreg full_decoder_out
wave -noreg out_final
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\circuit_with_xor_and_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_circuit_with_xor_and 
