library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;



entity decoder3to8_tb is
end decoder3to8_tb;

architecture TB_ARCHITECTURE of decoder3to8_tb is

	component decoder3to8
	port(
		en : in STD_LOGIC;
		sel : in STD_LOGIC_VECTOR(2 downto 0);
		y : out STD_LOGIC_VECTOR(7 downto 0) );
	end component;


	signal en : STD_LOGIC;
	signal sel : STD_LOGIC_VECTOR(2 downto 0);

	signal y : STD_LOGIC_VECTOR(7 downto 0);


begin


	UUT : decoder3to8
		port map (
			en => en,
			sel => sel,
			y => y
		);

  
	stim_proc: process
    begin

        en <= '0';
        sel <= "000";
        wait for 10 ns;

        en <= '1';
        sel <= "000";
        wait for 10 ns;

        sel <= "001";
        wait for 10 ns;

        sel <= "011";
        wait for 10 ns;	
		
        sel <= "100";
        wait for 10 ns;
		
        sel <= "101";
        wait for 10 ns;
		
        sel <= "110";
        wait for 10 ns;

        sel <= "111";
        wait for 10 ns;

        en <= '0';
        wait for 10 ns;

        wait;
    end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_decoder3to8 of decoder3to8_tb is
	for TB_ARCHITECTURE
		for UUT : decoder3to8
			use entity work.decoder3to8(behavioral);
		end for;
	end for;
end TESTBENCH_FOR_decoder3to8;

