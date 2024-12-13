library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity delay_examples is
    Port (
        qin : in  std_logic;
        Y1, Y2, Y3, Y4, Y5 : out std_logic
    );
end delay_examples;

architecture Behavioral of delay_examples is
begin
    Y1 <= qin;
    Y2 <= qin after 1 ns;
    Y3 <= inertial qin after 1 ns;
    Y4 <= transport qin after 1 ns;
    Y5 <= reject 500 ps inertial qin after 1 ns;
end Behavioral;
