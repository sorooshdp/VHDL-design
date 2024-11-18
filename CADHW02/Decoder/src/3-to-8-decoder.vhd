library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity decoder3to8 is
    Port (
        en  : in  std_logic;
        sel : in  std_logic_vector(2 downto 0);
        y   : out std_logic_vector(7 downto 0)
    );
end decoder3to8;

architecture Behavioral of decoder3to8 is
begin
    process(en, sel)
    begin
        if en = '1' then
            y <= (others => '0');  -- Initialize outputs to '0'
            y(to_integer(unsigned(sel))) <= '1';
        else
            y <= (others => '0');
        end if;
    end process;
end Behavioral;