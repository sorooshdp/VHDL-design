library ieee;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

	-- Add your library and packages declaration here ...

entity bcd_counter_tb is
end bcd_counter_tb;

architecture TB_ARCHITECTURE of bcd_counter_tb is
	-- Component declaration of the tested unit
	component bcd_counter
	port(
		clk : in STD_LOGIC;
		reset : in STD_LOGIC;
		en : in STD_LOGIC;
		Q : out STD_LOGIC_VECTOR(3 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : STD_LOGIC;
	signal reset : STD_LOGIC;
	signal en : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal Q : STD_LOGIC_VECTOR(3 downto 0);

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : bcd_counter
		port map (
			clk => clk,
			reset => reset,
			en => en,
			Q => Q
		);		  
		
	-- Clock generation process
    clk_gen: process
    begin
        while true loop
            clk <= '0';
            wait for 10 ns;  -- Low period
            clk <= '1';
            wait for 10 ns;  -- High period
        end loop;
    end process;

	-- Add your stimulus here ...	 
	stimulus_process: process
    begin
        -- Reset the counter
        reset <= '1';
        wait for 20 ns;
        reset <= '0';

        -- Enable the counter
        en <= '1';
        wait for 200 ns;

        -- Disable the counter
        en <= '0';
        wait for 50 ns;

        -- Enable again
        en <= '1';
        wait for 200 ns;

        -- End simulation
        wait;
    end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_bcd_counter of bcd_counter_tb is
	for TB_ARCHITECTURE
		for UUT : bcd_counter
			use entity work.bcd_counter(behavioral);
		end for;
	end for;
end TESTBENCH_FOR_bcd_counter;

