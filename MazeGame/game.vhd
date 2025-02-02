library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity game is
    Port ( 
        CLOCK_24 : in STD_LOGIC;
        RESET_N : in STD_LOGIC;
        Key : in STD_LOGIC_VECTOR(3 downto 0);
        VGA_HS : out STD_LOGIC;
        VGA_VS : out STD_LOGIC;
        VGA_R : out STD_LOGIC_VECTOR(1 downto 0);
        VGA_G : out STD_LOGIC_VECTOR(1 downto 0);
        VGA_B : out STD_LOGIC_VECTOR(1 downto 0);
		  sevensegments : out STD_LOGIC_VECTOR(7 downto 0);
        outseg : out STD_LOGIC_VECTOR(3 downto 0);
		  LED : out STD_LOGIC_VECTOR(7 downto 0)
    );
end game;

architecture Behavioral of game is
    -- Constants
    constant GRID_WIDTH : integer := 20;
    constant GRID_HEIGHT : integer := 15;
    constant CELL_SIZE : integer := 32;
	 constant SYMBOL_SIZE : integer := 8;  -- 8x8 symbols
    constant SYMBOL_OFFSET : integer := (CELL_SIZE - SYMBOL_SIZE)/2;  -- Center symbol in cell	 
    constant PLAYER_SIZE : integer := 16;  -- Slightly smaller than cell
	 constant END_X : integer := GRID_WIDTH-2;  -- Second to last column
	 constant END_Y : integer := GRID_HEIGHT-2; -- Second to last row
	 constant PLAYER_SPEED : integer := 1;  -- Pixels per movement update
	 constant COLLISION_COOLDOWN_MAX : integer := 12_000_000;  -- 0.5 seconds at 24MHz
	  
    -- VGA Component
    component vga is
        port (
            CLK_24MHz : in std_logic;
            VS        : out std_logic;
            HS        : out std_logic;
            RED       : out std_logic_vector(1 downto 0);
            GREEN     : out std_logic_vector(1 downto 0);
            BLUE      : out std_logic_vector(1 downto 0);
            ScanlineX : out std_logic_vector(10 downto 0);
            ScanlineY : out std_logic_vector(10 downto 0);
            RESET     : in std_logic;
            ColorIN   : in std_logic_vector(5 downto 0)
        );
    end component;
	 
    -- Maze data structures
    -- We'll store each cell's walls as a 4-bit std_logic_vector:
    --   bit3 = top wall
    --   bit2 = right wall
    --   bit1 = bottom wall
    --   bit0 = left wall
    -- '1' means the wall is present, '0' means the wall is removed.
	 type wall_bits is array(0 to GRID_HEIGHT - 1, 0 to GRID_WIDTH - 1)of std_logic_vector(3 downto 0);
	 signal mazeWalls : wall_bits; 
	 type visited_array is array(0 to GRID_HEIGHT - 1, 0 to GRID_WIDTH - 1) of std_logic;
	 signal visited : visited_array;
	  
	 -- A stack to hold up to GRID_WIDTH * GRID_HEIGHT cells for DFS
    -- We'll store row/col separately for simplicity
	 constant MAX_STACK_SIZE : integer := GRID_WIDTH * GRID_HEIGHT / 4;
	 type stack_array is array(0 to MAX_STACK_SIZE - 1) of integer range 0 to 20;
    signal stackRow : stack_array;
    signal stackCol : stack_array;
    signal stackPtr : integer range 0 to MAX_STACK_SIZE := 0;
	 signal collision_cooldown : integer range 0 to COLLISION_COOLDOWN_MAX := 0;
	 
	 ------------------------------------------------------------------------
    -- Player position (in grid coordinates)
    ------------------------------------------------------------------------
    -- signal player_x : integer range 0 to GRID_WIDTH-1 := 1;
    -- signal player_y : integer range 0 to GRID_HEIGHT-1 := 1;
	 signal player_pixel_x : integer range 0 to GRID_WIDTH * CELL_SIZE := CELL_SIZE / 2;
	 signal player_pixel_y : integer range 0 to GRID_HEIGHT * CELL_SIZE := CELL_SIZE / 2;
	 signal player_lives : integer range 0 to 5 := 5;	 
	 signal collision_pulse : std_logic := '0';
	 signal game_over : std_logic := '0';
	 signal MOVE_DELAY_MAX : integer range 0 to 500_000 := 500_000;  -- Now a mutable signal
	 
	 ------------------------------------------------------------------------
    -- Button & movement control
    ------------------------------------------------------------------------
    --signal btn_prev   : std_logic_vector(3 downto 0) := (others => '0');
    signal move_delay : integer range 0 to 12000000 := 0;
    signal pseudo_rand   : std_logic_vector(31 downto 0) := x"ACE1_2467";
    signal reset_count   : unsigned(3 downto 0) := (others => '0');  -- Add this
    signal reset_signal  : std_logic;
    signal color_output  : std_logic_vector(5 downto 0);
    signal scanline_x    : std_logic_vector(10 downto 0);
    signal scanline_y    : std_logic_vector(10 downto 0);
    signal pixel_x, pixel_y : integer range 0 to 1023 := 0;  -- safe range

    -- Maze generation state machine
    type gen_state_type is (GEN_IDLE, GEN_START, GEN_STEP, GEN_BACKTRACK, GEN_DONE);
    signal gen_state : gen_state_type := GEN_IDLE;

    -- Current cell being processed in DFS
    signal cur_row, cur_col : integer range 0 to GRID_HEIGHT-1 := 0;
    signal cur_col2         : integer range 0 to GRID_WIDTH-1  := 0;  -- separate for clarity
	 
	 -- Counters and signals for seven segments
	 signal gameStarted      : std_logic := '0';
	 signal countdownVal     : integer range 0 to 100 := 100;
    signal second_delay     : integer range 0 to 24_000_000 := 24_000_000;
	 signal mux_counter      : unsigned(15 downto 0) := (others => '0');
    signal digit_select     : std_logic_vector(1 downto 0) := "00";
	 
    constant PLAYER_SMALL_SIZE : integer := 8;

	 constant POWERUP_DURATION : integer := 24_000_000 * 5;
	 signal ghost_powerup : std_logic := '0';
	 signal shrink_powerup : std_logic := '0';
 	 signal powerup_timer : integer range 0 to POWERUP_DURATION := 0;	 
	 signal ghost_timer_count : integer range 0 to 5 := 0;
	 signal ghost_second_delay : integer range 0 to 24_000_000 := 24_000_000;
	  
	 signal ghost_x : integer range 0 to GRID_WIDTH-1 := 3;
    signal ghost_y : integer range 0 to GRID_HEIGHT-1 := 3;
	 signal shrink_x : integer range 0 to GRID_WIDTH-1 := 15;
	 signal shrink_y : integer range 0 to GRID_HEIGHT-1 := 10;
	 signal ghost_active : std_logic := '1';
	 signal shrink_active : std_logic := '1';
	 
	 signal speed_x, speed_y : integer range 0 to GRID_WIDTH-1 := 5;  -- Example positions
	 signal speed_active : std_logic := '1';
	 signal speed_powerup : std_logic := '0';

	 signal mapchange_x, mapchange_y : integer range 0 to GRID_WIDTH-1 := 10;
	 signal mapchange_active : std_logic := '1';
	 
	 signal regenerate_req : std_logic := '0';
	 signal regenrate_ack  : std_logic := '0'; 
	 
	 
	  -- Symbol patterns (1 = draw, 0 = transparent)
	 type symbol_array is array(0 to 7) of std_logic_vector(7 downto 0);

     -- Ghost: "?" symbol
	  constant GHOST_SYMBOL : symbol_array := (
			 "00111100",  --   ****  
			 "01000010",  --  *    * 
			 "10000001",  -- *      *
			 "00001111",  --        *
			 "00011000",  --    **   
			 "00011000",  --         
			 "00000000",  --    **   
			 "00011000"   --         
	  );

		-- Shrink: "S" symbol 
	  constant SHRINK_SYMBOL : symbol_array := (
			 "01111110",  --  ****** 
			 "11000000",  -- **      
			 "01111100",  --  *****  
			 "00000110",  --      ** 
			 "00000110",  --      ** 
			 "11001100",  -- **  **  
			 "01111000",  --  ****   
			 "00000000"   --         
		);

		-- Speed: "!" symbol
		constant SPEED_SYMBOL : symbol_array := (
			 "00111000",  --    **   
			 "00111000",  --    **   
			 "00111000",  --    **   
			 "00111000",  --    **   
			 "00111000",  --    **   
			 "00000000",  --         
			 "00111000",  --    **   
			 "00111000"   --         
		);

		-- Mapchange: "M" symbol
		constant MAPCHANGE_SYMBOL : symbol_array := (
			 "10000001",  -- *      *
			 "11000011",  -- **    **
			 "11100111",  -- * *  * *
			 "11111111",  -- *  **  *
			 "11111111",  -- *  **  *
			 "11100111",  -- ***  * *
			 "11000011",  -- **    **
			 "10000001"   -- *      *
		);
	 

    -- A small helper to decode a single decimal digit (0..9) into 7-segment bits.
    -- The returned vector is (7 downto 0), where:
    -- bit0 = a-seg, bit1 = b, bit2 = c, bit3 = d, bit4 = e, bit5 = f, bit6 = g, bit7 = dp
    -- Adjust patterns depending on whether your hardware is active-low or active-high.
		function decode_seg(d : integer) return std_logic_vector is
		begin
			 case d is
				  when 0 => return x"C0";  -- 0
				  when 1 => return x"F9";  -- 1
				  when 2 => return x"A4";  -- 2
				  when 3 => return x"B0";  -- 3
				  when 4 => return x"99";  -- 4
				  when 5 => return x"92";  -- 5
				  when 6 => return x"82";  -- 6
				  when 7 => return x"F8";  -- 7
				  when 8 => return x"80";  -- 8
				  when 9 => return x"98";  -- 9
				  when others => return x"C0";  -- blank/off
			 end case;
		end function;
	 
    -- LFSR function (maximal length 32-bit xnor)
    function lfsr32(x : std_logic_vector(31 downto 0)) return std_logic_vector is
    begin
        return x(30 downto 0) & (x(0) xnor x(1) xnor x(21) xnor x(31));
    end function;

	 begin
			 reset_signal <= not RESET_N;

			 vga_inst : vga
				  port map (
						CLK_24MHz  => CLOCK_24,
						VS         => VGA_VS,
						HS         => VGA_HS,
						RED        => VGA_R,
						GREEN      => VGA_G,
						BLUE       => VGA_B,
						ScanlineX  => scanline_x,
						ScanlineY  => scanline_y,
						RESET      => reset_signal,
						ColorIN    => color_output
				  );

			 -- Convert scanline positions to integers
			 pixel_x <= to_integer(unsigned(scanline_x));
			 pixel_y <= to_integer(unsigned(scanline_y));
			 
			 -- LFSR Random generator update
				process(CLOCK_24)
				begin
					 if rising_edge(CLOCK_24) then
						  if reset_signal = '1' then
								reset_count <= reset_count + 1;
								pseudo_rand <= lfsr32(pseudo_rand xor std_logic_vector(reset_count & x"FFFFFF0"));
						  else
								pseudo_rand <= lfsr32(pseudo_rand);
						  end if;
					 end if;
				end process;
			 
			 -- Maze generation + DFS state machine	
				process(CLOCK_24, reset_signal, pseudo_rand, regenerate_req)
					variable neighbors : std_logic_vector(3 downto 0);
					variable nCount : integer range 0 to 4;
					variable idx : integer range 0 to 3;
					variable next_r, next_c : integer;
				begin
					if reset_signal = '1' or regenerate_req = '1' then 
						gen_state <= GEN_IDLE;
						stackPtr  <= 0;
						-- Initialize all walls to '1111' (all present)
						for r in 0 to GRID_HEIGHT-1 loop
							 for c in 0 to GRID_WIDTH-1 loop
								  mazeWalls(r,c) <= "1111";  -- all walls
								  visited(r,c)    <= '0';
							 end loop;
						end loop;
					elsif rising_edge(CLOCK_24) then 
						case gen_state is 						
							when GEN_IDLE =>
								  cur_row <= 0;
								  cur_col2 <= 0;
								  visited(0,0) <= '0';
								  stackRow(0)  <= 0;
								  stackCol(0)  <= 0;
								  stackPtr     <= 1;
								  gen_state    <= GEN_START;
							when GEN_START =>
								  -- We already visited (0,0). Move to step.
								  gen_state <= GEN_STEP;
							when GEN_STEP =>
								  -- Peek top of stack
								  -- Current row/col is cur_row,cur_col2
								  -- We'll find unvisited neighbors
								  cur_row <= stackRow(stackPtr-1);
								  cur_col2 <= stackCol(stackPtr-1);
								  -- Next state will compute neighbors
								  gen_state <= GEN_BACKTRACK;
							when GEN_BACKTRACK =>
								neighbors := (others => '0');
								nCount := 0;
								  -- Up neighbor
								  if (cur_row > 0) and (visited(cur_row-1, cur_col2)='0') then
										neighbors(3) := '1';
										nCount := nCount + 1;
								  end if;
								  -- Right neighbor
								  if (cur_col2 < GRID_WIDTH-1) and (visited(cur_row, cur_col2+1)='0') then
										neighbors(2) := '1';
										nCount := nCount + 1;
								  end if;
								  -- Down neighbor
								  if (cur_row < GRID_HEIGHT-1) and (visited(cur_row+1, cur_col2)='0') then
										neighbors(1) := '1';
										nCount := nCount + 1;
								  end if;
								  -- Left neighbor
								  if (cur_col2 > 0) and (visited(cur_row, cur_col2-1)='0') then
										neighbors(0) := '1';
										nCount := nCount + 1;
								  end if;
								  

								  if nCount > 0 then
										-- Pick a random direction among the ones set in 'neighbors'
										-- We have 4 possible directions, so reduce bits from LFSR
										idx := to_integer(unsigned(pseudo_rand(1 downto 0)));
										-- Keep rotating idx until we find a valid direction
										for attempt in 0 to 3 loop
											 if neighbors(idx) = '1' then
												  exit;  -- Exit the loop once a valid neighbor is found
											 end if;
											 idx := (idx + 1) mod 4;  -- Rotate to the next direction
										end loop;
										
										next_r := cur_row;
										next_c := cur_col2;
										
										case idx is 	
											when 0 =>
												next_c := cur_col2 - 1;
												mazeWalls(cur_row, cur_col2)(0) <= '0';
												mazeWalls(next_r, next_c)(2) <= '0'; 
											when 1 => 
												next_r := cur_row + 1;
												mazeWalls(cur_row, cur_col2)(1) <= '0';
												mazeWalls(next_r, next_c)(3) <= '0';    
											when 2 =>
												next_c := cur_col2 + 1;
											  -- remove right wall of current
											  mazeWalls(cur_row, cur_col2)(2) <= '0';
											  -- remove left wall of neighbor
											  mazeWalls(next_r, next_c)(0) <= '0'; 
											when 3 => 
											  next_r := cur_row - 1;
											  -- remove top wall of current
											  mazeWalls(cur_row, cur_col2)(3) <= '0';
											  -- remove bottom wall of neighbor
											  mazeWalls(next_r, next_c)(1) <= '0'; 
											when others =>
												null;
										end case;	
										
										visited(next_r, next_c) <= '1';
										stackRow(stackPtr) <= next_r;
										stackCol(stackPtr) <= next_c;
										stackPtr <= stackPtr + 1;
										
										gen_state <= GEN_STEP;
										
										else
											-- No unvisited neighbors => backtrack
											if stackPtr > 1 then
												 stackPtr <= stackPtr - 1;
												 gen_state <= GEN_STEP;
											else
												 -- Maze generation done
												 gen_state <= GEN_DONE;
											end if;
								  end if;				
							when GEN_DONE =>
								null;					
						end case;
					end if;
				end process;
					
				process(CLOCK_24, reset_signal, game_over, pseudo_rand)
				   variable next_pixel_x, next_pixel_y : integer;
					variable current_grid_x, current_grid_y : integer;
					variable collision_occurred : std_logic := '0';
					--variable next_x, next_y : integer;
				begin
					if reset_signal = '1' or game_over = '1' then
						regenerate_req <= '0';
					
						collision_cooldown <= 0;
					
						player_pixel_x   <= CELL_SIZE / 2;  -- Start at center of first cell
						player_pixel_y   <= CELL_SIZE / 2;
						move_delay       <= 0;
						
						gameStarted      <= '0';
						countdownVal     <= 100;
						second_delay     <= 24_000_000;
						mux_counter      <= (others => '0');
						digit_select     <= "00";
						game_over        <= '0';
						player_lives     <= 5;
						
						ghost_active <= '1';
						shrink_active <= '1';
						ghost_powerup <= '0';
						shrink_powerup <= '0';
						
						ghost_x <= to_integer(unsigned(pseudo_rand(4 downto 0))) mod GRID_WIDTH;
						ghost_y <= to_integer(unsigned(pseudo_rand(9 downto 5))) mod GRID_HEIGHT;
						shrink_x <= to_integer(unsigned(pseudo_rand(14 downto 10))) mod GRID_WIDTH;
						shrink_y <= to_integer(unsigned(pseudo_rand(19 downto 15))) mod GRID_HEIGHT;
						
						speed_active <= '1';
						mapchange_active <= '1';
						speed_powerup <= '0';

						-- Randomize new power-up positions
						speed_x <= to_integer(unsigned(pseudo_rand(24 downto 20))) mod GRID_WIDTH;
						speed_y <= to_integer(unsigned(pseudo_rand(29 downto 25))) mod GRID_HEIGHT;
						mapchange_x <= to_integer(unsigned(pseudo_rand(19 downto 15))) mod GRID_WIDTH;
						mapchange_y <= to_integer(unsigned(pseudo_rand(24 downto 20))) mod GRID_HEIGHT;
						
					elsif rising_edge(CLOCK_24) then
						mapchange_y <= mapchange_y;
						mapchange_x <= mapchange_x;
					   current_grid_x := player_pixel_x / CELL_SIZE;
						current_grid_y := player_pixel_y / CELL_SIZE;
						collision_occurred := '0';
							
						if move_delay = 0 then	
                       next_pixel_x := player_pixel_x;
							  next_pixel_y := player_pixel_y;
							  			  
							  case Key is
									when "1110" =>  -- Up
										if ghost_powerup = '0' then
										 if player_pixel_y - PLAYER_SIZE / 2 = current_grid_y * CELL_SIZE and mazeWalls(current_grid_y, current_grid_x)(3) = '1' then 
												next_pixel_y := player_pixel_y;
												collision_occurred := '1';
										 else
												next_pixel_y := player_pixel_y - PLAYER_SPEED;
										 end if;
										else 
											next_pixel_y := player_pixel_y - PLAYER_SPEED;
										end if;
										 -- Check if top wall is 0
--										 if mazeWalls(current_grid_y, current_grid_x)(3) = '0' then
--											   if (player_pixel_y - PLAYER_SIZE/2) > current_grid_y * CELL_SIZE then
--													 next_pixel_y := player_pixel_y - PLAYER_SPEED;
--												end if;
--										 end if;
									when "1101" =>  -- Down
									   if ghost_powerup = '0' then
										 if player_pixel_y + PLAYER_SIZE / 2 = current_grid_y * CELL_SIZE + CELL_SIZE and mazeWalls(current_grid_y, current_grid_x)(1) = '1' then 
												next_pixel_y := player_pixel_y;
												collision_occurred := '1';
										 else
												next_pixel_y := player_pixel_y + PLAYER_SPEED;
										 end if;
										else
										  next_pixel_y := player_pixel_y + PLAYER_SPEED;
										end if;
										 -- Check if bottom wall is 0
--										 if mazeWalls(current_grid_y, current_grid_x)(1) = '0' then
--											   if (player_pixel_y + PLAYER_SIZE/2) < ((current_grid_y + 1) * CELL_SIZE) then
--												    next_pixel_y := player_pixel_y + PLAYER_SPEED;
--											   end if;
--										 end if;
									when "1011" =>  -- Left
									  if ghost_powerup = '0' then 
										 if player_pixel_x - PLAYER_SIZE / 2 = current_grid_x * CELL_SIZE and mazeWalls(current_grid_y, current_grid_x)(0) = '1' then 
												next_pixel_x := player_pixel_x;
												collision_occurred := '1';
										 else
												next_pixel_x := player_pixel_x - PLAYER_SPEED;
										 end if;
										else
											next_pixel_x := player_pixel_x - PLAYER_SPEED;
										end if;
										 -- Check if left wall is 0
--										  if mazeWalls(current_grid_y, current_grid_x)(0) = '0' then
--											  if (player_pixel_x - PLAYER_SIZE/2) > current_grid_x * CELL_SIZE then
--												    next_pixel_x := player_pixel_x - PLAYER_SPEED;
--											  end if;
--										  end if;
									when "0111" =>  -- Right
									  if ghost_powerup = '0' then 
										 if player_pixel_x + PLAYER_SIZE / 2 = current_grid_x * CELL_SIZE + CELL_SIZE and mazeWalls(current_grid_y, current_grid_x)(2) = '1' then 
												next_pixel_x := player_pixel_x;
												collision_occurred := '1';
										 else
												next_pixel_x := player_pixel_x + PLAYER_SPEED;
										 end if;
										else
										     next_pixel_x := player_pixel_x + PLAYER_SPEED;
										end if;
										 -- Check if right wall is 0
--										  if mazeWalls(current_grid_y, current_grid_x)(2) = '0' then
--											  if (player_pixel_x + PLAYER_SIZE/2) < ((current_grid_x + 1) * CELL_SIZE) then 
--													next_pixel_x := player_pixel_x + PLAYER_SPEED;
--											  end if;
--										  end if;
									when others =>
										 null;
							  end case;
								  
								-- Make sure within bounds just in case
								if next_pixel_x >= 0 and next_pixel_x < GRID_WIDTH * CELL_SIZE then
									 player_pixel_x <= next_pixel_x;
								end if;
								if next_pixel_y >= 0 and next_pixel_y < GRID_HEIGHT * CELL_SIZE then
									 player_pixel_y <= next_pixel_y;
								end if;

							   move_delay <= MOVE_DELAY_MAX;
								collision_pulse <= collision_occurred;
								  	
							   --btn_prev <= Key;	
						else
							move_delay <= move_delay - 1;
							collision_pulse <= '0';
						end if;
						
						if collision_pulse = '1' and gameStarted = '1' and player_lives > 0 then
								    if collision_cooldown = 0 then
										  player_lives <= player_lives - 1;
										  collision_cooldown <= COLLISION_COOLDOWN_MAX;  -- Start cooldown
									 end if;
						elsif collision_cooldown > 0 then
									 collision_cooldown <= collision_cooldown - 1;
						end if;
						
						if countdownVal = 0 or (current_grid_x = END_X and current_grid_y = END_Y) or player_lives = 0 then
								game_over <= '1';
						end if;
						
						if (gameStarted = '0') then
							 -- If ANY key is pressed that wasn't pressed before,
							 -- we consider that as "start the game"
							 if (Key /= "1111") then
								  gameStarted <= '1';
							 end if;
						end if;
						
						if ghost_powerup = '1' then
							 if ghost_second_delay = 0 then
								  ghost_timer_count <= ghost_timer_count - 1;
								  ghost_second_delay <= 24_000_000;
								  if ghost_timer_count = 0 then
										ghost_powerup <= '0';
								  end if;
							 else
								  ghost_second_delay <= ghost_second_delay - 1;
							 end if;
						end if;
						 
						if gameStarted = '1' then
							if second_delay = 0 then
								-- Decrement the countdown once every 1 second
								if countdownVal > 0 then
									countdownVal <= countdownVal - 1;
								end if;
								second_delay <= 24_000_000;  -- reload ~1 second
							else
								second_delay <= second_delay - 1;
							end if;
						end if;
						
						-- Check powerup collisions
						if gameStarted = '1' then
							 current_grid_x := player_pixel_x / CELL_SIZE;
							 current_grid_y := player_pixel_y / CELL_SIZE;
							 
							 -- Ghost powerup collision
							 if (current_grid_x = ghost_x) and (current_grid_y = ghost_y) and (ghost_active = '1') then
								  ghost_active <= '0';
								  ghost_powerup <= '1';
								      ghost_timer_count <= 5;
										ghost_second_delay <= 24_000_000;
							 end if;
							 
							 -- Shrink powerup collision
							 if (current_grid_x = shrink_x) and (current_grid_y = shrink_y) and (shrink_active = '1') then
								  shrink_active <= '0';
								  shrink_powerup <= '1';
							 end if;
							 
							 -- Collision detection
							if (current_grid_x = speed_x) and (current_grid_y = speed_y) and (speed_active = '1') then
								 speed_active <= '0';
								 speed_powerup <= '1';
							end if;

							-- Movement speed modification
							if speed_powerup = '1' then
								 MOVE_DELAY_MAX <= 250_000;  -- Double speed
							else
								 MOVE_DELAY_MAX <= 500_000;  -- Normal speed
							end if;
							
							if (current_grid_x = mapchange_x) and (current_grid_y = mapchange_y) and (mapchange_active = '1') then
									 mapchange_active <= '0';
									 regenerate_req <= '1';
							else 
									regenerate_req <= '0';
							end if;
						end if;
						
						mux_counter <= mux_counter + 1;
						digit_select <= std_logic_vector(mux_counter(15 downto 14));
						
						case digit_select is 
							when "00" => 
								outseg <= "0111";
								if gameStarted = '0' then
									sevensegments <= decode_seg(1);
								else 
									sevensegments <= decode_seg(countdownVal mod 10);
								end if;
							when "01" => 
								outseg <= "1011";
								if gameStarted = '0' then
									sevensegments <= decode_seg(4);
								else 
									sevensegments <= decode_seg((countdownVal / 10) mod 10);
								end if;
							when "10" => 
								outseg <= "1101";
								if gameStarted = '0' then
									sevensegments <= decode_seg(2);
								else 
									sevensegments <= decode_seg(0);
								end if;
							when "11" => 
								outseg <= "1110";
								if gameStarted = '0' then
									sevensegments <= decode_seg(2);
								else 
									  if ghost_powerup = '1' then
											sevensegments <= decode_seg(ghost_timer_count);
									  else
											sevensegments <= decode_seg(0);
									  end if;
								end if;
							when others => 
								   outseg <= "1111";
                           sevensegments <= "11111111";
						end case;
						
					end if;
				end process;
				
				color_logic : process(pixel_x, pixel_y, player_pixel_x, player_pixel_y, mazeWalls, 
											 ghost_x, ghost_y, shrink_x, shrink_y, speed_x, speed_y, 
											 mapchange_x, mapchange_y, ghost_active, shrink_active, 
											 speed_active, mapchange_active, shrink_powerup)
											 
				  variable main_player_size : integer := PLAYER_SIZE;
				  variable grid_x, grid_y : integer;
				  variable local_x, local_y : integer;
				  variable walls : std_logic_vector(3 downto 0);
				begin
				  -- Default color
				  color_output <= "001111";
				  
				  if (pixel_x < GRID_WIDTH * CELL_SIZE) and (pixel_y < GRID_HEIGHT * CELL_SIZE) then
					 grid_x := pixel_x / CELL_SIZE;
					 grid_y := pixel_y / CELL_SIZE;

					 local_x := pixel_x mod CELL_SIZE;
					 local_y := pixel_y mod CELL_SIZE;

					 walls := mazeWalls(grid_y, grid_x);

					 -- Check top wall
					 if (walls(3) = '1') and (local_y = 0) then
						color_output <= "111111";  -- white
					 end if;

					 -- Check right wall
					 if (walls(2) = '1') and (local_x = CELL_SIZE-1) then
						color_output <= "111111";
					 end if;

					 -- Check bottom wall
					 if (walls(1) = '1') and (local_y = CELL_SIZE-1) then
						color_output <= "111111";
					 end if;

					 -- Check left wall
					 if (walls(0) = '1') and (local_x = 0) then
						color_output <= "111111";
					 end if;
					 

						if shrink_powerup = '1' then
							 main_player_size := PLAYER_SIZE / 2;
						else 
							main_player_size := PLAYER_SIZE;
						end if;

					 -- Draw the player in red
						if (pixel_x >= player_pixel_x - main_player_size/2) and 
							(pixel_x < player_pixel_x + main_player_size/2) and
							(pixel_y >= player_pixel_y - main_player_size/2) and 
							(pixel_y < player_pixel_y + main_player_size/2) then
							 color_output <= "000000";  -- red
						end if;
					 
					 -- draw the end point 
				  if (grid_x = END_X) and (grid_y = END_Y) then
						 if (local_x >= (CELL_SIZE - PLAYER_SIZE)/2) and
							  (local_x < (CELL_SIZE + PLAYER_SIZE)/2) and
							  (local_y >= (CELL_SIZE - PLAYER_SIZE)/2) and
							  (local_y < (CELL_SIZE + PLAYER_SIZE)/2) then
							  color_output <= "001100";  -- green
						 end if;
				  end if;
				  
				  -- Calculate symbol coordinates if in power-up cell
					if (grid_x = ghost_x and grid_y = ghost_y and ghost_active = '1') or
						(grid_x = shrink_x and grid_y = shrink_y and shrink_active = '1') or
						(grid_x = speed_x and grid_y = speed_y and speed_active = '1') or
						(grid_x = mapchange_x and grid_y = mapchange_y and mapchange_active = '1') then
						 
						 -- Get relative position within symbol area
						 local_x := pixel_x mod CELL_SIZE;
						 local_y := pixel_y mod CELL_SIZE;
						 
						 if local_x >= SYMBOL_OFFSET and local_x < SYMBOL_OFFSET + SYMBOL_SIZE and
							 local_y >= SYMBOL_OFFSET and local_y < SYMBOL_OFFSET + SYMBOL_SIZE then
							  
							  -- Calculate symbol grid coordinates
							  local_x := local_x - SYMBOL_OFFSET;
							  local_y := local_y - SYMBOL_OFFSET;
							  
							  -- Check symbol pattern based on power-up type
							  if grid_x = ghost_x and grid_y = ghost_y then
									if GHOST_SYMBOL(local_y)(local_x) = '1' then
										 color_output <= "111000";  -- orange
									end if;
							  elsif grid_x = shrink_x and grid_y = shrink_y then
									if SHRINK_SYMBOL(local_y)(local_x) = '1' then
										 color_output <= "110011";  -- Magenta
									end if;
							  elsif grid_x = speed_x and grid_y = speed_y then
									if SPEED_SYMBOL(local_y)(local_x) = '1' then
										 color_output <= "111100";  -- Yellow
									end if;
							  elsif grid_x = mapchange_x and grid_y = mapchange_y then
									if MAPCHANGE_SYMBOL(local_y)(local_x) = '1' then
										 color_output <= "000011";  -- Blue
									end if;
							  end if;
						 end if;
					end if;
				  
--				  if (grid_x = ghost_x) and (grid_y = ghost_y) and (ghost_active = '1') then
--						 if (local_x >= (CELL_SIZE - PLAYER_SIZE)/2) and
--							  (local_x < (CELL_SIZE + PLAYER_SIZE)/2) and
--							  (local_y >= (CELL_SIZE - PLAYER_SIZE)/2) and
--							  (local_y < (CELL_SIZE + PLAYER_SIZE)/2) then
--							  color_output <= "101111";  -- green
--						 end if;
--						
----						 if (local_x >= (CELL_SIZE - PLAYER_SIZE)/2) and
----							 (local_y >= (CELL_SIZE - PLAYER_SIZE)/2) then
----							  color_output <= "111100";  -- Cyan
----						 end if;
--				  end if;
--				  
--				  -- Draw Shrink Powerup
--					if (grid_x = shrink_x) and (grid_y = shrink_y) and (shrink_active = '1') then
--						 if (local_x >= (CELL_SIZE - PLAYER_SIZE)/2) and
--							  (local_x < (CELL_SIZE + PLAYER_SIZE)/2) and
--							  (local_y >= (CELL_SIZE - PLAYER_SIZE)/2) and
--							  (local_y < (CELL_SIZE + PLAYER_SIZE)/2) then
--							  color_output <= "110011";  
--						 end if;
----						 if (local_x >= (CELL_SIZE - PLAYER_SIZE)/2) and
----							 (local_y >= (CELL_SIZE - PLAYER_SIZE)/2) then
----							  color_output <= "111111";  -- White
----						 end if;
--					end if;
--				  
--				  -- Speed power-up (yellow)
--					if (grid_x = speed_x) and (grid_y = speed_y) and (speed_active = '1') then
--						 if (local_x >= (CELL_SIZE - PLAYER_SIZE)/2) and
--							 (local_y >= (CELL_SIZE - PLAYER_SIZE)/2) then
--							  color_output <= "111100";  -- Yellow
--						 end if;
--					end if;
--
--					-- Map change power-up (blue)
--					if (grid_x = mapchange_x) and (grid_y = mapchange_y) and (mapchange_active = '1') then
--						 if (local_x >= (CELL_SIZE - PLAYER_SIZE)/2) and
--							 (local_y >= (CELL_SIZE - PLAYER_SIZE)/2) then
--							  color_output <= "000011";  -- Blue
--						 end if;
--					end if;
				  end if;

				end process color_logic;
				
				LED <= "00011111" when (player_lives = 5 and gameStarted = '1') else
						 "00001111" when (player_lives = 4 and gameStarted = '1') else
						 "00000111" when (player_lives = 3 and gameStarted = '1') else
						 "00000011" when (player_lives = 2 and gameStarted = '1') else
						 "00000001" when (player_lives = 1 and gameStarted = '1') else
						 "00000000";
end Behavioral;