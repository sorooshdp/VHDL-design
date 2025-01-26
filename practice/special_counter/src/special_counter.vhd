library IEEE;
use IEEE.std_logic_1164.ALL;


entity special_counter is	
	Port(
		reset, clk: in std_logic;
		count: out std_logic_vector(3 downto 0)
	);
end special_counter;


architecture special_counter of special_counter is 
	type state_type is (S0, S1, S8, S5, SS5, S3);
	signal state, next_state : state_type;
begin									  
	process(clk, reset) 
	begin 
		if reset = '0' then
			count <= (others => '0');
		elsif clk'event and clk = '1' then 
			state <= next_state;
		end if;
	end process;
	
	process(state) 
	begin
		case state is
			when S0 => next_state <= S1;  
			when S1 => next_state <= S8;
			when S8 => next_state <= S5;
			when S5 => next_state <= SS5;
			when SS5 => next_state <= S3;
			when S3 => next_state <= S0; 
			when others => next_state <= S0;  
		end case;
	end process;
	
	
	 

end special_counter;
