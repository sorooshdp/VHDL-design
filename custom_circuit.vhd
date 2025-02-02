LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY circuit_with_xor_and IS
    PORT (
        en : IN STD_LOGIC; -- Enable input
        sel : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- 3-bit select input
        full_decoder_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- decoder resault
        out_final : OUT STD_LOGIC -- Final output
    );
END circuit_with_xor_and;

ARCHITECTURE Behavioral OF circuit_with_xor_and IS

    COMPONENT decoder3to8
        PORT (
            en : IN STD_LOGIC;
            sel : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            y : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL decoder_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL xor1_out, xor2_out : STD_LOGIC;

BEGIN
    -- Instantiate the decoder3to8
    UUT_decoder : decoder3to8
    PORT MAP(
        en => en,
        sel => sel,
        y => decoder_out
    );

    -- decoder resault
    full_decoder_out <= decoder_out;

    -- XOR gates for required outputs
    xor1_out <= decoder_out(0) XNOR decoder_out(3); -- XNOR between y(0) and y(3)
    xor2_out <= decoder_out(4) XNOR decoder_out(7); -- XNOR between y(4) and y(7)

    -- AND gate for final output
    out_final <= xor1_out AND xor2_out;

END Behavioral;