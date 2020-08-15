library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
package Pong_Pkg is
   
  -- Set the Width and Height of the Game Board
  constant c_Game_Width    : integer := 640;
  constant c_Game_Height   : integer := 480;
 
  -- Set the number of points to play to
  constant c_Score_Limit : integer := 9;
   
  -- Set the Height and width (in board game units) of the paddle.
  constant c_Paddle_Height : integer := 120;
  constant c_Paddle_Width : integer := 10;
 
  -- Set the Speed of the paddle movement.  In this case, the paddle will move
  -- one board game unit every 4 milliseconds that the button is held down.
  constant c_Paddle_Speed : integer := 100000;
 
  -- Set the Speed of the ball movement.  In this case, the ball will move
  -- one board game unit every 2.66 milliseconds that the button is held down.   
  constant c_Ball_Speed : integer  := 150000;
   
  -- Sets Column index to draw Player 1 & Player 2 Paddles.
  constant c_Paddle_Col_Location_P1 : integer := 0;
  constant c_Paddle_Col_Location_P2 : integer := c_Game_Width-10; 
   
end package Pong_Pkg;  
