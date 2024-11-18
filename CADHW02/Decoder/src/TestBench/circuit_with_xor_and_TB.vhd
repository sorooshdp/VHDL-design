library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity circuit_with_xor_and_tb is
end circuit_with_xor_and_tb;

architecture TB_ARCHITECTURE of circuit_with_xor_and_tb is
	-- Component declaration of the tested unit
	component circuit_with_xor_and
	port(
		en : in STD_LOGIC;
		sel : in STD_LOGIC_VECTOR(2 downto 0);
		full_decoder_out : out STD_LOGIC_VECTOR(7 downto 0);
		out_final : out STD_LOGIC );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal en : STD_LOGIC;
	signal sel : STD_LOGIC_VECTOR(2 downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal full_decoder_out : STD_LOGIC_VECTOR(7 downto 0);
	signal out_final : STD_LOGIC;

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : circuit_with_xor_and
		port map (
			en => en,
			sel => sel,
			full_decoder_out => full_decoder_out,
			out_final => out_final
		);

	-- Add your stimulus here ...
	
	stim_proc: process
    begin
        -- Enable the decoder
        en <= '1';

        -- Test case 1: sel = "000"
        sel <= "000"; wait for 10 ns;
    
        -- Test case 1: sel = "001"
        sel <= "001"; wait for 10 ns;

        -- Test case 1: sel = "010"
        sel <= "010"; wait for 10 ns;

        -- Test case 2: sel = "011"
        sel <= "011"; wait for 10 ns;

        -- Test case 3: sel = "100"
        sel <= "100"; wait for 10 ns;
    
        -- Test case 3: sel = "101"
        sel <= "101"; wait for 10 ns;
    
        -- Test case 3: sel = "110"
        sel <= "110"; wait for 10 ns;

        -- Test case 4: sel = "111"
        sel <= "111"; wait for 10 ns;

        -- Add more cases as necessary
        wait;
    end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_circuit_with_xor_and of circuit_with_xor_and_tb is
	for TB_ARCHITECTURE
		for UUT : circuit_with_xor_and
			use entity work.circuit_with_xor_and(behavioral);
		end for;
	end for;
end TESTBENCH_FOR_circuit_with_xor_and;

