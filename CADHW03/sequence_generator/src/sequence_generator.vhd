 library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity sequence_generator is	
	    Port (
        clk   : in  STD_LOGIC;
        reset : in  STD_LOGIC;   
        y     : out STD_LOGIC_VECTOR(3 downto 0)  
    );
end sequence_generator;

architecture sequence_generator of sequence_generator is  
    type state_type is (S0, S3, S7a, S7b, S11a, S11b, S15);
    signal current_state, next_state : state_type;
begin

	
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= S0;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    process(current_state)
    begin
        case current_state is
            when S0 =>
                next_state <= S3;
            when S3 =>
                next_state <= S7a;
            when S7a =>
                next_state <= S7b;
            when S7b =>
                next_state <= S11a;
            when S11a =>
                next_state <= S11b;
            when S11b =>
                next_state <= S15;
            when S15 =>
                next_state <= S0;
        end case;
    end process;
	
	--medvedev machine
    process(current_state)
    begin
        case current_state is
            when S0   => y <= "0000";
            when S3   => y <= "0011"; 
            when S7a  => y <= "0111"; 
            when S7b  => y <= "0111"; 
            when S11a => y <= "1011"; 
            when S11b => y <= "1011";
            when S15  => y <= "1111"; 
        end case;
    end process;

end sequence_generator;
