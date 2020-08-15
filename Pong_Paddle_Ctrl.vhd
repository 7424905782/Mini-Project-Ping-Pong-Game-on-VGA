library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
library work;
use work.Pong_Pkg.all;
 
entity Pong_Paddle_Ctrl is
  port (
    clk : in std_logic;  -- 25MHz Clock
     X_Pos :in integer; -- X Position of Paddle in VGA

    i_VGA_Cols : in std_logic_vector(9 downto 0);  --VGA Inputs
    i_VGA_Rows : in std_logic_vector(9 downto 0);
    
    i_Paddle_size : in integer; 

    i_Paddle_Up : in std_logic;  -- Inputs to move paddle up and down
    i_Paddle_Dn : in std_logic;
 
    o_Draw_Paddle : out std_logic;  -- Ouutput to VGA
    o_Paddle_Y    : out std_logic_vector(9 downto 0)  -- Output to #Pong_Top# for Win-Lose logic
    );
end entity Pong_Paddle_Ctrl;
 
architecture rtl of Pong_Paddle_Ctrl is
 

  signal col : integer;  --To use VGA Inputs as integers for easy comparison
  signal row : integer;
 
  signal ctr_en : std_logic; -- Enable for counting for paddle movement
 
  signal ctr : integer;

  signal Y_Pos : integer := 0;
  signal draw_Paddle : std_logic := '0';
   
begin
 
  col <= to_integer(unsigned(i_VGA_Cols));
  row <= to_integer(unsigned(i_VGA_Rows));  
 
  -- Only allow paddles to move if only one button is pushed.
  ctr_en <= i_Paddle_Up xor i_Paddle_Dn;
 
  movement : process (clk) is
  begin
    if clk = '1' and clk'event then
 
      if ctr_en = '1' then  -- count only when button is pushed and held
        if ctr = c_Paddle_Speed then  --When the frequency dividing factor is reached, reset counter
          ctr <= 0;
        else
          ctr <= ctr + 1;
        end if;
      else
        ctr <= 0;
      end if;
 
	if(ctr = c_Paddle_Speed) then  -- Move only when counter is at limit
		if (i_Paddle_Up = '1') then
			if Y_Pos /= 0 then
			  	Y_Pos <= Y_Pos - 1;
			end if;

		elsif (i_Paddle_Dn = '1') then
			if Y_Pos /= c_Game_Height-i_Paddle_Size-1 then
			  	Y_Pos <= Y_Pos + 1;
			end if;
         
      		end if;
	end if;
    end if;
  end process movement;
 
   
--Gives output to draw paddle when row, col pair is within the bounds of the Paddle
  draw : process (clk) is
  begin
    if clk = '1' and clk'event then
      if (col >= X_Pos and
          col <= X_Pos + c_Paddle_Width and
          row >= Y_Pos and
          row <= Y_Pos + i_Paddle_Size) then
          draw_Paddle <= '1';
      else
       	  draw_Paddle <= '0';
      end if;
    end if;
  end process draw;
 
  -- Assign output for next higher module to use
  o_Draw_Paddle <= draw_Paddle;
  o_Paddle_Y    <= std_logic_vector(to_unsigned(Y_Pos, o_Paddle_Y'length));
   
end architecture rtl;