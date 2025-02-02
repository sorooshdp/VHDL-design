LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY sequence_generator IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        y : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END sequence_generator;

ARCHITECTURE sequence_generator OF sequence_generator IS
    TYPE state_type IS (S0, S3, S7a, S7b, S11a, S11b, S15);
    SIGNAL current_state, next_state : state_type;
BEGIN
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            current_state <= S0;
        ELSIF rising_edge(clk) THEN
            current_state <= next_state;
        END IF;
    END PROCESS;

    PROCESS (current_state)
    BEGIN
        CASE current_state IS
            WHEN S0 =>
                next_state <= S3;
            WHEN S3 =>
                next_state <= S7a;
            WHEN S7a =>
                next_state <= S7b;
            WHEN S7b =>
                next_state <= S11a;
            WHEN S11a =>
                next_state <= S11b;
            WHEN S11b =>
                next_state <= S15;
            WHEN S15 =>
                next_state <= S0;
        END CASE;
    END PROCESS;

    --medvedev machine
    PROCESS (current_state)
    BEGIN
        CASE current_state IS
            WHEN S0 => y <= "0000";
            WHEN S3 => y <= "0011";
            WHEN S7a => y <= "0111";
            WHEN S7b => y <= "0111";
            WHEN S11a => y <= "1011";
            WHEN S11b => y <= "1011";
            WHEN S15 => y <= "1111";
        END CASE;
    END PROCESS;

END sequence_generator;