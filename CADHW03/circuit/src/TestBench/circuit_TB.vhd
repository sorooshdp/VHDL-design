library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity circuit_tb is
end circuit_tb;

architecture TB_ARCHITECTURE of circuit_tb is
	-- Component declaration of the tested unit
	component circuit
	port(
		clk : in STD_LOGIC;
		reset : in STD_LOGIC;
		x : out STD_LOGIC_VECTOR(2 downto 0);
		y : out STD_LOGIC_VECTOR(2 downto 0);
		z : out STD_LOGIC_VECTOR(2 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : STD_LOGIC;
	signal reset : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal x : STD_LOGIC_VECTOR(2 downto 0);
	signal y : STD_LOGIC_VECTOR(2 downto 0);
	signal z : STD_LOGIC_VECTOR(2 downto 0);

	-- Add your code here ... 
	signal clk_period : time := 10ns;

begin

	-- Unit Under Test port map
	UUT : circuit
		port map (
			clk => clk,
			reset => reset,
			x => x,
			y => y,
			z => z
		);

	-- Add your stimulus here ...
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
        reset <= '1';
		wait for 30ns;
		reset <= '0';
		wait;
    end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_circuit of circuit_tb is
	for TB_ARCHITECTURE
		for UUT : circuit
			use entity work.circuit(circuit);
		end for;
	end for;
end TESTBENCH_FOR_circuit;

