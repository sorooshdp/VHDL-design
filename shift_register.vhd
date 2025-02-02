LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY shift_register IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        command : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        dataIn : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
        dataOut : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
    );
END shift_register;

ARCHITECTURE shift_register OF shift_register IS
    SIGNAL reg : STD_LOGIC_VECTOR(63 DOWNTO 0);
BEGIN
    PROCESS (clk, reset)
    BEGIN

        IF reset = '1' THEN
            reg <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            CASE command IS
                WHEN "001" => -- Store dataIn into the register
                    reg <= dataIn;
                WHEN "010" => -- Shift left by 1 bit
                    reg <= reg(62 DOWNTO 0) & '0';
                WHEN "011" => -- Shift right by 1 bit
                    reg <= '0' & reg(63 DOWNTO 1);
                WHEN "101" => -- Rotate left by 1 bit
                    reg <= reg(62 DOWNTO 0) & reg(63);
                WHEN "110" => -- Rotate right by 1 bit
                    reg <= reg(0) & reg(63 DOWNTO 1);
                WHEN OTHERS => -- Hold the current value
                    reg <= reg;
            END CASE;
        END IF;
    END PROCESS;

    dataOut <= reg;
END shift_register;