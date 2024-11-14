library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity circuit_with_xor_and is
    Port (
        en   : in  std_logic;                      			-- Enable input
        sel  : in  std_logic_vector(2 downto 0);   			-- 3-bit select input
		full_decoder_out : out std_logic_vector(7 downto 0);  	-- decoder resault
        out_final : out std_logic                 			-- Final output
    );
end circuit_with_xor_and;

architecture Behavioral of circuit_with_xor_and is

    component decoder3to8
        Port (
            en   : in  std_logic;
            sel  : in  std_logic_vector(2 downto 0);
            y    : out std_logic_vector(7 downto 0)
        );
    end component;

    signal decoder_out : std_logic_vector(7 downto 0);
    signal xor1_out, xor2_out : std_logic; 
	
begin
    -- Instantiate the decoder3to8
    UUT_decoder: decoder3to8
        Port map (
            en   => en,
            sel  => sel,
            y    => decoder_out
        );
		
	-- decoder resault
	full_decoder_out <= decoder_out;

    -- XOR gates for required outputs
    xor1_out <= decoder_out(0) xnor decoder_out(3); -- XOR between y(0) and y(3)
    xor2_out <= decoder_out(4) xnor decoder_out(7); -- XOR between y(4) and y(7)

    -- AND gate for final output
    out_final <= xor1_out and xor2_out;

end Behavioral;

