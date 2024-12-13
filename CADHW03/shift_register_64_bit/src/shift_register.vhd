library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity shift_register is   
    Port (
        clk     : in  std_logic;
        reset   : in  std_logic;
        command : in  std_logic_vector(2 downto 0);
        dataIn  : in  std_logic_vector(63 downto 0);
        dataOut : out std_logic_vector(63 downto 0)
    );
end shift_register;



architecture shift_register of shift_register is  
	signal reg: std_logic_vector(63 downto 0);
begin
	process( clk,reset) 
	begin  
		
	if reset = '1' then
		reg <= (others => '0');	
	elsif rising_edge(clk) then 
		     case command is
                when "001" => 	 -- Store dataIn into the register
                   		reg <= dataIn;
                when "010" =>   -- Shift left by 1 bit
                    	reg <= reg(62 downto 0) & '0';
                when "011" =>  -- Shift right by 1 bit
                    	reg <= '0' & reg(63 downto 1);
                when "101" =>  -- Rotate left by 1 bit
                    	reg <= reg(62 downto 0) & reg(63);
                when "110" =>  -- Rotate right by 1 bit
                    	reg <= reg(0) & reg(63 downto 1);
                when others =>  -- Hold the current value
                    reg <= reg;
            end case;
		end if;
	end process;	
	
	dataOut <= reg;
end shift_register;
