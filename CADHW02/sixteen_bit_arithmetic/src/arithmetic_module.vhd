-- VHDL code for a 16-bit arithmetic module
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity arithmetic_module is
    port (
        A       : in  std_logic_vector(15 downto 0);
        B       : in  std_logic_vector(15 downto 0);
        fn		: in  std_logic_vector(1 downto 0);
        Cin     : in  std_logic;
        R       : out std_logic_vector(15 downto 0);
        Cout    : out std_logic;
        F_O     : out std_logic  -- Overflow flag for 2's complement subtraction
    );
end entity arithmetic_module;

architecture Behavioral of arithmetic_module is
begin
    process(A, B, fn, Cin)
        variable A_ext, B_ext, Cin_ext: signed(16 downto 0);
        variable Result_s             : signed(16 downto 0);
    begin
        A_ext := ('0' & signed(A));
        B_ext := ('0' & signed(B));
        Cin_ext := (others => '0');
        Cin_ext(0) := '0';  -- Default Cin_ext to zero

        case fn is
            when "00" =>  -- ADD: R = A + B
                Result_s := A_ext + B_ext;
            when "01" =>  -- ADDC: R = A + B + Cin
                Cin_ext(0) := Cin;
                Result_s := A_ext + B_ext + Cin_ext;
            when "10" =>  -- SUB: R = A - B
                Result_s := A_ext - B_ext;
            when "11" =>  -- SUBB: R = A - B - Cin
                Cin_ext(0) := Cin;
                Result_s := A_ext - B_ext - Cin_ext;
            when others =>
                Result_s := (others => '0');
        end case;

        R    <= std_logic_vector(Result_s(15 downto 0));
        Cout <= Result_s(16);  -- Output carry

        -- Overflow detection for subtraction
        if (fn = "10" or fn = "11") then
            if (A_ext(15) /= B_ext(15)) and (A_ext(15) /= Result_s(15)) then
                F_O <= '1';
            else
                F_O <= '0';
            end if;
        else
            F_O <= '0';
        end if;
    end process;
end architecture Behavioral;