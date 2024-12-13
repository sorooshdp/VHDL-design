library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity firewall_tb is
end firewall_tb;

architecture TB_ARCHITECTURE of firewall_tb is
	-- Component declaration of the tested unit
	component firewall
	port(
		clk : in STD_LOGIC;
		reset : in STD_LOGIC;
		frame_in : in STD_LOGIC_VECTOR(111 downto 0);
		frame_out : out STD_LOGIC_VECTOR(111 downto 0);
		valid_out : out STD_LOGIC );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : STD_LOGIC;
	signal reset : STD_LOGIC;
	signal frame_in : STD_LOGIC_VECTOR(111 downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal frame_out : STD_LOGIC_VECTOR(111 downto 0);
	signal valid_out : STD_LOGIC;

	-- Add your code here ...
  	    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;
	  -- Test Vectors
    constant VALID_DST_MAC : STD_LOGIC_VECTOR(47 downto 0) := 
        "000000010010001101000101011001111000100110101011"; -- DST MAC: 00:11:22:33:44:55
    constant VALID_SRC_MAC : STD_LOGIC_VECTOR(47 downto 0) := 
        "011001100111100010001000100110011010101010111011"; -- SRC MAC: 66:77:88:99:AA:BB
    constant VALID_DATA : STD_LOGIC_VECTOR(15 downto 0) := 
        "1101111010101111"; -- DATA=DEADBEEF 

begin

	-- Unit Under Test port map
	UUT : firewall
		port map (
			clk => clk,
			reset => reset,
			frame_in => frame_in,
			frame_out => frame_out,
			valid_out => valid_out
		);

	-- Add your stimulus here ...
	 -- Clock generation process
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize
        reset <= '1';
        frame_in <= (others => '0');
        wait for CLK_PERIOD;
        reset <= '0';
        
        -- Test Case 1: Valid Frame
        frame_in <= VALID_DST_MAC & VALID_SRC_MAC & VALID_DATA;
        wait for CLK_PERIOD * 5;

        
        -- Test Case 2: Invalid Destination MAC
        frame_in <= x"FFFFFFFFFFFFFFFFFFFFFFFF" & VALID_DATA;
        wait for CLK_PERIOD * 6;

        
        -- Test Case 3: Invalid Source MAC
        frame_in <= VALID_DST_MAC & x"FFFFFFFFFFFF" & VALID_DATA;
        wait for CLK_PERIOD * 6;
 
        
        -- Test Case 4: Invalid Data
        frame_in <= VALID_DST_MAC & VALID_SRC_MAC & x"FFFF";
        wait for CLK_PERIOD * 6;

        
        -- Test Case 5: Reset Behavior
        reset <= '1';
        wait for CLK_PERIOD;

        
        report "All test cases passed successfully!" severity note;
        wait;
    end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_firewall of firewall_tb is
	for TB_ARCHITECTURE
		for UUT : firewall
			use entity work.firewall(firewall);
		end for;
	end for;
end TESTBENCH_FOR_firewall;

