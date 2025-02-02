LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY serial_to_parallel IS
    PORT (
        Reset : IN STD_LOGIC;
        Clk : IN STD_LOGIC;
        DataIn : IN STD_LOGIC;
        Start : IN STD_LOGIC;
        Pattern : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        DataOut : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        Valid : OUT STD_LOGIC;
        Found : OUT STD_LOGIC
    );
END serial_to_parallel;

ARCHITECTURE serial_to_parallel OF serial_to_parallel IS
    TYPE state_type IS (IDLE, COLLECT, DONE);
    SIGNAL current_state, next_state : state_type;
    SIGNAL shift_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL bit_count : unsigned(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL valid_reg : STD_LOGIC := '0';
    SIGNAL found_reg : STD_LOGIC := '0';
BEGIN

    DataOut <= shift_reg;
    Valid <= valid_reg;
    Found <= found_reg;

    PROCESS (Clk, Reset)
    BEGIN
        IF Reset = '1' THEN
            current_state <= IDLE;
            bit_count <= (OTHERS => '0');
            shift_reg <= (OTHERS => '0');
            valid_reg <= '0';
            found_reg <= '0';
        ELSIF rising_edge(Clk) THEN
            current_state <= next_state;

            CASE current_state IS
                WHEN IDLE =>
                    valid_reg <= '0';
                    IF Start = '1' THEN
                        found_reg <= '0';
                        shift_reg <= (OTHERS => '0');
                        bit_count <= (OTHERS => '0');
                    END IF;

                WHEN COLLECT =>
                    IF bit_count < 7 THEN
                        shift_reg <= shift_reg(6 DOWNTO 0) & DataIn;
                        bit_count <= bit_count + 1;
                    ELSE
                        shift_reg <= shift_reg(6 DOWNTO 0) & DataIn;
                    END IF;

                WHEN DONE =>
                    valid_reg <= '1';
                    IF shift_reg = Pattern THEN
                        found_reg <= '1';
                    END IF;
            END CASE;
        END IF;
    END PROCESS;

    PROCESS (current_state, Start, bit_count)
    BEGIN
        next_state <= current_state;
        CASE current_state IS
            WHEN IDLE =>
                IF Start = '1' THEN
                    next_state <= COLLECT;
                END IF;

            WHEN COLLECT =>
                IF bit_count = 7 THEN
                    next_state <= DONE;
                ELSE
                    next_state <= COLLECT;
                END IF;

            WHEN DONE =>
                next_state <= IDLE;

        END CASE;
    END PROCESS;

END serial_to_parallel;