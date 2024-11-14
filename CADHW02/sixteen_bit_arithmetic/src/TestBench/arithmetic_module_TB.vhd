library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity arithmetic_module_tb is
end arithmetic_module_tb;

architecture TB_ARCHITECTURE of arithmetic_module_tb is
	-- Component declaration of the tested unit
	component arithmetic_module
	port(
		A : in STD_LOGIC_VECTOR(15 downto 0);
		B : in STD_LOGIC_VECTOR(15 downto 0);
		fn : in STD_LOGIC_VECTOR(1 downto 0);
		Cin : in STD_LOGIC;
		R : out STD_LOGIC_VECTOR(15 downto 0);
		Cout : out STD_LOGIC;
		F_O : out STD_LOGIC );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal A : STD_LOGIC_VECTOR(15 downto 0);
	signal B : STD_LOGIC_VECTOR(15 downto 0);
	signal fn : STD_LOGIC_VECTOR(1 downto 0);
	signal Cin : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal R : STD_LOGIC_VECTOR(15 downto 0);
	signal Cout : STD_LOGIC;
	signal F_O : STD_LOGIC;

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : arithmetic_module
		port map (
			A => A,
			B => B,
			fn => fn,
			Cin => Cin,
			R => R,
			Cout => Cout,
			F_O => F_O
		);

	-- Add your stimulus here ...	   
	stim_proc: process
    begin
        -- Test Case 1: ADD (Function Code 00)
        -- A = 1, B = 2, Cin = 0
        A        <= std_logic_vector(to_signed(1, 16));
        B        <= std_logic_vector(to_signed(2, 16));
        fn		 <= "00";
        Cin      <= '0';
        wait for 10 ns;

        -- Test Case 2: ADDC (Function Code 01)
        -- A = 1, B = 2, Cin = 1
        A        <= std_logic_vector(to_signed(1, 16));
        B        <= std_logic_vector(to_signed(2, 16));
        fn <= "01";
        Cin      <= '1';
        wait for 10 ns;

        -- Test Case 3: SUB (Function Code 10)
        -- A = 3, B = 1, Cin = 0
        A        <= std_logic_vector(to_signed(3, 16));
        B        <= std_logic_vector(to_signed(1, 16));
        fn <= "10";
        Cin      <= '0';
        wait for 10 ns;

        -- Test Case 4: SUB (Function Code 10)
        -- A = 5, B = 7, Cin = 0
        A        <= std_logic_vector(to_signed(5, 16));
        B        <= std_logic_vector(to_signed(7, 16));
        fn <= "10";
        Cin      <= '0';
        wait for 10 ns;

        -- Test Case 5: SUB (Function Code 10)
        -- A = 32767, B = -1, Cin = 0
        A        <= std_logic_vector(to_signed(32767, 16));
        B        <= std_logic_vector(to_signed(-1, 16));
        fn <= "10";
        Cin      <= '0';
        wait for 10 ns;

        -- Test Case 6: SUB (Function Code 10)
        -- A = -32768, B = 1, Cin = 0
        A        <= std_logic_vector(to_signed(-32768, 16));
        B        <= std_logic_vector(to_signed(1, 16));
        fn <= "10";
        Cin      <= '0';
        wait for 10 ns;

        -- Test Case 7: SUBB (Function Code 11)
        -- A = 0, B = 1, Cin = 1
        A        <= std_logic_vector(to_signed(0, 16));
        B        <= std_logic_vector(to_signed(1, 16));
        fn <= "11";
        Cin      <= '1';
        wait for 10 ns;

        wait;
    end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_arithmetic_module of arithmetic_module_tb is
	for TB_ARCHITECTURE
		for UUT : arithmetic_module
			use entity work.arithmetic_module(behavioral);
		end for;
	end for;
end TESTBENCH_FOR_arithmetic_module;

