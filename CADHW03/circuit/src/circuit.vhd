library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity circuit is  
	port(
	clk : in std_logic;
	reset : in std_logic;
	x, y, z : out std_logic_vector(2 downto 0)
	);
end circuit;

architecture circuit of circuit is	
signal a, b, c : std_logic;	
signal r1, r2, r3, addr : std_logic_vector(2 downto 0);
begin
	process(clk, reset)
	begin 		
		if (reset = '1') then 	
			a <= '0'; b <= '1'; c <= '0';  
			r1 <= "000"; r2 <= "000"; r3 <= "000"; 
		elsif (rising_edge(clk)) then 
			b <= a; c <= b; a <= not c;
			if ( a = '1' and b = '0' ) then 
				r1 <= a & b & c;
			end if;
			if ( a = '0' and b = '1' ) then 
				r2 <= a & b & c;
			end if;	  

			if ( b = '0' and c = '1' ) then 
				  r3 <= std_logic_vector( unsigned(r1) + unsigned(r2) );
			end if;
		end if;
	end process;  
	
	x <= r1;
	z <= r2;
	y <= r3;
end circuit;
