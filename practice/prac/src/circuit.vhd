library IEEE;
use ieee.std_logic_1164.all;

entity circuit is 
	port(
		clk, reset, en, x : in std_logic;
		g : in std_logic_vector(3 downto 0);
		q : out std_logic_vector(3 downto 0)
	);
end circuit;



architecture circuit of circuit is 
	signal gout : std_logic_vector(3 downto 0);
	signal memout : std_logic_vector(3 downto 0);
	signal nextq : std_logic_vector(3 downto 0);
begin
	
	process(clk, reset)
	begin
		if reset = '1' then 
			nextq <= (others => '0'); 
		elsif clk'event and clk = '1' then 
			if en = '1' then 
				memout <= nextq;
			end if;	   
		end if;
	end process; 
	
	process(g, nextq(3)) 
	begin 
		for i in 0 to 3 loop 
			gout(i) <= nextq(3) and g(i);
		end loop;				 
	end process;			
	
	nextq(0) <= x xor gout(0);
	
	process(gout, memout, nextq) 
	begin 
		for i in 1 to 3 loop
			memout(i) <= nextq(i) xor gout(i);
		end loop;
	end process;

	q <= memout;
	

end circuit;
