LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY game IS
	PORT (
		CLOCK_24 : IN STD_LOGIC;
		RESET_N : IN STD_LOGIC;
		Key : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		VGA_HS : OUT STD_LOGIC;
		VGA_VS : OUT STD_LOGIC;
		VGA_R : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		VGA_G : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		VGA_B : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		sevensegments : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		outseg : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		LED : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END game;

ARCHITECTURE Behavioral OF game IS
	-- Constants
	CONSTANT GRID_WIDTH : INTEGER := 20;
	CONSTANT GRID_HEIGHT : INTEGER := 15;
	CONSTANT CELL_SIZE : INTEGER := 32;
	CONSTANT SYMBOL_SIZE : INTEGER := 8; -- 8x8 symbols
	CONSTANT SYMBOL_OFFSET : INTEGER := (CELL_SIZE - SYMBOL_SIZE)/2; -- Center symbol in cell	 
	CONSTANT PLAYER_SIZE : INTEGER := 16; -- Slightly smaller than cell
	CONSTANT END_X : INTEGER := GRID_WIDTH - 2; -- Second to last column
	CONSTANT END_Y : INTEGER := GRID_HEIGHT - 2; -- Second to last row
	CONSTANT PLAYER_SPEED : INTEGER := 1; -- Pixels per movement update
	CONSTANT COLLISION_COOLDOWN_MAX : INTEGER := 12_000_000; -- 0.5 seconds at 24MHz

	-- VGA Component
	COMPONENT vga IS
		PORT (
			CLK_24MHz : IN STD_LOGIC;
			VS : OUT STD_LOGIC;
			HS : OUT STD_LOGIC;
			RED : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			GREEN : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			BLUE : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			ScanlineX : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
			ScanlineY : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
			RESET : IN STD_LOGIC;
			ColorIN : IN STD_LOGIC_VECTOR(5 DOWNTO 0)
		);
	END COMPONENT;

	-- Maze data structures
	-- We'll store each cell's walls as a 4-bit std_logic_vector:
	--   bit3 = top wall
	--   bit2 = right wall
	--   bit1 = bottom wall
	--   bit0 = left wall
	-- '1' means the wall is present, '0' means the wall is removed.
	TYPE wall_bits IS ARRAY(0 TO GRID_HEIGHT - 1, 0 TO GRID_WIDTH - 1)OF STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL mazeWalls : wall_bits;
	TYPE visited_array IS ARRAY(0 TO GRID_HEIGHT - 1, 0 TO GRID_WIDTH - 1) OF STD_LOGIC;
	SIGNAL visited : visited_array;

	-- A stack to hold up to GRID_WIDTH * GRID_HEIGHT cells for DFS
	-- We'll store row/col separately for simplicity
	CONSTANT MAX_STACK_SIZE : INTEGER := GRID_WIDTH * GRID_HEIGHT / 4;
	TYPE stack_array IS ARRAY(0 TO MAX_STACK_SIZE - 1) OF INTEGER RANGE 0 TO 20;
	SIGNAL stackRow : stack_array;
	SIGNAL stackCol : stack_array;
	SIGNAL stackPtr : INTEGER RANGE 0 TO MAX_STACK_SIZE := 0;
	SIGNAL collision_cooldown : INTEGER RANGE 0 TO COLLISION_COOLDOWN_MAX := 0;

	------------------------------------------------------------------------
	-- Player position (in grid coordinates)
	------------------------------------------------------------------------
	-- signal player_x : integer range 0 to GRID_WIDTH-1 := 1;
	-- signal player_y : integer range 0 to GRID_HEIGHT-1 := 1;
	SIGNAL player_pixel_x : INTEGER RANGE 0 TO GRID_WIDTH * CELL_SIZE := CELL_SIZE / 2;
	SIGNAL player_pixel_y : INTEGER RANGE 0 TO GRID_HEIGHT * CELL_SIZE := CELL_SIZE / 2;
	SIGNAL player_lives : INTEGER RANGE 0 TO 5 := 5;
	SIGNAL collision_pulse : STD_LOGIC := '0';
	SIGNAL game_over : STD_LOGIC := '0';
	SIGNAL MOVE_DELAY_MAX : INTEGER RANGE 0 TO 500_000 := 500_000; -- Now a mutable signal

	------------------------------------------------------------------------
	-- Button & movement control
	------------------------------------------------------------------------
	--signal btn_prev   : std_logic_vector(3 downto 0) := (others => '0');
	SIGNAL move_delay : INTEGER RANGE 0 TO 12000000 := 0;
	SIGNAL pseudo_rand : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"ACE1_2467";
	SIGNAL reset_count : unsigned(3 DOWNTO 0) := (OTHERS => '0'); -- Add this
	SIGNAL reset_signal : STD_LOGIC;
	SIGNAL color_output : STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL scanline_x : STD_LOGIC_VECTOR(10 DOWNTO 0);
	SIGNAL scanline_y : STD_LOGIC_VECTOR(10 DOWNTO 0);
	SIGNAL pixel_x, pixel_y : INTEGER RANGE 0 TO 1023 := 0; -- safe range

	-- Maze generation state machine
	TYPE gen_state_type IS (GEN_IDLE, GEN_START, GEN_STEP, GEN_BACKTRACK, GEN_DONE);
	SIGNAL gen_state : gen_state_type := GEN_IDLE;

	-- Current cell being processed in DFS
	SIGNAL cur_row, cur_col : INTEGER RANGE 0 TO GRID_HEIGHT - 1 := 0;
	SIGNAL cur_col2 : INTEGER RANGE 0 TO GRID_WIDTH - 1 := 0; -- separate for clarity

	-- Counters and signals for seven segments
	SIGNAL gameStarted : STD_LOGIC := '0';
	SIGNAL countdownVal : INTEGER RANGE 0 TO 100 := 100;
	SIGNAL second_delay : INTEGER RANGE 0 TO 24_000_000 := 24_000_000;
	SIGNAL mux_counter : unsigned(15 DOWNTO 0) := (OTHERS => '0');
	SIGNAL digit_select : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";

	CONSTANT PLAYER_SMALL_SIZE : INTEGER := 8;

	CONSTANT POWERUP_DURATION : INTEGER := 24_000_000 * 5;
	SIGNAL ghost_powerup : STD_LOGIC := '0';
	SIGNAL shrink_powerup : STD_LOGIC := '0';
	SIGNAL powerup_timer : INTEGER RANGE 0 TO POWERUP_DURATION := 0;
	SIGNAL ghost_timer_count : INTEGER RANGE 0 TO 5 := 0;
	SIGNAL ghost_second_delay : INTEGER RANGE 0 TO 24_000_000 := 24_000_000;

	SIGNAL ghost_x : INTEGER RANGE 0 TO GRID_WIDTH - 1 := 3;
	SIGNAL ghost_y : INTEGER RANGE 0 TO GRID_HEIGHT - 1 := 3;
	SIGNAL shrink_x : INTEGER RANGE 0 TO GRID_WIDTH - 1 := 15;
	SIGNAL shrink_y : INTEGER RANGE 0 TO GRID_HEIGHT - 1 := 10;
	SIGNAL ghost_active : STD_LOGIC := '1';
	SIGNAL shrink_active : STD_LOGIC := '1';

	SIGNAL speed_x, speed_y : INTEGER RANGE 0 TO GRID_WIDTH - 1 := 5; -- Example positions
	SIGNAL speed_active : STD_LOGIC := '1';
	SIGNAL speed_powerup : STD_LOGIC := '0';

	SIGNAL mapchange_x, mapchange_y : INTEGER RANGE 0 TO GRID_WIDTH - 1 := 10;
	SIGNAL mapchange_active : STD_LOGIC := '1';

	SIGNAL regenerate_req : STD_LOGIC := '0';
	SIGNAL regenrate_ack : STD_LOGIC := '0';
	-- Symbol patterns (1 = draw, 0 = transparent)
	TYPE symbol_array IS ARRAY(0 TO 7) OF STD_LOGIC_VECTOR(7 DOWNTO 0);

	-- Ghost: "?" symbol
	CONSTANT GHOST_SYMBOL : symbol_array := (
		"00111100", --   ****  
		"01000010", --  *    * 
		"10000001", -- *      *
		"00001111", --        *
		"00011000", --    **   
		"00011000", --         
		"00000000", --    **   
		"00011000" --         
	);

	-- Shrink: "S" symbol 
	CONSTANT SHRINK_SYMBOL : symbol_array := (
		"01111110", --  ****** 
		"11000000", -- **      
		"01111100", --  *****  
		"00000110", --      ** 
		"00000110", --      ** 
		"11001100", -- **  **  
		"01111000", --  ****   
		"00000000" --         
	);

	-- Speed: "!" symbol
	CONSTANT SPEED_SYMBOL : symbol_array := (
		"00111000", --    **   
		"00111000", --    **   
		"00111000", --    **   
		"00111000", --    **   
		"00111000", --    **   
		"00000000", --         
		"00111000", --    **   
		"00111000" --         
	);

	-- Mapchange: "M" symbol
	CONSTANT MAPCHANGE_SYMBOL : symbol_array := (
		"10000001", -- *      *
		"11000011", -- **    **
		"11100111", -- * *  * *
		"11111111", -- *  **  *
		"11111111", -- *  **  *
		"11100111", -- ***  * *
		"11000011", -- **    **
		"10000001" -- *      *
	);
	-- A small helper to decode a single decimal digit (0..9) into 7-segment bits.
	-- The returned vector is (7 downto 0), where:
	-- bit0 = a-seg, bit1 = b, bit2 = c, bit3 = d, bit4 = e, bit5 = f, bit6 = g, bit7 = dp
	-- Adjust patterns depending on whether your hardware is active-low or active-high.
	FUNCTION decode_seg(d : INTEGER) RETURN STD_LOGIC_VECTOR IS
	BEGIN
		CASE d IS
			WHEN 0 => RETURN x"C0"; -- 0
			WHEN 1 => RETURN x"F9"; -- 1
			WHEN 2 => RETURN x"A4"; -- 2
			WHEN 3 => RETURN x"B0"; -- 3
			WHEN 4 => RETURN x"99"; -- 4
			WHEN 5 => RETURN x"92"; -- 5
			WHEN 6 => RETURN x"82"; -- 6
			WHEN 7 => RETURN x"F8"; -- 7
			WHEN 8 => RETURN x"80"; -- 8
			WHEN 9 => RETURN x"98"; -- 9
			WHEN OTHERS => RETURN x"C0"; -- blank/off
		END CASE;
	END FUNCTION;

	-- LFSR function (maximal length 32-bit xnor)
	FUNCTION lfsr32(x : STD_LOGIC_VECTOR(31 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
	BEGIN
		RETURN x(30 DOWNTO 0) & (x(0) XNOR x(1) XNOR x(21) XNOR x(31));
	END FUNCTION;

BEGIN
	reset_signal <= NOT RESET_N;

	vga_inst : vga
	PORT MAP(
		CLK_24MHz => CLOCK_24,
		VS => VGA_VS,
		HS => VGA_HS,
		RED => VGA_R,
		GREEN => VGA_G,
		BLUE => VGA_B,
		ScanlineX => scanline_x,
		ScanlineY => scanline_y,
		RESET => reset_signal,
		ColorIN => color_output
	);

	-- Convert scanline positions to integers
	pixel_x <= to_integer(unsigned(scanline_x));
	pixel_y <= to_integer(unsigned(scanline_y));

	-- LFSR Random generator update
	PROCESS (CLOCK_24)
	BEGIN
		IF rising_edge(CLOCK_24) THEN
			IF reset_signal = '1' THEN
				reset_count <= reset_count + 1;
				pseudo_rand <= lfsr32(pseudo_rand XOR STD_LOGIC_VECTOR(reset_count & x"FFFFFF0"));
			ELSE
				pseudo_rand <= lfsr32(pseudo_rand);
			END IF;
		END IF;
	END PROCESS;

	-- Maze generation + DFS state machine	
	PROCESS (CLOCK_24, reset_signal, pseudo_rand, regenerate_req)
		VARIABLE neighbors : STD_LOGIC_VECTOR(3 DOWNTO 0);
		VARIABLE nCount : INTEGER RANGE 0 TO 4;
		VARIABLE idx : INTEGER RANGE 0 TO 3;
		VARIABLE next_r, next_c : INTEGER;
	BEGIN
		IF reset_signal = '1' OR regenerate_req = '1' THEN
			gen_state <= GEN_IDLE;
			stackPtr <= 0;
			-- Initialize all walls to '1111' (all present)
			FOR r IN 0 TO GRID_HEIGHT - 1 LOOP
				FOR c IN 0 TO GRID_WIDTH - 1 LOOP
					mazeWalls(r, c) <= "1111"; -- all walls
					visited(r, c) <= '0';
				END LOOP;
			END LOOP;
		ELSIF rising_edge(CLOCK_24) THEN
			CASE gen_state IS
				WHEN GEN_IDLE =>
					cur_row <= 0;
					cur_col2 <= 0;
					visited(0, 0) <= '0';
					stackRow(0) <= 0;
					stackCol(0) <= 0;
					stackPtr <= 1;
					gen_state <= GEN_START;
				WHEN GEN_START =>
					-- We already visited (0,0). Move to step.
					gen_state <= GEN_STEP;
				WHEN GEN_STEP =>
					-- Peek top of stack
					-- Current row/col is cur_row,cur_col2
					-- We'll find unvisited neighbors
					cur_row <= stackRow(stackPtr - 1);
					cur_col2 <= stackCol(stackPtr - 1);
					-- Next state will compute neighbors
					gen_state <= GEN_BACKTRACK;
				WHEN GEN_BACKTRACK =>
					neighbors := (OTHERS => '0');
					nCount := 0;
					-- Up neighbor
					IF (cur_row > 0) AND (visited(cur_row - 1, cur_col2) = '0') THEN
						neighbors(3) := '1';
						nCount := nCount + 1;
					END IF;
					-- Right neighbor
					IF (cur_col2 < GRID_WIDTH - 1) AND (visited(cur_row, cur_col2 + 1) = '0') THEN
						neighbors(2) := '1';
						nCount := nCount + 1;
					END IF;
					-- Down neighbor
					IF (cur_row < GRID_HEIGHT - 1) AND (visited(cur_row + 1, cur_col2) = '0') THEN
						neighbors(1) := '1';
						nCount := nCount + 1;
					END IF;
					-- Left neighbor
					IF (cur_col2 > 0) AND (visited(cur_row, cur_col2 - 1) = '0') THEN
						neighbors(0) := '1';
						nCount := nCount + 1;
					END IF;
					IF nCount > 0 THEN
						-- Pick a random direction among the ones set in 'neighbors'
						-- We have 4 possible directions, so reduce bits from LFSR
						idx := to_integer(unsigned(pseudo_rand(1 DOWNTO 0)));
						-- Keep rotating idx until we find a valid direction
						FOR attempt IN 0 TO 3 LOOP
							IF neighbors(idx) = '1' THEN
								EXIT; -- Exit the loop once a valid neighbor is found
							END IF;
							idx := (idx + 1) MOD 4; -- Rotate to the next direction
						END LOOP;

						next_r := cur_row;
						next_c := cur_col2;

						CASE idx IS
							WHEN 0 =>
								next_c := cur_col2 - 1;
								mazeWalls(cur_row, cur_col2)(0) <= '0';
								mazeWalls(next_r, next_c)(2) <= '0';
							WHEN 1 =>
								next_r := cur_row + 1;
								mazeWalls(cur_row, cur_col2)(1) <= '0';
								mazeWalls(next_r, next_c)(3) <= '0';
							WHEN 2 =>
								next_c := cur_col2 + 1;
								-- remove right wall of current
								mazeWalls(cur_row, cur_col2)(2) <= '0';
								-- remove left wall of neighbor
								mazeWalls(next_r, next_c)(0) <= '0';
							WHEN 3 =>
								next_r := cur_row - 1;
								-- remove top wall of current
								mazeWalls(cur_row, cur_col2)(3) <= '0';
								-- remove bottom wall of neighbor
								mazeWalls(next_r, next_c)(1) <= '0';
							WHEN OTHERS =>
								NULL;
						END CASE;

						visited(next_r, next_c) <= '1';
						stackRow(stackPtr) <= next_r;
						stackCol(stackPtr) <= next_c;
						stackPtr <= stackPtr + 1;

						gen_state <= GEN_STEP;

					ELSE
						-- No unvisited neighbors => backtrack
						IF stackPtr > 1 THEN
							stackPtr <= stackPtr - 1;
							gen_state <= GEN_STEP;
						ELSE
							-- Maze generation done
							gen_state <= GEN_DONE;
						END IF;
					END IF;
				WHEN GEN_DONE =>
					NULL;
			END CASE;
		END IF;
	END PROCESS;

	PROCESS (CLOCK_24, reset_signal, game_over, pseudo_rand)
		VARIABLE next_pixel_x, next_pixel_y : INTEGER;
		VARIABLE current_grid_x, current_grid_y : INTEGER;
		VARIABLE collision_occurred : STD_LOGIC := '0';
		--variable next_x, next_y : integer;
	BEGIN
		IF reset_signal = '1' OR game_over = '1' THEN
			regenerate_req <= '0';

			collision_cooldown <= 0;

			player_pixel_x <= CELL_SIZE / 2; -- Start at center of first cell
			player_pixel_y <= CELL_SIZE / 2;
			move_delay <= 0;

			gameStarted <= '0';
			countdownVal <= 100;
			second_delay <= 24_000_000;
			mux_counter <= (OTHERS => '0');
			digit_select <= "00";
			game_over <= '0';
			player_lives <= 5;

			ghost_active <= '1';
			shrink_active <= '1';
			ghost_powerup <= '0';
			shrink_powerup <= '0';

			ghost_x <= to_integer(unsigned(pseudo_rand(4 DOWNTO 0))) MOD GRID_WIDTH;
			ghost_y <= to_integer(unsigned(pseudo_rand(9 DOWNTO 5))) MOD GRID_HEIGHT;
			shrink_x <= to_integer(unsigned(pseudo_rand(14 DOWNTO 10))) MOD GRID_WIDTH;
			shrink_y <= to_integer(unsigned(pseudo_rand(19 DOWNTO 15))) MOD GRID_HEIGHT;

			speed_active <= '1';
			mapchange_active <= '1';
			speed_powerup <= '0';

			-- Randomize new power-up positions
			speed_x <= to_integer(unsigned(pseudo_rand(24 DOWNTO 20))) MOD GRID_WIDTH;
			speed_y <= to_integer(unsigned(pseudo_rand(29 DOWNTO 25))) MOD GRID_HEIGHT;
			mapchange_x <= to_integer(unsigned(pseudo_rand(19 DOWNTO 15))) MOD GRID_WIDTH;
			mapchange_y <= to_integer(unsigned(pseudo_rand(24 DOWNTO 20))) MOD GRID_HEIGHT;

		ELSIF rising_edge(CLOCK_24) THEN
			mapchange_y <= mapchange_y;
			mapchange_x <= mapchange_x;
			current_grid_x := player_pixel_x / CELL_SIZE;
			current_grid_y := player_pixel_y / CELL_SIZE;
			collision_occurred := '0';

			IF move_delay = 0 THEN
				next_pixel_x := player_pixel_x;
				next_pixel_y := player_pixel_y;

				CASE Key IS
					WHEN "1110" => -- Up
						IF ghost_powerup = '0' THEN
							IF player_pixel_y - PLAYER_SIZE / 2 = current_grid_y * CELL_SIZE AND mazeWalls(current_grid_y, current_grid_x)(3) = '1' THEN
								next_pixel_y := player_pixel_y;
								collision_occurred := '1';
							ELSE
								next_pixel_y := player_pixel_y - PLAYER_SPEED;
							END IF;
						ELSE
							next_pixel_y := player_pixel_y - PLAYER_SPEED;
						END IF;
						-- Check if top wall is 0
						--										 if mazeWalls(current_grid_y, current_grid_x)(3) = '0' then
						--											   if (player_pixel_y - PLAYER_SIZE/2) > current_grid_y * CELL_SIZE then
						--													 next_pixel_y := player_pixel_y - PLAYER_SPEED;
						--												end if;
						--										 end if;
					WHEN "1101" => -- Down
						IF ghost_powerup = '0' THEN
							IF player_pixel_y + PLAYER_SIZE / 2 = current_grid_y * CELL_SIZE + CELL_SIZE AND mazeWalls(current_grid_y, current_grid_x)(1) = '1' THEN
								next_pixel_y := player_pixel_y;
								collision_occurred := '1';
							ELSE
								next_pixel_y := player_pixel_y + PLAYER_SPEED;
							END IF;
						ELSE
							next_pixel_y := player_pixel_y + PLAYER_SPEED;
						END IF;
						-- Check if bottom wall is 0
						--										 if mazeWalls(current_grid_y, current_grid_x)(1) = '0' then
						--											   if (player_pixel_y + PLAYER_SIZE/2) < ((current_grid_y + 1) * CELL_SIZE) then
						--												    next_pixel_y := player_pixel_y + PLAYER_SPEED;
						--											   end if;
						--										 end if;
					WHEN "1011" => -- Left
						IF ghost_powerup = '0' THEN
							IF player_pixel_x - PLAYER_SIZE / 2 = current_grid_x * CELL_SIZE AND mazeWalls(current_grid_y, current_grid_x)(0) = '1' THEN
								next_pixel_x := player_pixel_x;
								collision_occurred := '1';
							ELSE
								next_pixel_x := player_pixel_x - PLAYER_SPEED;
							END IF;
						ELSE
							next_pixel_x := player_pixel_x - PLAYER_SPEED;
						END IF;
						-- Check if left wall is 0
						--										  if mazeWalls(current_grid_y, current_grid_x)(0) = '0' then
						--											  if (player_pixel_x - PLAYER_SIZE/2) > current_grid_x * CELL_SIZE then
						--												    next_pixel_x := player_pixel_x - PLAYER_SPEED;
						--											  end if;
						--										  end if;
					WHEN "0111" => -- Right
						IF ghost_powerup = '0' THEN
							IF player_pixel_x + PLAYER_SIZE / 2 = current_grid_x * CELL_SIZE + CELL_SIZE AND mazeWalls(current_grid_y, current_grid_x)(2) = '1' THEN
								next_pixel_x := player_pixel_x;
								collision_occurred := '1';
							ELSE
								next_pixel_x := player_pixel_x + PLAYER_SPEED;
							END IF;
						ELSE
							next_pixel_x := player_pixel_x + PLAYER_SPEED;
						END IF;
						-- Check if right wall is 0
						--										  if mazeWalls(current_grid_y, current_grid_x)(2) = '0' then
						--											  if (player_pixel_x + PLAYER_SIZE/2) < ((current_grid_x + 1) * CELL_SIZE) then 
						--													next_pixel_x := player_pixel_x + PLAYER_SPEED;
						--											  end if;
						--										  end if;
					WHEN OTHERS =>
						NULL;
				END CASE;

				-- Make sure within bounds just in case
				IF next_pixel_x >= 0 AND next_pixel_x < GRID_WIDTH * CELL_SIZE THEN
					player_pixel_x <= next_pixel_x;
				END IF;
				IF next_pixel_y >= 0 AND next_pixel_y < GRID_HEIGHT * CELL_SIZE THEN
					player_pixel_y <= next_pixel_y;
				END IF;

				move_delay <= MOVE_DELAY_MAX;
				collision_pulse <= collision_occurred;

				--btn_prev <= Key;	
			ELSE
				move_delay <= move_delay - 1;
				collision_pulse <= '0';
			END IF;

			IF collision_pulse = '1' AND gameStarted = '1' AND player_lives > 0 THEN
				IF collision_cooldown = 0 THEN
					player_lives <= player_lives - 1;
					collision_cooldown <= COLLISION_COOLDOWN_MAX; -- Start cooldown
				END IF;
			ELSIF collision_cooldown > 0 THEN
				collision_cooldown <= collision_cooldown - 1;
			END IF;

			IF countdownVal = 0 OR (current_grid_x = END_X AND current_grid_y = END_Y) OR player_lives = 0 THEN
				game_over <= '1';
			END IF;

			IF (gameStarted = '0') THEN
				-- If ANY key is pressed that wasn't pressed before,
				-- we consider that as "start the game"
				IF (Key /= "1111") THEN
					gameStarted <= '1';
				END IF;
			END IF;

			IF ghost_powerup = '1' THEN
				IF ghost_second_delay = 0 THEN
					ghost_timer_count <= ghost_timer_count - 1;
					ghost_second_delay <= 24_000_000;
					IF ghost_timer_count = 0 THEN
						ghost_powerup <= '0';
					END IF;
				ELSE
					ghost_second_delay <= ghost_second_delay - 1;
				END IF;
			END IF;

			IF gameStarted = '1' THEN
				IF second_delay = 0 THEN
					-- Decrement the countdown once every 1 second
					IF countdownVal > 0 THEN
						countdownVal <= countdownVal - 1;
					END IF;
					second_delay <= 24_000_000; -- reload ~1 second
				ELSE
					second_delay <= second_delay - 1;
				END IF;
			END IF;

			-- Check powerup collisions
			IF gameStarted = '1' THEN
				current_grid_x := player_pixel_x / CELL_SIZE;
				current_grid_y := player_pixel_y / CELL_SIZE;

				-- Ghost powerup collision
				IF (current_grid_x = ghost_x) AND (current_grid_y = ghost_y) AND (ghost_active = '1') THEN
					ghost_active <= '0';
					ghost_powerup <= '1';
					ghost_timer_count <= 5;
					ghost_second_delay <= 24_000_000;
				END IF;

				-- Shrink powerup collision
				IF (current_grid_x = shrink_x) AND (current_grid_y = shrink_y) AND (shrink_active = '1') THEN
					shrink_active <= '0';
					shrink_powerup <= '1';
				END IF;

				-- Collision detection
				IF (current_grid_x = speed_x) AND (current_grid_y = speed_y) AND (speed_active = '1') THEN
					speed_active <= '0';
					speed_powerup <= '1';
				END IF;

				-- Movement speed modification
				IF speed_powerup = '1' THEN
					MOVE_DELAY_MAX <= 250_000; -- Double speed
				ELSE
					MOVE_DELAY_MAX <= 500_000; -- Normal speed
				END IF;

				IF (current_grid_x = mapchange_x) AND (current_grid_y = mapchange_y) AND (mapchange_active = '1') THEN
					mapchange_active <= '0';
					regenerate_req <= '1';
				ELSE
					regenerate_req <= '0';
				END IF;
			END IF;

			mux_counter <= mux_counter + 1;
			digit_select <= STD_LOGIC_VECTOR(mux_counter(15 DOWNTO 14));

			CASE digit_select IS
				WHEN "00" =>
					outseg <= "0111";
					IF gameStarted = '0' THEN
						sevensegments <= decode_seg(1);
					ELSE
						sevensegments <= decode_seg(countdownVal MOD 10);
					END IF;
				WHEN "01" =>
					outseg <= "1011";
					IF gameStarted = '0' THEN
						sevensegments <= decode_seg(4);
					ELSE
						sevensegments <= decode_seg((countdownVal / 10) MOD 10);
					END IF;
				WHEN "10" =>
					outseg <= "1101";
					IF gameStarted = '0' THEN
						sevensegments <= decode_seg(2);
					ELSE
						sevensegments <= decode_seg(0);
					END IF;
				WHEN "11" =>
					outseg <= "1110";
					IF gameStarted = '0' THEN
						sevensegments <= decode_seg(2);
					ELSE
						IF ghost_powerup = '1' THEN
							sevensegments <= decode_seg(ghost_timer_count);
						ELSE
							sevensegments <= decode_seg(0);
						END IF;
					END IF;
				WHEN OTHERS =>
					outseg <= "1111";
					sevensegments <= "11111111";
			END CASE;

		END IF;
	END PROCESS;

	color_logic : PROCESS (pixel_x, pixel_y, player_pixel_x, player_pixel_y, mazeWalls,
		ghost_x, ghost_y, shrink_x, shrink_y, speed_x, speed_y,
		mapchange_x, mapchange_y, ghost_active, shrink_active,
		speed_active, mapchange_active, shrink_powerup)

		VARIABLE main_player_size : INTEGER := PLAYER_SIZE;
		VARIABLE grid_x, grid_y : INTEGER;
		VARIABLE local_x, local_y : INTEGER;
		VARIABLE walls : STD_LOGIC_VECTOR(3 DOWNTO 0);
	BEGIN
		-- Default color
		color_output <= "001111";

		IF (pixel_x < GRID_WIDTH * CELL_SIZE) AND (pixel_y < GRID_HEIGHT * CELL_SIZE) THEN
			grid_x := pixel_x / CELL_SIZE;
			grid_y := pixel_y / CELL_SIZE;

			local_x := pixel_x MOD CELL_SIZE;
			local_y := pixel_y MOD CELL_SIZE;

			walls := mazeWalls(grid_y, grid_x);

			-- Check top wall
			IF (walls(3) = '1') AND (local_y = 0) THEN
				color_output <= "111111"; -- white
			END IF;

			-- Check right wall
			IF (walls(2) = '1') AND (local_x = CELL_SIZE - 1) THEN
				color_output <= "111111";
			END IF;

			-- Check bottom wall
			IF (walls(1) = '1') AND (local_y = CELL_SIZE - 1) THEN
				color_output <= "111111";
			END IF;

			-- Check left wall
			IF (walls(0) = '1') AND (local_x = 0) THEN
				color_output <= "111111";
			END IF;
			IF shrink_powerup = '1' THEN
				main_player_size := PLAYER_SIZE / 2;
			ELSE
				main_player_size := PLAYER_SIZE;
			END IF;

			-- Draw the player in red
			IF (pixel_x >= player_pixel_x - main_player_size/2) AND
				(pixel_x < player_pixel_x + main_player_size/2) AND
				(pixel_y >= player_pixel_y - main_player_size/2) AND
				(pixel_y < player_pixel_y + main_player_size/2) THEN
				color_output <= "000000"; -- red
			END IF;

			-- draw the end point 
			IF (grid_x = END_X) AND (grid_y = END_Y) THEN
				IF (local_x >= (CELL_SIZE - PLAYER_SIZE)/2) AND
					(local_x < (CELL_SIZE + PLAYER_SIZE)/2) AND
					(local_y >= (CELL_SIZE - PLAYER_SIZE)/2) AND
					(local_y < (CELL_SIZE + PLAYER_SIZE)/2) THEN
					color_output <= "001100"; -- green
				END IF;
			END IF;

			-- Calculate symbol coordinates if in power-up cell
			IF (grid_x = ghost_x AND grid_y = ghost_y AND ghost_active = '1') OR
				(grid_x = shrink_x AND grid_y = shrink_y AND shrink_active = '1') OR
				(grid_x = speed_x AND grid_y = speed_y AND speed_active = '1') OR
				(grid_x = mapchange_x AND grid_y = mapchange_y AND mapchange_active = '1') THEN

				-- Get relative position within symbol area
				local_x := pixel_x MOD CELL_SIZE;
				local_y := pixel_y MOD CELL_SIZE;

				IF local_x >= SYMBOL_OFFSET AND local_x < SYMBOL_OFFSET + SYMBOL_SIZE AND
					local_y >= SYMBOL_OFFSET AND local_y < SYMBOL_OFFSET + SYMBOL_SIZE THEN

					-- Calculate symbol grid coordinates
					local_x := local_x - SYMBOL_OFFSET;
					local_y := local_y - SYMBOL_OFFSET;

					-- Check symbol pattern based on power-up type
					IF grid_x = ghost_x AND grid_y = ghost_y THEN
						IF GHOST_SYMBOL(local_y)(local_x) = '1' THEN
							color_output <= "111000"; -- orange
						END IF;
					ELSIF grid_x = shrink_x AND grid_y = shrink_y THEN
						IF SHRINK_SYMBOL(local_y)(local_x) = '1' THEN
							color_output <= "110011"; -- Magenta
						END IF;
					ELSIF grid_x = speed_x AND grid_y = speed_y THEN
						IF SPEED_SYMBOL(local_y)(local_x) = '1' THEN
							color_output <= "111100"; -- Yellow
						END IF;
					ELSIF grid_x = mapchange_x AND grid_y = mapchange_y THEN
						IF MAPCHANGE_SYMBOL(local_y)(local_x) = '1' THEN
							color_output <= "000011"; -- Blue
						END IF;
					END IF;
				END IF;
			END IF;

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
		END IF;

	END PROCESS color_logic;

	LED <= "00011111" WHEN (player_lives = 5 AND gameStarted = '1') ELSE
		"00001111" WHEN (player_lives = 4 AND gameStarted = '1') ELSE
		"00000111" WHEN (player_lives = 3 AND gameStarted = '1') ELSE
		"00000011" WHEN (player_lives = 2 AND gameStarted = '1') ELSE
		"00000001" WHEN (player_lives = 1 AND gameStarted = '1') ELSE
		"00000000";
END Behavioral;