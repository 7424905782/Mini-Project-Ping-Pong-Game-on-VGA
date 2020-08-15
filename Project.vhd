library ieee;
use ieee.std_logic_1164.all;
 
entity Project10_Pong_Top is
  port (
    -- Main Clock (100 MHz)
    i_Clk         : in std_logic;

    i_Start : in  std_logic;
 
    -- Push Buttons
    i_Switch_1 : in std_logic;
    i_Switch_2 : in std_logic;
    i_Switch_3 : in std_logic;
    i_Switch_4 : in std_logic;
    
    
    i_P1_diff : in std_logic_vector(1 downto 0);
    i_P2_diff : in std_logic_vector(1 downto 0);
     
    -- VGA
    o_VGA_HSync : out std_logic;
    o_VGA_VSync : out std_logic;
    o_VGA_Red : out std_logic_vector(3 downto 0);
    o_VGA_Grn : out std_logic_vector(3 downto 0);
    o_VGA_Blu : out std_logic_vector(3 downto 0);
    
    o_seven_seg : out std_logic_vector(6 downto 0);
    o_an : out std_logic_vector(3 downto 0)
    );
end entity Project10_Pong_Top;
 
architecture RTL of Project10_Pong_Top is
 signal clk : std_logic := '0';
 
  signal w_RX_DV : std_logic;
   
  -- VGA Constants to set Frame Size
  constant c_VIDEO_WIDTH : integer := 4;
  constant c_TOTAL_COLS  : integer := 800;
  constant c_TOTAL_ROWS  : integer := 525;
  constant c_ACTIVE_COLS : integer := 640;
  constant c_ACTIVE_ROWS : integer := 480;
   
  -- Common VGA Signals
  signal w_HSync_VGA       : std_logic;
  signal w_VSync_VGA       : std_logic;
  signal w_Red_Video_Porch : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Grn_Video_Porch : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Blu_Video_Porch : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
 
  signal w_Switch_1 : std_logic;
  signal w_Switch_2 : std_logic;
  signal w_Switch_3 : std_logic;
  signal w_Switch_4 : std_logic;
   
  -- Pong Signals
  signal w_HSync_Pong     : std_logic;
  signal w_VSync_Pong     : std_logic;
  signal w_Red_Video_Pong : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Grn_Video_Pong : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Blu_Video_Pong : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);  
   
begin
 
  w_RX_DV <= i_Start;
    
    process(i_Clk)  -- clock to get 25 MHz
        variable ctr : integer := 0;
    begin
        if(i_Clk = '1' and i_Clk'event) then
            ctr := ctr +1;
            if(ctr = 2) then
                ctr := 0;
                clk <= not clk;
            end if;
        end if;
    end process;
 
  VGA_Sync_Pulses_inst : entity work.VGA_Sync_Pulses
    generic map (
      g_TOTAL_COLS  => c_TOTAL_COLS,
      g_TOTAL_ROWS  => c_TOTAL_ROWS,
      g_ACTIVE_COLS => c_ACTIVE_COLS,
      g_ACTIVE_ROWS => c_ACTIVE_ROWS
      )
    port map (
      i_Clk       => clk,
      o_HSync     => w_HSync_VGA,
      o_VSync     => w_VSync_VGA,
      o_Col_Count => open,
      o_Row_Count => open
      );
 
  Debounce_Switch_1: entity work.Debounce_Switch
    port map (
      clk    => clk,
      i_Switch => i_Switch_1,
      o_Switch => w_Switch_1);
   
  Debounce_Switch_2: entity work.Debounce_Switch
    port map (
      clk    => clk,
      i_Switch => i_Switch_2,
      o_Switch => w_Switch_2);
   
  Debounce_Switch_3: entity work.Debounce_Switch
    port map (
      clk    => clk,
      i_Switch => i_Switch_3,
      o_Switch => w_Switch_3);
   
  Debounce_Switch_4: entity work.Debounce_Switch
    port map (
      clk    => clk,
      i_Switch => i_Switch_4,
      o_Switch => w_Switch_4);
   
  Pong_Top_1: entity work.Pong_Top
    generic map (
      g_Video_Width => c_VIDEO_WIDTH,
      g_Total_Cols  => c_TOTAL_COLS, 
      g_Total_Rows  => c_TOTAL_ROWS, 
      g_Active_Cols => c_ACTIVE_COLS,
      g_Active_Rows => c_ACTIVE_ROWS) 
    port map (
      clk          => clk,
      i_HSync        => w_HSync_VGA,
      i_VSync        => w_VSync_VGA,
      start   => w_RX_DV,
      P1_up => w_Switch_1,
      P1_down => w_Switch_2,
      P2_up => w_Switch_3,
      P2_down => w_Switch_4,
      P1_diff => i_P1_diff,
      P2_diff => i_P2_diff,
      o_seven_seg => o_seven_seg,
      o_an => o_an,
      o_HSync        => w_HSync_Pong,
      o_VSync        => w_VSync_Pong,
      o_Red_Video    => w_Red_Video_Pong,
      o_Blu_Video    => w_Blu_Video_Pong,
      o_Grn_Video    => w_Grn_Video_Pong);
 
       
  VGA_Sync_Porch_Inst : entity work.VGA_Sync_Porch
    generic map (
      g_Video_Width => c_VIDEO_WIDTH,
      g_TOTAL_COLS  => c_TOTAL_COLS,
      g_TOTAL_ROWS  => c_TOTAL_ROWS,
      g_ACTIVE_COLS => c_ACTIVE_COLS,
      g_ACTIVE_ROWS => c_ACTIVE_ROWS 
      )
    port map (
      i_Clk       => clk,
      i_HSync     => w_HSync_Pong,
      i_VSync     => w_VSync_Pong,
      i_Red_Video => w_Red_Video_Pong,
      i_Grn_Video => w_Blu_Video_Pong,
      i_Blu_Video => w_Grn_Video_Pong,
      --
      o_HSync     => o_VGA_HSync,
      o_VSync     => o_VGA_VSync,
      o_Red_Video => w_Red_Video_Porch,
      o_Grn_Video => w_Blu_Video_Porch,
      o_Blu_Video => w_Grn_Video_Porch
      );
       
  o_VGA_Red <= w_Red_Video_Porch;
   
  o_VGA_Grn <= w_Grn_Video_Porch;
 
  o_VGA_Blu <= w_Blu_Video_Porch;
   
end architecture RTL;
