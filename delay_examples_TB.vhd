LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY delay_examples_tb IS
END delay_examples_tb;

ARCHITECTURE TB_ARCHITECTURE OF delay_examples_tb IS

	COMPONENT delay_examples
		PORT (
			qin : IN STD_LOGIC;
			Y1 : OUT STD_LOGIC;
			Y2 : OUT STD_LOGIC;
			Y3 : OUT STD_LOGIC;
			Y4 : OUT STD_LOGIC;
			Y5 : OUT STD_LOGIC);
	END COMPONENT;

	SIGNAL qin : STD_LOGIC;

	SIGNAL Y1 : STD_LOGIC;
	SIGNAL Y2 : STD_LOGIC;
	SIGNAL Y3 : STD_LOGIC;
	SIGNAL Y4 : STD_LOGIC;
	SIGNAL Y5 : STD_LOGIC;

BEGIN

	UUT : delay_examples
	PORT MAP(
		qin => qin,
		Y1 => Y1,
		Y2 => Y2,
		Y3 => Y3,
		Y4 => Y4,
		Y5 => Y5
	);

	PROCESS
	BEGIN
		qin <= '0', '1' AFTER 15 ns, '0' AFTER 18 ns, '1' AFTER 21 ns, '0' AFTER 21.8 ns, '1' AFTER 24 ns, '0' AFTER 24.4 ns, '1'
			AFTER 30 ns, '0' AFTER 35 ns, '1' AFTER 35.6ns;
		WAIT;
	END PROCESS;

END TB_ARCHITECTURE;

CONFIGURATION TESTBENCH_FOR_delay_examples OF delay_examples_tb IS
	FOR TB_ARCHITECTURE
		FOR UUT : delay_examples
			USE ENTITY work.delay_examples(behavioral);
		END FOR;
	END FOR;
END TESTBENCH_FOR_delay_examples;