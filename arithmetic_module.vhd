-- VHDL code for a 16-bit arithmetic module
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY arithmetic_module IS
    PORT (
        A : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        B : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        fn : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        Cin : IN STD_LOGIC;
        R : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        Cout : OUT STD_LOGIC;
        F_O : OUT STD_LOGIC -- Overflow flag for 2's complement subtraction
    );
END ENTITY arithmetic_module;

ARCHITECTURE Behavioral OF arithmetic_module IS
BEGIN
    PROCESS (A, B, fn, Cin)
        VARIABLE A_ext, B_ext, Cin_ext : signed(16 DOWNTO 0);
        VARIABLE Result_s : signed(16 DOWNTO 0);
    BEGIN
        A_ext := ('0' & signed(A));
        B_ext := ('0' & signed(B));
        Cin_ext := (OTHERS => '0');
        Cin_ext(0) := '0'; -- Default Cin_ext to zero

        CASE fn IS
            WHEN "00" => -- ADD: R = A + B
                Result_s := A_ext + B_ext;
            WHEN "01" => -- ADDC: R = A + B + Cin
                Cin_ext(0) := Cin;
                Result_s := A_ext + B_ext + Cin_ext;
            WHEN "10" => -- SUB: R = A - B
                Result_s := A_ext - B_ext;
            WHEN "11" => -- SUBB: R = A - B - Cin
                Cin_ext(0) := Cin;
                Result_s := A_ext - B_ext - Cin_ext;
            WHEN OTHERS =>
                Result_s := (OTHERS => '0');
        END CASE;

        R <= STD_LOGIC_VECTOR(Result_s(15 DOWNTO 0));
        Cout <= Result_s(16); -- Output carry

        -- Overflow detection for subtraction
        IF (fn = "10" OR fn = "11") THEN
            IF (A_ext(15) /= B_ext(15)) AND (A_ext(15) /= Result_s(15)) THEN
                F_O <= '1';
            ELSE
                F_O <= '0';
            END IF;
        ELSE
            F_O <= '0';
        END IF;
    END PROCESS;
END ARCHITECTURE Behavioral;