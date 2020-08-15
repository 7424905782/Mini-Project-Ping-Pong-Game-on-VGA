library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
library work;
use work.Pong_Pkg.all;
use work.VGA_Sync_Porch;
 
entity Pong_Top is
  generic (
    g_Video_Width : integer;
    g_Total_Cols  : integer;
    g_Total_Rows  : integer;
    g_Active_Cols : integer;
    g_Active_Rows : integer
    );
  port (
    clk     : in std_logic;
    i_HSync   : in std_logic;
    i_VSync   : in std_logic;
 
    -- Game Start Button
    start : in std_logic;
     
    -- Player 1 & Player 2 Controls (Controls Paddles)
    P1_up : in std_logic;
    P1_down : in std_logic;
    P1_diff : in std_logic_vector(1 downto 0);
    P2_up : in std_logic;
    P2_down : in std_logic;
    P2_diff : in std_logic_vector(1 downto 0);
    
    o_seven_seg : out std_logic_vector(6 downto 0);  --outputs for score display
    o_an : out std_logic_vector(3 downto 0);
     
    o_HSync     : out std_logic; -- VGA outputs
    o_VSync     : out std_logic;
    o_Red_Video : out std_logic_vector(g_Video_Width-1 downto 0);
    o_Blu_Video : out std_logic_vector(g_Video_Width-1 downto 0);
    o_Grn_Video : out std_logic_vector(g_Video_Width-1 downto 0)
    );
end entity Pong_Top;
 
architecture rtl of Pong_Top is
 
  type state_type is (s_Idle, s_Running, s_P1_Wins, s_P2_Wins, s_Cleanup);
  signal state : state_type := s_Idle;
   
  signal w_HSync : std_logic;   -- VGA Temporaries
  signal w_VSync : std_logic;
   
  -- Make these unsigned counters (always positive)
  signal cols : std_logic_vector(9 downto 0);
  signal rows : std_logic_vector(9 downto 0);

 
  signal P1_size : integer := 0; -- for size inputs
  signal P2_size : integer := 0;
  signal sclk : std_logic := '0';  -- clock for seven segment
  signal an : std_logic_vector(3 downto 0);  -- anode signals
  signal seven_seg : std_logic_vector(6 downto 0) := "0000000";  -- cathode signals
  
  signal Fix : std_logic := '0';  -- for fixing size when game is running
  signal P1_Fix : std_logic_vector (2 downto 0);
  signal P2_Fix : std_logic_vector (2 downto 0);
  
  signal draw_P1 : std_logic;  -- for drawing of all instances
  signal draw_P2 : std_logic;
  signal Y_P1    : std_logic_vector(9 downto 0);
  signal Y_P2    : std_logic_vector(9 downto 0);
  signal draw_ball      : std_logic;
  signal X_ball         : std_logic_vector(9 downto 0);
  signal Y_ball         : std_logic_vector(9 downto 0);
  signal draw_Red       : std_logic;
  signal draw_Blue       : std_logic;
  signal draw_Green     : std_logic;
   
  signal running : std_logic := '0'; 
  
  signal sreset : std_logic := '0'; -- reset speed in ball ctrl
 
  signal Y_P1_Top : unsigned(9 downto 0);  -- for expression simplification
  signal Y_P1_Bot : unsigned(9 downto 0);
  signal Y_P2_Top : unsigned(9 downto 0);
  signal Y_P2_Bot : unsigned(9 downto 0);
 
  signal P1_Score : integer range 0 to c_Score_Limit := 0;  -- score temporary variables
  signal P2_Score : integer range 0 to c_Score_Limit := 0;
   
begin
  
  P1_Fix <= P1_diff & Fix; -- logic for paddle sizes
  P2_Fix <= P2_diff & Fix;
  
  with P1_Fix select P1_size <=
        c_Paddle_Height when "000",
        c_Paddle_Height - 20 when "010",
        c_Paddle_Height - 40 when "110",
        c_Paddle_Height - 60 when "100",
        P1_size when others;
        
  with P2_Fix select P2_size <=
                c_Paddle_Height when "000",
                c_Paddle_Height - 20 when "010",
                c_Paddle_Height - 40 when "110",
                c_Paddle_Height - 60 when "100",
                P2_size when others;
   

	 process(clk)   -- clock for seven segment
  variable ctr : integer := 0;
  begin 
    if(clk = '1' and clk'event) then
        if(ctr = 12500) then 
            ctr := 0;
            sclk <= not sclk;
        else
            ctr := ctr + 1;
        end if;   
    end if;
  end process;
 
   --Seven Segment logic
      process(sclk, P1_Score, P2_Score)
      begin
          if(sclk = '1') then
                an(0) <= '0';
                an(3) <= '1';
                if( P1_Score = 1 or P1_Score = 4) then seven_seg(0) <= '1'; else seven_seg(0) <= '0'; end if;
                if( P1_Score = 5 or P1_Score = 6 or P1_Score = 11 or P1_Score = 12 or P1_Score = 15 or P1_Score = 14) then seven_seg(1) <= '1';else seven_seg(1) <= '0'; end if;
                if( P1_Score = 2) then seven_seg(2) <= '1';else seven_seg(2) <= '0'; end if;
                if( P1_Score = 1 or P1_Score = 4 or P1_Score = 7) then seven_seg(3) <= '1';else seven_seg(3) <= '0'; end if;
                if( P1_Score = 1 or P1_Score = 3 or P1_Score = 4 or P1_Score = 5 or P1_Score = 7 or P1_Score = 9) then seven_seg(4) <= '1';else seven_seg(4) <= '0'; end if;
                if( P1_Score = 1 or P1_Score = 2 or P1_Score = 3 or P1_Score = 7) then seven_seg(5) <= '1';else seven_seg(5) <= '0'; end if;
                if( P1_Score = 1 or P1_Score = 7 or P1_Score = 0) then seven_seg(6) <= '1';else seven_seg(6) <= '0'; end if;                                                        
          else
                    an(0) <= '1';
                    an(3) <= '0';
                    if( P2_Score = 1 or P2_Score = 4) then seven_seg(0) <= '1'; else seven_seg(0) <= '0'; end if;
                    if( P2_Score = 5 or P2_Score = 6 or P2_Score = 11 or P2_Score = 12 or P1_Score = 15 or P1_Score = 14) then seven_seg(1) <= '1';else seven_seg(1) <= '0'; end if;
                    if( P2_Score = 2) then seven_seg(2) <= '1';else seven_seg(2) <= '0'; end if;
                    if( P2_Score = 1 or P2_Score = 4 or P2_Score = 7) then seven_seg(3) <= '1';else seven_seg(3) <= '0'; end if;
                    if( P2_Score = 1 or P2_Score = 3 or P2_Score = 4 or P2_Score = 5 or P2_Score = 7 or P2_Score = 9) then seven_seg(4) <= '1';else seven_seg(4) <= '0'; end if;
                    if( P2_Score = 1 or P2_Score = 2 or P2_Score = 3 or P2_Score = 7) then seven_seg(5) <= '1';else seven_seg(5) <= '0'; end if;
                    if( P2_Score = 1 or P2_Score = 7 or P2_Score = 0) then seven_seg(6) <= '1';else seven_seg(6) <= '0'; end if;
          end if;
      end process;
    an(1) <= '1';
    an(2) <= '1';
    o_seven_seg <= seven_seg;
    o_an <= an;

  Sync_To_Count_inst : entity work.Sync_To_Count
    generic map (
      g_Total_Cols => g_Total_Cols,
      g_Total_Rows => g_Total_Rows
      )
    port map (
      i_Clk       => clk,
      i_HSync     => i_HSync,
      i_VSync     => i_VSync,
      o_HSync     => w_HSync,
      o_VSync     => w_VSync,
      o_Col_Count => cols,
      o_Row_Count => rows
      );
  p_Reg_Syncs : process (clk) is
  begin
    if rising_edge(clk) then
      o_VSync <= w_VSync;
      o_HSync <= w_HSync;
    end if;
  end process p_Reg_Syncs; 
 
 
   
  -- Instantiation of Paddle Control + Draw for Player 1
  Paddle_Ctrl_P1_inst : entity work.Pong_Paddle_Ctrl
    port map (
      clk           => clk,
      X_Pos => c_Paddle_Col_Location_P1,
      i_VGA_Cols => cols,
      i_VGA_Rows => rows,
      i_Paddle_Up     => P1_up,
      i_Paddle_Dn     => P1_down,
      i_Paddle_size  => P1_size,
      o_Draw_Paddle   => draw_P1,
      o_Paddle_Y      => Y_P1
      );
 
   
  -- Instantiation of Paddle Control + Draw for Player 2
  Paddle_Ctrl_P2_inst : entity work.Pong_Paddle_Ctrl
    port map (
      clk           => clk,
      X_Pos => c_Paddle_Col_Location_P2,
      i_VGA_Cols => cols,
      i_VGA_Rows => rows,
      i_Paddle_Up     => P2_up,
      i_Paddle_Dn     => P2_down,
      i_Paddle_size   => P2_size,
      o_Draw_Paddle   => draw_P2,
      o_Paddle_Y      => Y_P2
      );
 
   
  -- Instantiation of Ball Control + Draw 
  Pong_Ball_Ctrl_inst : entity work.Pong_Ball_Ctrl
    port map (
      clk           => clk,
      running   => running,
      i_VGA_Cols => cols,
      i_VGA_Rows => rows,
      o_Draw_Ball     => draw_ball,
      o_Ball_X        => X_ball,
      o_Ball_Y        => Y_ball
      );
 
  -- Create Intermediary signals for P1 and P2 Paddle Top and Bottom positions
  Y_P1_Bot <= unsigned(Y_P1);
  Y_P1_Top <= Y_P1_Bot + to_unsigned(P1_size, Y_P1_Bot'length);
 
  Y_P2_Bot <= unsigned(Y_P2);
  Y_P2_Top <= Y_P2_Bot + to_unsigned(P2_size, Y_P2_Bot'length);
 
   
   
  -- Create a state machine to control the state of play
  p_SM_Main : process (clk) is
  begin
    if rising_edge(clk) then
       
      case state is
 
        -- Stay in this state until Game Start button is hit
        when s_Idle =>
            if(P1_Score = 0 and P2_Score = 0) then
                Fix <= '0';
            end if;
          if start = '1' then
            state <= s_Running;
            sreset <= '0';
          end if;
 
           
        -- Stay in this state until either player misses the ball
        -- Can only occur when the Ball is at 10 or c_Game_Width-20
        when s_Running =>
            Fix <= '1';
          -- Player 1's Side:
          if X_ball = std_logic_vector(to_unsigned(0, X_ball'length) + 10) then
            if (unsigned(Y_ball) < Y_P1_Bot - 10 or
                unsigned(Y_ball) > Y_P1_Top) then
              state <= s_P2_Wins;
              sreset <= '1';
            end if;
 
          -- Player 2's Side:
          elsif X_ball = std_logic_vector(to_unsigned(c_Game_Width-20, X_ball'length)) then
            if (unsigned(Y_ball) < Y_P2_Bot - 10 or
                unsigned(Y_ball) > Y_P2_Top) then
              state <= s_P1_Wins;
              sreset <= '1';
            end if;
             
          end if;
 
 
        when s_P1_Wins =>
          if P1_Score = c_Score_Limit then
            P1_Score <= 0;
            P2_Score <= 0;
          else
            P1_Score <= P1_Score + 1;
          end if;
          state  <= s_Cleanup;
 
           
        when s_P2_Wins =>
          if P2_Score = c_Score_Limit then
            P2_Score <= 0;
            P1_Score <= 0;
          else
            P2_Score <= P2_Score + 1;
          end if;
          state <= s_Cleanup;
 
           
        when s_Cleanup =>
          state <= s_Idle;
 
           
        when others =>
          state <= s_Idle;
           
      end case;
    end if;
  end process p_SM_Main;
 
  -- Conditional Assignment of Game Active based on State Machine
  running <= '1' when state = s_Running else '0';
 
--  draw_Red <= not (draw_P1 or draw_ball);
--  draw_Blue <= not (draw_P2 or draw_ball);
--  draw_Green <= not (draw_P1 or  draw_ball or draw_P2);
   
  -- Assign Color outputs, only two colors, White or Black
  o_Red_Video <= (others => '1') when draw_P1 = '1' else (others => '0');
  o_Blu_Video <= (others => '1') when draw_P2 = '1' else (others => '0');
  o_Grn_Video <= (others => '1') when draw_ball = '1' else (others => '0');
   
   
end architecture rtl;
