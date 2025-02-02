LIBRARY ieee;
USE ieee.NUMERIC_STD.ALL;
USE ieee.std_logic_1164.ALL;

ENTITY decoder3to8_tb IS
END decoder3to8_tb;

ARCHITECTURE TB_ARCHITECTURE OF decoder3to8_tb IS
	-- Component declaration of the tested unit
	COMPONENT decoder3to8
		PORT (
			en : IN STD_LOGIC;
			sel : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			y : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
	END COMPONENT;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	SIGNAL en : STD_LOGIC;
	SIGNAL sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	SIGNAL y : STD_LOGIC_VECTOR(7 DOWNTO 0);


BEGIN

	-- Unit Under Test port map
	UUT : decoder3to8
	PORT MAP(
		en => en,
		sel => sel,
		y => y
	);


	stim_proc : PROCESS
	BEGIN

		en <= '0';
		sel <= "000";
		WAIT FOR 10 ns;

		en <= '1';
		sel <= "000";
		WAIT FOR 10 ns;

		sel <= "001";
		WAIT FOR 10 ns;

		sel <= "011";
		WAIT FOR 10 ns;

		sel <= "100";
		WAIT FOR 10 ns;

		sel <= "101";
		WAIT FOR 10 ns;

		sel <= "110";
		WAIT FOR 10 ns;

		sel <= "111";
		WAIT FOR 10 ns;

		en <= '0';
		WAIT FOR 10 ns;

		WAIT;
	END PROCESS;
END TB_ARCHITECTURE;

CONFIGURATION TESTBENCH_FOR_decoder3to8 OF decoder3to8_tb IS
	FOR TB_ARCHITECTURE
		FOR UUT : decoder3to8
			USE ENTITY work.decoder3to8(behavioral);
		END FOR;
	END FOR;
END TESTBENCH_FOR_decoder3to8;