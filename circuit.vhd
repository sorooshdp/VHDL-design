LIBRARY IEEE;
USE ieee.std_logic_1164.ALL;

ENTITY circuit IS
	PORT (
		clk, reset, en, x : IN STD_LOGIC;
		g : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		q : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END circuit;

ARCHITECTURE circuit OF circuit IS
	SIGNAL gout : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL memout : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL nextq : STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN

	PROCESS (clk, reset)
	BEGIN
		IF reset = '1' THEN
			nextq <= (OTHERS => '0');
		ELSIF clk'event AND clk = '1' THEN
			IF en = '1' THEN
				memout <= nextq;
			END IF;
		END IF;
	END PROCESS;

	PROCESS (g, nextq(3))
	BEGIN
		FOR i IN 0 TO 3 LOOP
			gout(i) <= nextq(3) AND g(i);
		END LOOP;
	END PROCESS;

	nextq(0) <= x XOR gout(0);

	PROCESS (gout, memout, nextq)
	BEGIN
		FOR i IN 1 TO 3 LOOP
			memout(i) <= nextq(i) XOR gout(i);
		END LOOP;
	END PROCESS;

	q <= memout;
END circuit;