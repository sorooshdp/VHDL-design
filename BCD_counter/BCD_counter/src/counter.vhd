library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BCD_Counter is
    Port (
        clk   : in  std_logic;  -- Clock input
        reset : in  std_logic;  -- Asynchronous reset
        en    : in  std_logic;  -- Enable signal
        Q     : out std_logic_vector(3 downto 0)  -- 4-bit BCD output
    );
end BCD_Counter;

architecture Behavioral of BCD_Counter is
    signal count : std_logic_vector(3 downto 0) := "0000";  -- Internal 4-bit counter
begin
    process(clk, reset)
    begin
        if reset = '1' then
            count <= "0000";  -- Reset counter to 0
        elsif rising_edge(clk) then
            if en = '1' then
                if count = "1001" then
                    count <= "0000";  -- Reset to 0 after reaching 9
                else
                    count <= count + 1;  -- Increment counter
                end if;
            end if;
        end if;
    end process;

    Q <= count;  -- Assign the internal counter to output
end Behavioral;

