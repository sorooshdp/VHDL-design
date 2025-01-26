library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity DualPortRam is
    generic (
        DATA_WIDTH : integer := 8; -- Width of data
        ADDR_WIDTH : integer := 8  -- Width of address
    );
    port (
        Clk    : in  STD_LOGIC;                       -- Clock signal
        WE1    : in  STD_LOGIC;                       -- Write enable for port 1
        RE1    : in  STD_LOGIC;                       -- Read enable for port 1
        Addr1  : in  STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0); -- Address for port 1
        Data1  : inout STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0); -- Data for port 1

        WE2    : in  STD_LOGIC;                       -- Write enable for port 2
        RE2    : in  STD_LOGIC;                       -- Read enable for port 2
        Addr2  : in  STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0); -- Address for port 2
        Data2  : inout STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) -- Data for port 2
    );
end DualPortRam;


architecture DualPortRam of DualPortRam is
	type memory_type is array (0 to 2**ADDR_WIDTH-1) of STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal RAM : memory_type := (others => (others => '0')); -- Initialize to zero
begin

	process(Clk)
	begin
		if rising_edge(Clk) then 
			if WE1 = '1' then 
				RAM(to_integer(unsigned(Addr1))) <= Data1;
			end if;
		end if;
	end process;
	
	
	Data1 <= RAM(to_integer(unsigned(Addr1))) when RE1 = '1' else (others => 'Z'); 	
	
	process(Clk)
	begin
		if rising_edge(Clk) then 
			if WE1 = '1' then 
				RAM(to_integer(unsigned(Addr2))) <= Data2;
			end if;
		end if;
	end process;
	
	
	Data2 <= RAM(to_integer(unsigned(Addr2))) when RE2 = '1' else (others => 'Z'); 

end DualPortRam;
