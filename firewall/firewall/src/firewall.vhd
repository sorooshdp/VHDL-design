library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity firewall is 
  Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        frame_in    : in  STD_LOGIC_VECTOR(111 downto 0);
        frame_out   : out STD_LOGIC_VECTOR(111 downto 0);
        valid_out   : out STD_LOGIC
    );
end firewall;

architecture firewall of firewall is
    type state_type is (IDLE, CHECK_DST_MAC, CHECK_SRC_MAC, CHECK_DATA, VALID, INVALID);
    signal current_state, next_state : state_type;

    constant VALID_DST_MAC : STD_LOGIC_VECTOR(47 downto 0) := 
        "000000010010001101000101011001111000100110101011"; -- DST MAC: 00:11:22:33:44:55
    constant VALID_SRC_MAC : STD_LOGIC_VECTOR(47 downto 0) := 
        "011001100111100010001000100110011010101010111011"; -- SRC MAC: 66:77:88:99:AA:BB
    constant VALID_DATA    : STD_LOGIC_VECTOR(15 downto 0) := 
        "1101111010101111"; -- DATA=DEADBEEF

begin
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= IDLE;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;


    process(current_state, frame_in)
    begin
        next_state <= IDLE; 
        case current_state is
            when IDLE =>
                if frame_in(111 downto 64) = VALID_DST_MAC then
                    next_state <= CHECK_DST_MAC;
                else
                    next_state <= INVALID;
                end if;

            when CHECK_DST_MAC =>
                if frame_in(63 downto 16) = VALID_SRC_MAC then
                    next_state <= CHECK_SRC_MAC;
                else
                    next_state <= INVALID;
                end if;

            when CHECK_SRC_MAC =>
                if frame_in(15 downto 0) = VALID_DATA then
                    next_state <= CHECK_DATA;
                else
                    next_state <= INVALID;
                end if;

            when CHECK_DATA =>
                next_state <= VALID;

            when VALID =>
                next_state <= IDLE;

            when INVALID =>
                next_state <= IDLE;

            when others =>
                next_state <= IDLE;
        end case;
    end process;


    valid_out <= '1' when current_state = VALID else '0';
    frame_out <= frame_in when current_state = VALID else (others => '0');

end firewall;
