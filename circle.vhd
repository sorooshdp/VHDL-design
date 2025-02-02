LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY circle IS
	PORT (
		clk, resetn : IN STD_LOGIC;
		a, b : IN std logic
		x, w, z : OUT std logic
	);
END circle;

ARCHITECTURE circle OF circle IS
	TYPE state IS (S1, S2, S3);
	SIGNAL y : state;
BEGIN
	Transitions : PROCESS (resetn, clk, a, b)
	BEGIN
		IF resetn = '0' THEN
			y <= S1;
		ELSIF (clk'event AND clk = '1')
			CASE y IS
				WHEN S1 =>

					IF a = '1' THEN
						IF b = '1' THEN
							y <= S3;
						ELSE
							y <= S1;
						END IF;
					ELSE
						y <= S2
						END IF;

					WHEN S2 =>

						IF b = '1' THEN
							y <= S3;
						ELSE
							Y <= S2;
						END IF;

					WHEN S3 =>

						IF a = b THEN
							y <= S3;
						ELSE
							y <= S1;
						END IF;
					END CASE;
			END IF;
		END PROCESS;

		Outputs : PROCESS (y, a, b)
		BEGIN
			x <= '0';
			w <= '0';
			z <= '0';

			CASE y IS
				WHEN S1 => IF a = '1' THEN
					x <= '1';
			END IF;
			WHEN S2 => w <= '1';
			WHEN S3 => IF a = b THEN
			z <= '1';
		END IF;
	END CASE;
END PROCESS;
