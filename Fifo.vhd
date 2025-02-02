LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Fifo IS
	PORT (
		CLK : IN STD_LOGIC;
		Reset : IN STD_LOGIC;
		WE : IN STD_LOGIC;
		RE : IN STD_LOGIC;
		Din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		Dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END Fifo;

ARCHITECTURE Fifo OF Fifo IS
	TYPE memory_type IS ARRAY(0 TO 63) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL memory : memory_type;
	SIGNAL Ar, Aw : unsigned(5 DOWNTO 0);
BEGIN
	PROCESS (CLK, Reset)
	BEGIN
		IF Reset = '0' THEN
			Ar <= (OTHERS => '0');
			Aw <= (OTHERS => '0');
			Dout <= (OTHERS => '0');
			memory <= (OTHERS => (OTHERS => '0'));
		ELSIF rising_edge(CLK) THEN
			IF WE = '1' THEN
				memory(to_integer(Aw)) <= Din;
				IF Aw = 63 THEN
					Aw <= (OTHERS => '0');
				ELSE
					Aw <= Aw + 1;
				END IF;

			END IF;

			IF RE = '1' THEN
				Dout <= memory(to_integer(Ar));

				IF Ar = 63 THEN
					Ar <= (OTHERS => '0');
				ELSE
					Ar <= Ar + 1;
				END IF;
			END IF;

		END IF;
	END PROCESS;
END Fifo;