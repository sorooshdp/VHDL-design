library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity sequence_generator_tb is
end sequence_generator_tb;

architecture TB_ARCHITECTURE of sequence_generator_tb is
	-- Component declaration of the tested unit
	component sequence_generator
	port(
		clk : in STD_LOGIC;
		reset : in STD_LOGIC;
		y : out STD_LOGIC_VECTOR(3 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : STD_LOGIC;
	signal reset : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal y : STD_LOGIC_VECTOR(3 downto 0);

	-- Add your code here ...  
	signal clk_period : time := 10ns;

begin

	-- Unit Under Test port map
	UUT : sequence_generator
		port map (
			clk => clk,
			reset => reset,
			y => y
		);

	-- Add your stimulus here ...
	clk_process: process 
	begin 
		while true loop
			clk <= '0';
			wait for clk_period / 2;
			clk <= '1';	 
			wait for clk_period / 2;
		end loop;
	end process;
	
	-- Combined Stimulus Process
    stim_process : process
    begin
        reset <= '0';
		wait;
    end process;
			
end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_sequence_generator of sequence_generator_tb is
	for TB_ARCHITECTURE
		for UUT : sequence_generator
			use entity work.sequence_generator(sequence_generator);
		end for;
	end for;
end TESTBENCH_FOR_sequence_generator;

