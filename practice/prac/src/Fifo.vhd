library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Fifo is	  		 
    Port ( 
        CLK : in STD_LOGIC;
        Reset : in STD_LOGIC;
        WE : in STD_LOGIC;
        RE : in STD_LOGIC;
        Din : in STD_LOGIC_VECTOR(7 downto 0);
        Dout : out STD_LOGIC_VECTOR(7 downto 0)
    );
end Fifo;


architecture Fifo of Fifo is 
    type memory_type is array(0 to 63) of std_logic_vector(7 downto 0);
    signal memory : memory_type;
    signal Ar, Aw : unsigned(5 downto 0);
begin									 
	process(CLK, Reset)
	begin
		if Reset = '0' then
			Ar <= (others => '0');
            Aw <= (others => '0');
            Dout <= (others => '0');
            memory <= (others => (others => '0'));
		elsif rising_edge(CLK) then 
			if WE = '1' then 
				memory(to_integer(Aw)) <= Din;
				if Aw = 63 then 
					Aw <= (others => '0');
				else 
					Aw <= Aw + 1;
				end if;
			
			end if;
			
			if RE = '1' then 
				Dout <= memory(to_integer(Ar));
				
				if Ar = 63 then 
					Ar <= (others => '0');
				else 
					Ar <= Ar + 1;
				end if;
			end if;
			
		end if;
	end process;
end Fifo;
