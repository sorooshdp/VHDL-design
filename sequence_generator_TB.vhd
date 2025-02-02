LIBRARY ieee;
USE ieee.NUMERIC_STD.ALL;
USE ieee.std_logic_1164.ALL;

ENTITY sequence_generator_tb IS
END sequence_generator_tb;

ARCHITECTURE TB_ARCHITECTURE OF sequence_generator_tb IS
	-- Component declaration of the tested unit
	COMPONENT sequence_generator
		PORT (
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			y : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
	END COMPONENT;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	SIGNAL clk : STD_LOGIC;
	SIGNAL reset : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity
	SIGNAL y : STD_LOGIC_VECTOR(3 DOWNTO 0);

	-- Add your code here ...  
	SIGNAL clk_period : TIME := 10ns;

BEGIN

	-- Unit Under Test port map
	UUT : sequence_generator
	PORT MAP(
		clk => clk,
		reset => reset,
		y => y
	);

	clk_process : PROCESS
	BEGIN
		WHILE true LOOP
			clk <= '0';
			WAIT FOR clk_period / 2;
			clk <= '1';
			WAIT FOR clk_period / 2;
		END LOOP;
	END PROCESS;

	-- Combined Stimulus Process
	stim_process : PROCESS
	BEGIN
		reset <= '0';
		WAIT;
	END PROCESS;

END TB_ARCHITECTURE;

CONFIGURATION TESTBENCH_FOR_sequence_generator OF sequence_generator_tb IS
	FOR TB_ARCHITECTURE
		FOR UUT : sequence_generator
			USE ENTITY work.sequence_generator(sequence_generator);
		END FOR;
	END FOR;
END TESTBENCH_FOR_sequence_generator;