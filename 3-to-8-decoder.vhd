LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY decoder3to8 IS
    PORT (
        en : IN STD_LOGIC;
        sel : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        y : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END decoder3to8;

ARCHITECTURE Behavioral OF decoder3to8 IS
BEGIN
    PROCESS (en, sel)
    BEGIN
        IF en = '1' THEN
            y <= (OTHERS => '0'); -- Initialize outputs to '0'
            y(to_integer(unsigned(sel))) <= '1';
        ELSE
            y <= (OTHERS => '0');
        END IF;
    END PROCESS;
END Behavioral;