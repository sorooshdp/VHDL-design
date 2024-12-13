library ieee;
use ieee.std_logic_1164.all;


entity delay_examples_tb is
end delay_examples_tb;

architecture TB_ARCHITECTURE of delay_examples_tb is

	component delay_examples
	port(
		qin : in STD_LOGIC;
		Y1 : out STD_LOGIC;
		Y2 : out STD_LOGIC;
		Y3 : out STD_LOGIC;
		Y4 : out STD_LOGIC;
		Y5 : out STD_LOGIC );
	end component;

	signal qin : STD_LOGIC;

	signal Y1 : STD_LOGIC;
	signal Y2 : STD_LOGIC;
	signal Y3 : STD_LOGIC;
	signal Y4 : STD_LOGIC;
	signal Y5 : STD_LOGIC;

begin

	UUT : delay_examples
		port map (
			qin => qin,
			Y1 => Y1,
			Y2 => Y2,
			Y3 => Y3,
			Y4 => Y4,
			Y5 => Y5
		);

    process
    begin
			qin <= '0', '1' after 15 ns,'0' after 18 ns,'1' after 21 ns,'0' after 21.8 ns,'1' after 24 ns,'0' after 24.4 ns, '1' 
			after 30 ns,'0' after 35 ns, '1' after 35.6ns;
        wait;  
    end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_delay_examples of delay_examples_tb is
	for TB_ARCHITECTURE
		for UUT : delay_examples
			use entity work.delay_examples(behavioral);
		end for;
	end for;
end TESTBENCH_FOR_delay_examples;

