LIBRARY ieee;
USE ieee.NUMERIC_STD.ALL;
USE ieee.std_logic_1164.ALL;


ENTITY circuit_with_xor_and_tb IS
END circuit_with_xor_and_tb;

ARCHITECTURE TB_ARCHITECTURE OF circuit_with_xor_and_tb IS
	-- Component declaration of the tested unit
	COMPONENT circuit_with_xor_and
		PORT (
			en : IN STD_LOGIC;
			sel : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			full_decoder_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			out_final : OUT STD_LOGIC);
	END COMPONENT;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	SIGNAL en : STD_LOGIC;
	SIGNAL sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	SIGNAL full_decoder_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL out_final : STD_LOGIC;

BEGIN

	-- Unit Under Test port map
	UUT : circuit_with_xor_and
	PORT MAP(
		en => en,
		sel => sel,
		full_decoder_out => full_decoder_out,
		out_final => out_final
	);

	stim_proc : PROCESS
	BEGIN
		-- Enable the decoder
		en <= '1';

		-- Test case 1: sel = "000"
		sel <= "000";
		WAIT FOR 10 ns;

		-- Test case 1: sel = "001"
		sel <= "001";
		WAIT FOR 10 ns;

		-- Test case 1: sel = "010"
		sel <= "010";
		WAIT FOR 10 ns;

		-- Test case 2: sel = "011"
		sel <= "011";
		WAIT FOR 10 ns;

		-- Test case 3: sel = "100"
		sel <= "100";
		WAIT FOR 10 ns;

		-- Test case 3: sel = "101"
		sel <= "101";
		WAIT FOR 10 ns;

		-- Test case 3: sel = "110"
		sel <= "110";
		WAIT FOR 10 ns;

		-- Test case 4: sel = "111"
		sel <= "111";
		WAIT FOR 10 ns;

		-- Add more cases as necessary
		WAIT;
	END PROCESS;

END TB_ARCHITECTURE;

CONFIGURATION TESTBENCH_FOR_circuit_with_xor_and OF circuit_with_xor_and_tb IS
	FOR TB_ARCHITECTURE
		FOR UUT : circuit_with_xor_and
			USE ENTITY work.circuit_with_xor_and(behavioral);
		END FOR;
	END FOR;
END TESTBENCH_FOR_circuit_with_xor_and;