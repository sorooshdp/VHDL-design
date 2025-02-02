LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY special_counter IS
	PORT (
		reset, clk : IN STD_LOGIC;
		count : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END special_counter;

ARCHITECTURE special_counter OF special_counter IS
	TYPE state_type IS (S0, S1, S8, S5, SS5, S3);
	SIGNAL state, next_state : state_type;
BEGIN
	PROCESS (clk, reset)
	BEGIN
		IF reset = '0' THEN
			count <= (OTHERS => '0');
		ELSIF clk'event AND clk = '1' THEN
			state <= next_state;
		END IF;
	END PROCESS;

	PROCESS (state)
	BEGIN
		CASE state IS
			WHEN S0 => next_state <= S1;
			WHEN S1 => next_state <= S8;
			WHEN S8 => next_state <= S5;
			WHEN S5 => next_state <= SS5;
			WHEN SS5 => next_state <= S3;
			WHEN S3 => next_state <= S0;
			WHEN OTHERS => next_state <= S0;
		END CASE;
	END PROCESS;
END special_counter;