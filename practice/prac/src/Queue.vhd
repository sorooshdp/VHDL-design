library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Queue is			 
	generic (
        DATA_WIDTH : integer := 12;  -- Width of data
        ADDR_WIDTH : integer := 8    -- Width of address (depth = 2^ADDR_WIDTH)
    );
    port (
        Clk       : in  STD_LOGIC;                                -- Clock signal
        Reset     : in  STD_LOGIC;                                -- Reset signal
        PUSH      : in  STD_LOGIC;                                -- Push operation signal
        POP       : in  STD_LOGIC;                                -- Pop operation signal
        Data_In   : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);  -- Input data
        FIFO_Full : out STD_LOGIC;                                -- FIFO full flag
        FIFO_Empty: out STD_LOGIC;                                -- FIFO empty flag
        Data_Out  : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0)   -- Output data
    );
end Queue;



architecture Queue of Queue is	
	type memory_type is array(0 to 2**ADDR_WIDTH - 1) of std_logic_vector(DATA_WIDTH downto 0);
	signal RAM : memory_type := (others => (others => '0')); 
	
	    -- Address pointers
    signal Head : STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0) := (others => '0'); -- Head pointer
    signal Tail : STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0) := (others => '0'); -- Tail pointer
	
	    -- Internal signals
    signal Full : STD_LOGIC := '0';
    signal Empty : STD_LOGIC := '1';
begin
	    -- Write data to the FIFO (push operation)
    process(Clk)
    begin
        if rising_edge(Clk) then
            if Reset = '1' then
                Head <= (others => '0');
                Tail <= (others => '0');
                Full <= '0';
                Empty <= '1';
            elsif PUSH = '1' and Full = '0' then
                RAM(to_integer(unsigned(Head))) <= Data_In; -- Write data
                Head <= Head + 1; -- Increment head pointer
                Empty <= '0';
                if (Head + 1) = Tail then -- Check if FIFO becomes full
                    Full <= '1';
                end if;
            end if;
        end if;
    end process;
	
	    -- Read data from the FIFO (pop operation)
    process(Clk)
    begin
        if rising_edge(Clk) then
            if Reset = '1' then
                Head <= (others => '0');
                Tail <= (others => '0');
                Full <= '0';
                Empty <= '1';
            elsif POP = '1' and Empty = '0' then
                Data_Out <= RAM(to_integer(unsigned(Tail))); -- Read data
                Tail <= Tail + 1; -- Increment tail pointer
                Full <= '0';
                if Tail + 1 = Head then -- Check if FIFO becomes empty
                    Empty <= '1';
                end if;
            end if;
        end if;
    end process;

    -- Assign flags
    FIFO_Full <= Full;
    FIFO_Empty <= Empty

end Queue;


