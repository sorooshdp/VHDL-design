LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Queue IS
    GENERIC (
        DATA_WIDTH : INTEGER := 12; -- Width of data
        ADDR_WIDTH : INTEGER := 8 -- Width of address (depth = 2^ADDR_WIDTH)
    );
    PORT (
        Clk : IN STD_LOGIC; -- Clock signal
        Reset : IN STD_LOGIC; -- Reset signal
        PUSH : IN STD_LOGIC; -- Push operation signal
        POP : IN STD_LOGIC; -- Pop operation signal
        Data_In : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0); -- Input data
        FIFO_Full : OUT STD_LOGIC; -- FIFO full flag
        FIFO_Empty : OUT STD_LOGIC; -- FIFO empty flag
        Data_Out : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0) -- Output data
    );
END Queue;

ARCHITECTURE Queue OF Queue IS
    TYPE memory_type IS ARRAY(0 TO 2 ** ADDR_WIDTH - 1) OF STD_LOGIC_VECTOR(DATA_WIDTH DOWNTO 0);
    SIGNAL RAM : memory_type := (OTHERS => (OTHERS => '0'));
    -- Address pointers
    SIGNAL Head : STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0) := (OTHERS => '0'); -- Head pointer
    SIGNAL Tail : STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0) := (OTHERS => '0'); -- Tail pointer
    -- Internal signals
    SIGNAL Full : STD_LOGIC := '0';
    SIGNAL Empty : STD_LOGIC := '1';
BEGIN
    -- Write data to the FIFO (push operation)
    PROCESS (Clk)
    BEGIN
        IF rising_edge(Clk) THEN
            IF Reset = '1' THEN
                Head <= (OTHERS => '0');
                Tail <= (OTHERS => '0');
                Full <= '0';
                Empty <= '1';
            ELSIF PUSH = '1' AND Full = '0' THEN
                RAM(to_integer(unsigned(Head))) <= Data_In; -- Write data
                Head <= Head + 1; -- Increment head pointer
                Empty <= '0';
                IF (Head + 1) = Tail THEN -- Check if FIFO becomes full
                    Full <= '1';
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- Read data from the FIFO (pop operation)
    PROCESS (Clk)
    BEGIN
        IF rising_edge(Clk) THEN
            IF Reset = '1' THEN
                Head <= (OTHERS => '0');
                Tail <= (OTHERS => '0');
                Full <= '0';
                Empty <= '1';
            ELSIF POP = '1' AND Empty = '0' THEN
                Data_Out <= RAM(to_integer(unsigned(Tail))); -- Read data
                Tail <= Tail + 1; -- Increment tail pointer
                Full <= '0';
                IF Tail + 1 = Head THEN -- Check if FIFO becomes empty
                    Empty <= '1';
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- Assign flags
    FIFO_Full <= Full;
    FIFO_Empty <= Empty

END Queue;