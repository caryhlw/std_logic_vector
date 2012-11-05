library ieee;
use ieee.std_logic_1164.all;

ENTITY line is
  PORT(
    signal x0, x1 : in std_logic_vector(7 downto 0)
    signal y0, y1 : in std_logic_vector(6 downto 0)
    signal x_out  : out std_logic_vector(7 downto 0)
    signal y_out  : out std_logic_vector(6 downto 0)
  );
END;

architecture behavioral of line is
  type state_types is (START, DRAW, FINISH);
begin
  process(x0, y0)
    variable dx : std_logic_vector(7 downto 0);
    variable dy : std_logic_vector(6 downto 0);
    variable sx : integer;
    variable sy : integer;
    variable state : state_types;
    begin
      dx := abs(x1 - x0);
      dy := abs(y1 - y0);
      
      if (x0 < x1) then
        sx := 1;
      else
        sx := -1;
      end if;
      
      if (y0 < y1) then
        sy := 1;
      else
        sy := -1;
      end if;
end behavioural;