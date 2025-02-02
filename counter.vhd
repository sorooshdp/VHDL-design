LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY BCD_Counter IS
    PORT (
        clk : IN STD_LOGIC; -- Clock input
        reset : IN STD_LOGIC; -- Asynchronous reset
        en : IN STD_LOGIC; -- Enable signal
        Q : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) -- 4-bit BCD output
    );
END BCD_Counter;

ARCHITECTURE Behavioral OF BCD_Counter IS
    SIGNAL count : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000"; -- Internal 4-bit counter
BEGIN
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            count <= "0000"; -- Reset counter to 0
        ELSIF rising_edge(clk) THEN
            IF en = '1' THEN
                IF count = "1001" THEN
                    count <= "0000"; -- Reset to 0 after reaching 9
                ELSE
                    count <= count + 1; -- Increment counter
                END IF;
            END IF;
        END IF;
    END PROCESS;

    Q <= count; -- Assign the internal counter to output
END Behavioral;