library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity Debounce_Switch is
  port (
    clk    : in  std_logic;
    i_Switch : in  std_logic;
    o_Switch : out std_logic
    );
end entity Debounce_Switch;
 
architecture RTL of Debounce_Switch is
 
  -- Set for 250,000 clock ticks of 25 MHz clock (10 ms)
  constant c_DEBOUNCE_LIMIT : integer := 250000;
 
  signal ctr : integer := 0;
  signal curr : std_logic := '0';
 
begin
 
  p_Debounce : process (clk) is
  begin
    if rising_edge(clk) then
 
      -- Switch input is different than internal switch value, so an input is
      -- changing.  Increase counter until it is stable for 10 ms.
      if (i_Switch /= curr and ctr < c_DEBOUNCE_LIMIT) then
        ctr <= ctr + 1;
 
      -- End of counter reached, switch is stable, register it, reset counter
      elsif ctr = c_DEBOUNCE_LIMIT then
        curr <= i_Switch;
        ctr <= 0;
 
      -- Switches are the same state, reset the counter
      else
        ctr <= 0;
 
      end if;
    end if;
  end process p_Debounce;
 
  -- Assign internal register to output
  o_Switch <= curr;
 
end architecture RTL;
