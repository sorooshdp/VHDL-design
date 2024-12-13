library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity serial_to_parallel is
	    Port (
        Reset    : in  std_logic;
        Clk      : in  std_logic;
        DataIn   : in  std_logic;
        Start    : in  std_logic;
        Pattern  : in  std_logic_vector(7 downto 0);
        DataOut  : out std_logic_vector(7 downto 0);
        Valid    : out std_logic;
        Found    : out std_logic
    );
end serial_to_parallel;


architecture serial_to_parallel of serial_to_parallel is  
    type state_type is (IDLE, COLLECT, DONE);
    signal current_state, next_state : state_type;

    signal shift_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal bit_count : unsigned(2 downto 0) := (others => '0');  
    signal valid_reg : std_logic := '0';
    signal found_reg : std_logic := '0';
begin

    DataOut <= shift_reg;
    Valid   <= valid_reg;
    Found   <= found_reg;

    process(Clk, Reset)
    begin
        if Reset = '1' then
            current_state <= IDLE;
            bit_count     <= (others => '0');
            shift_reg     <= (others => '0');
            valid_reg     <= '0';
            found_reg     <= '0';
        elsif rising_edge(Clk) then
            current_state <= next_state;

            case current_state is
                when IDLE =>
                    valid_reg <= '0';
                    if Start = '1' then
                        found_reg <= '0';  
                        shift_reg <= (others => '0');
                        bit_count <= (others => '0');
                    end if;

                when COLLECT =>
                    if bit_count < 7 then
                        shift_reg <= shift_reg(6 downto 0) & DataIn;
                        bit_count <= bit_count + 1;
                    else
                        shift_reg <= shift_reg(6 downto 0) & DataIn;
                    end if;

                when DONE =>
                    valid_reg <= '1';
                    if shift_reg = Pattern then
                        found_reg <= '1';
                    end if;
            end case;
        end if;
    end process;

    process(current_state, Start, bit_count)
    begin
        next_state <= current_state;
        case current_state is
            when IDLE =>
                if Start = '1' then
                    next_state <= COLLECT;
                end if;

            when COLLECT =>
                if bit_count = 7 then
                    next_state <= DONE;
                else
                    next_state <= COLLECT;
                end if;

            when DONE =>
                next_state <= IDLE;

        end case;
    end process;

end serial_to_parallel;
