library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
library work;
use work.Pong_Pkg.all;
 
entity Pong_Ball_Ctrl is
  port (
    clk           : in  std_logic; -- 25MHz clock
    running   : in  std_logic;  -- input specifying whether game is running
    i_VGA_Cols : in  std_logic_vector(9 downto 0);  --VGA input signals
    i_VGA_Rows : in  std_logic_vector(9 downto 0);
    --
    o_Draw_Ball     : out std_logic;  -- VGA output
    o_Ball_X        : out std_logic_vector(9 downto 0);  -- output for higher module logic
    o_Ball_Y        : out std_logic_vector(9 downto 0)
    );
end entity Pong_Ball_Ctrl;
 
architecture rtl of Pong_Ball_Ctrl is
  signal col : integer := 0;  -- integer forms of input for easy comparison
  signal row : integer := 0;
  signal speed : integer := c_Ball_Speed;  --to determine after how many cycles of clock will ball move once
  signal ctr : integer := 0;
   
  -- X and Y location (Col, Row) for Pong Ball, also Previous Locations
  signal xpos      : integer := 0;
  signal ypos      : integer := 0;
  signal xpos_prev : integer := 0;
  signal ypos_prev : integer := 0;
  
  
  signal sreset : std_logic := '0';  -- for resettng speed to default value
 
  signal draw : std_logic := '0';
   
begin
 
  col <= to_integer(unsigned(i_VGA_Cols));
  row <= to_integer(unsigned(i_VGA_Rows));  
 
     
  movement : process (clk) is
  begin
    if rising_edge(clk) then
          if(sreset = '1') then
              speed <= c_Ball_Speed;  -- speed reset
          end if;
          if running = '0' then  -- initialize positions of ball and moving direction
                xpos      <= c_Game_Width/2;
                ypos      <= c_Game_Height/2;
                xpos_prev <= c_Game_Width/2 + 1; 
                ypos_prev <= c_Game_Height/2 - 1;
                sreset <= '1';
          else
                sreset <= '0'; --if running, dont reset speed
                if ctr = speed then  -- similar to paddle control
                  ctr <= 0;
                else
                  ctr <= ctr + 1;
                end if;
                if ctr = speed then
                       -- x movement logic
                      -- Store Previous Location to keep track of ball movement
                      xpos_prev <= xpos;
                       
                      -- If ball is moving to the right, keep it moving right, but check
                      -- that it's not at the wall (in which case it bounces back)
                      if xpos_prev < xpos then
                        if xpos = c_Game_Width-20 then
                            if(speed > 80000) then
                                speed <= speed - 10000;
                            end if;
                            xpos <= xpos - 1;
                        else
                          xpos <= xpos + 1;
                        end if;
             
                      -- Ball is moving left, keep it moving left, check for wall impact
                      elsif xpos_prev > xpos then
                        if xpos = 10 then
                          if(speed > 80000) then   -- change speed on paddle impact
                              speed <= speed - 10000;
                          end if;
                          xpos <= xpos + 1;
                        else
                          xpos <= xpos - 1;
                        end if;
                      end if;
                  ypos_prev <= ypos;
                  if ypos_prev < ypos then
                    if ypos = c_Game_Height-20 then
                      ypos <= ypos - 1;
                    else
                      ypos <= ypos + 1;
                    end if;
                  elsif ypos_prev > ypos then
                    if ypos = 0 then
                      ypos <= ypos + 1;
                    else
                      ypos <= ypos - 1;
                end if;
              end if;
            end if;
          end if;                     
    end if;
  end process movement;
 
 
  -- Logic for drawing ball within bounds
  drawing : process (clk) is
  begin
    if rising_edge(clk) then
      if (col >= xpos and col <= xpos + c_Paddle_Width and row >= ypos and row <= ypos + c_Paddle_Width) then
        draw <= '1';
      else
        draw <= '0';
      end if;
    end if;
  end process drawing;
 
  o_Draw_Ball <= draw;
  o_Ball_X    <= std_logic_vector(to_unsigned(xpos, o_Ball_X'length));
  o_Ball_Y    <= std_logic_vector(to_unsigned(ypos, o_Ball_Y'length));
   
   
end architecture rtl;
