SetActiveLib -work
comp -include "$dsn\src\decoder_3_to_8.vhd" 
comp -include "$dsn\src\TestBench\decoder3to8_TB.vhd" 
asim +access +r TESTBENCH_FOR_decoder3to8 
wave 
wave -noreg en
wave -noreg sel
wave -noreg y
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\decoder3to8_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_decoder3to8 
