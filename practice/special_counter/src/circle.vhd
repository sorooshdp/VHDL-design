library ieee;
use ieee.std_logic_1164.all;

entity circle is
	port (clk, resetn: in std_logic;
	a, b: in std logic
	x,w,z: out std logic
	);
end circle;


architecture circle of circle is
	type state is (S1, S2, S3);
	signal y: state;
begin
	Transitions: process (resetn, clk, a, b)
	begin
		if resetn = '0' then y <= S1;
		elsif (clk'event and clk = '1')
			case y is 	
				when S1 => 
				
					if a = '1' then
						if b = '1' then y <= S3; else y <= S1 ; end if; 
					else 
						y <= S2 
					end if;
				
				when S2 => 
				
					if b = '1' then y <= S3 ; else Y <= S2 ; end if;
					
				when S3 => 
				
					if a = b then y <= S3 ; else y <= S1; end if;
			end case;
		end if;
	end process; 
	
	Outputs: process (y, a, b)
	begin
		x <= '0'; w <= '0'; z <= '0';
		
		case y is
			when S1 => if a = '1' then x<= '1' ; end if;
			when S2 => w <= '1' ;
			when S3 => if a = b then z <= '1' ; end if;
		end case;
	end process;

end circle;
