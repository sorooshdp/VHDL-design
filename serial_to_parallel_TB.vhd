LIBRARY ieee;
USE ieee.NUMERIC_STD.ALL;
USE ieee.std_logic_1164.ALL;

ENTITY serial_to_parallel_tb IS
END serial_to_parallel_tb;

ARCHITECTURE TB_ARCHITECTURE OF serial_to_parallel_tb IS
    -- Component declaration of the tested unit
    COMPONENT serial_to_parallel
        PORT (
            Reset : IN STD_LOGIC;
            Clk : IN STD_LOGIC;
            DataIn : IN STD_LOGIC;
            Start : IN STD_LOGIC;
            Pattern : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            DataOut : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            Valid : OUT STD_LOGIC;
            Found : OUT STD_LOGIC);
    END COMPONENT;

    -- Stimulus signals - signals mapped to the input and inout ports of tested entity
    SIGNAL Reset : STD_LOGIC;
    SIGNAL Clk : STD_LOGIC := '0';
    SIGNAL DataIn : STD_LOGIC;
    SIGNAL Start : STD_LOGIC;
    SIGNAL Pattern : STD_LOGIC_VECTOR(7 DOWNTO 0);
    -- Observed signals - signals mapped to the output ports of tested entity
    SIGNAL DataOut : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL Valid : STD_LOGIC;
    SIGNAL Found : STD_LOGIC;

    -- Add your code here ...	   
    SIGNAL clk_period : TIME := 100ns;
BEGIN

    -- Unit Under Test port map
    UUT : serial_to_parallel
    PORT MAP(
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
    clk_process : PROCESS
    BEGIN
        WHILE true LOOP
            Clk <= '0';
            WAIT FOR clk_period / 2;
            Clk <= '1';
            WAIT FOR clk_period / 2;
        END LOOP;
    END PROCESS;

    -- Combined Stimulus Process
    stim_process : PROCESS
    BEGIN
        Pattern <= "10101010";
        Reset <= '1';
        WAIT FOR 200 ns;
        Reset <= '0';

        Start <= '1';
        WAIT FOR clk_period;
        DataIn <= '1';
        WAIT FOR clk_period;
        DataIn <= '0';
        WAIT FOR clk_period;
        DataIn <= '1';
        WAIT FOR clk_period;
        DataIn <= '0';
        WAIT FOR clk_period;
        DataIn <= '1';
        WAIT FOR clk_period;
        DataIn <= '0';
        WAIT FOR clk_period;
        DataIn <= '1';
        WAIT FOR clk_period;
        DataIn <= '0';
        WAIT FOR clk_period;
        Start <= '0';
        WAIT FOR clk_period * 10;

        Pattern <= "11110000";
        Reset <= '1';
        WAIT FOR 200 ns;
        Reset <= '0';

        Start <= '1';
        WAIT FOR clk_period;
        DataIn <= '1';
        WAIT FOR clk_period;
        DataIn <= '0';
        WAIT FOR clk_period;
        DataIn <= '1';
        WAIT FOR clk_period;
        DataIn <= '0';
        WAIT FOR clk_period;
        DataIn <= '1';
        WAIT FOR clk_period;
        DataIn <= '0';
        WAIT FOR clk_period;
        DataIn <= '1';
        WAIT FOR clk_period;
        DataIn <= '0';
        WAIT FOR clk_period;
        Start <= '0';
        WAIT FOR clk_period * 10;
        WAIT;

    END PROCESS;

END TB_ARCHITECTURE;

CONFIGURATION TESTBENCH_FOR_serial_to_parallel OF serial_to_parallel_tb IS
    FOR TB_ARCHITECTURE
        FOR UUT : serial_to_parallel
            USE ENTITY work.serial_to_parallel(serial_to_parallel);
        END FOR;
    END FOR;
END TESTBENCH_FOR_serial_to_parallel;