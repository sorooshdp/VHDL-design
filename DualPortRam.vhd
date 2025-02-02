LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY DualPortRam IS
	GENERIC (
		DATA_WIDTH : INTEGER := 8; -- Width of data
		ADDR_WIDTH : INTEGER := 8 -- Width of address
	);
	PORT (
		Clk : IN STD_LOGIC; -- Clock signal
		WE1 : IN STD_LOGIC; -- Write enable for port 1
		RE1 : IN STD_LOGIC; -- Read enable for port 1
		Addr1 : IN STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0); -- Address for port 1
		Data1 : INOUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0); -- Data for port 1

		WE2 : IN STD_LOGIC; -- Write enable for port 2
		RE2 : IN STD_LOGIC; -- Read enable for port 2
		Addr2 : IN STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0); -- Address for port 2
		Data2 : INOUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0) -- Data for port 2
	);
END DualPortRam;

ARCHITECTURE DualPortRam OF DualPortRam IS
	TYPE memory_type IS ARRAY (0 TO 2 ** ADDR_WIDTH - 1) OF STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
	SIGNAL RAM : memory_type := (OTHERS => (OTHERS => '0')); -- Initialize to zero
BEGIN

	PROCESS (Clk)
	BEGIN
		IF rising_edge(Clk) THEN
			IF WE1 = '1' THEN
				RAM(to_integer(unsigned(Addr1))) <= Data1;
			END IF;
		END IF;
	END PROCESS;
	Data1 <= RAM(to_integer(unsigned(Addr1))) WHEN RE1 = '1' ELSE
		(OTHERS => 'Z');

	PROCESS (Clk)
	BEGIN
		IF rising_edge(Clk) THEN
			IF WE1 = '1' THEN
				RAM(to_integer(unsigned(Addr2))) <= Data2;
			END IF;
		END IF;
	END PROCESS;
	Data2 <= RAM(to_integer(unsigned(Addr2))) WHEN RE2 = '1' ELSE
		(OTHERS => 'Z');

END DualPortRam;