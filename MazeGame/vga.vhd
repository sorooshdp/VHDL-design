LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL; -- Use numeric_std

ENTITY vga IS
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
END vga;

ARCHITECTURE Behavioral OF vga IS
  -- VGA Definitions
  CONSTANT HDisplayArea : INTEGER := 640; -- horizontal display area
  CONSTANT HLimit : INTEGER := 800; -- maximum horizontal amount (limit)
  CONSTANT HFrontPorch : INTEGER := 16; -- h. front porch
  CONSTANT HBackPorch : INTEGER := 48; -- h. back porch
  CONSTANT HSyncWidth : INTEGER := 96; -- h. pulse width
  CONSTANT VDisplayArea : INTEGER := 480; -- vertical display area
  CONSTANT VLimit : INTEGER := 525; -- maximum vertical amount (limit)
  CONSTANT VFrontPorch : INTEGER := 10; -- v. front porch
  CONSTANT VBackPorch : INTEGER := 33; -- v. back porch
  CONSTANT VSyncWidth : INTEGER := 2; -- v. pulse width      

  SIGNAL HBlank, VBlank, Blank : STD_LOGIC := '0';

  SIGNAL CurrentHPos : unsigned(10 DOWNTO 0) := (OTHERS => '0'); -- goes to 800
  SIGNAL CurrentVPos : unsigned(10 DOWNTO 0) := (OTHERS => '0'); -- goes to 525

BEGIN
  VGAPosition : PROCESS (CLK_24MHz, RESET)
  BEGIN
    IF RESET = '1' THEN
      CurrentHPos <= (OTHERS => '0');
      CurrentVPos <= (OTHERS => '0');
    ELSIF rising_edge(CLK_24MHz) THEN
      IF CurrentHPos < HLimit - 1 THEN
        CurrentHPos <= CurrentHPos + 1;
      ELSE
        IF CurrentVPos < VLimit - 1 THEN
          CurrentVPos <= CurrentVPos + 1;
        ELSE
          CurrentVPos <= (OTHERS => '0'); -- reset Vertical Position
        END IF;
        CurrentHPos <= (OTHERS => '0'); -- reset Horizontal Position
      END IF;
    END IF;
  END PROCESS VGAPosition;

  -- Timing definition for HSync, VSync and Blank (http://tinyvga.com/vga-timing/640x480@60Hz)
  HS <= '0' WHEN to_integer(CurrentHPos) < HSyncWidth ELSE
    '1';
  VS <= '0' WHEN to_integer(CurrentVPos) < VSyncWidth ELSE
    '1';

  HBlank <= '0' WHEN (CurrentHPos >= HSyncWidth + HFrontPorch) AND
    (CurrentHPos < HSyncWidth + HFrontPorch + HDisplayArea) ELSE
    '1';

  VBlank <= '0' WHEN (CurrentVPos >= VSyncWidth + VFrontPorch) AND
    (CurrentVPos < VSyncWidth + VFrontPorch + VDisplayArea) ELSE
    '1';

  Blank <= '1' WHEN (HBlank = '1') OR (VBlank = '1') ELSE
    '0';

  ScanlineX <= STD_LOGIC_VECTOR(CurrentHPos - (HSyncWidth + HFrontPorch)) WHEN (Blank = '0') ELSE
    (OTHERS => '0');
  ScanlineY <= STD_LOGIC_VECTOR(CurrentVPos - (VSyncWidth + VFrontPorch)) WHEN (Blank = '0') ELSE
    (OTHERS => '0');

  RED <= ColorIN(5 DOWNTO 4) WHEN (Blank = '0') ELSE
    "00";
  GREEN <= ColorIN(3 DOWNTO 2) WHEN (Blank = '0') ELSE
    "00";
  BLUE <= ColorIN(1 DOWNTO 0) WHEN (Blank = '0') ELSE
    "00";

END Behavioral;