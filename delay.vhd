LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY delay_examples IS
    PORT (
        qin : IN STD_LOGIC;
        Y1, Y2, Y3, Y4, Y5 : OUT STD_LOGIC
    );
END delay_examples;

ARCHITECTURE Behavioral OF delay_examples IS
BEGIN
    Y1 <= qin;
    Y2 <= qin AFTER 1 ns;
    Y3 <= INERTIAL qin AFTER 1 ns;
    Y4 <= TRANSPORT qin AFTER 1 ns;
    Y5 <= REJECT 500 ps INERTIAL qin AFTER 1 ns;
END Behavioral;