library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity serial_to_parallel_tb is
end serial_to_parallel_tb;

architecture TB_ARCHITECTURE of serial_to_parallel_tb is
	-- Component declaration of the tested unit
	component serial_to_parallel
	port(
		Reset : in STD_LOGIC;
		Clk : in STD_LOGIC;
		DataIn : in STD_LOGIC;
		Start : in STD_LOGIC;
		Pattern : in STD_LOGIC_VECTOR(7 downto 0);
		DataOut : out STD_LOGIC_VECTOR(7 downto 0);
		Valid : out STD_LOGIC;
		Found : out STD_LOGIC );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal Reset : STD_LOGIC;
	signal Clk : STD_LOGIC := '0';
	signal DataIn : STD_LOGIC;
	signal Start : STD_LOGIC;
	signal Pattern : STD_LOGIC_VECTOR(7 downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal DataOut : STD_LOGIC_VECTOR(7 downto 0);
	signal Valid : STD_LOGIC;
	signal Found : STD_LOGIC;

	-- Add your code here ...	   
	signal clk_period : time := 100ns; 


begin

	-- Unit Under Test port map
	UUT : serial_to_parallel
		port map (
			Reset => Reset,
			Clk => Clk,
			DataIn => DataIn,
			Start => Start,
			Pattern => Pattern,
			DataOut => DataOut,
			Valid => Valid,
			Found => Found
		);

	-- Add your stimulus here ...
	
    -- Clock Generation Process
    clk_process : process
    begin
        while true loop
            Clk <= '0';
            wait for clk_period / 2;
            Clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;
	
    -- Combined Stimulus Process
    stim_process : process
    begin
        Pattern <= "10101010";
        Reset <= '1';
        wait for 200 ns;
        Reset <= '0';

        Start  <= '1'; wait for clk_period;
        DataIn <= '1'; wait for clk_period;
        DataIn <= '0'; wait for clk_period;
        DataIn <= '1'; wait for clk_period;
        DataIn <= '0'; wait for clk_period;
        DataIn <= '1'; wait for clk_period;
        DataIn <= '0'; wait for clk_period;
        DataIn <= '1'; wait for clk_period;
        DataIn <= '0'; wait for clk_period;
        Start <= '0';
        wait for clk_period * 10;

        Pattern <= "11110000";
        Reset <= '1';
        wait for 200 ns;
        Reset <= '0';

        Start <= '1';  wait for clk_period;
        DataIn <= '1'; wait for clk_period;
        DataIn <= '0'; wait for clk_period;
        DataIn <= '1'; wait for clk_period;
        DataIn <= '0'; wait for clk_period;
        DataIn <= '1'; wait for clk_period;
        DataIn <= '0'; wait for clk_period;
        DataIn <= '1'; wait for clk_period;
        DataIn <= '0'; wait for clk_period;
        Start <= '0';
        wait for clk_period * 10;
		wait;
			 
    end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_serial_to_parallel of serial_to_parallel_tb is
	for TB_ARCHITECTURE
		for UUT : serial_to_parallel
			use entity work.serial_to_parallel(serial_to_parallel);
		end for;
	end for;
end TESTBENCH_FOR_serial_to_parallel;

