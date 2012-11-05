--Amitoj 		XXXXXXXX
--Cary Wong		19096072
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

ENTITY line is
  PORT(
    signal x0, x1 : in std_logic_vector(7 downto 0);
    signal y0, y1 : in std_logic_vector(6 downto 0);
    signal x_out  : out std_logic_vector(7 downto 0);
    signal y_out  : out std_logic_vector(6 downto 0);
    signal COMPLETE : out std_logic		--Debugging: state indicator
  );
END;

architecture behavioural of line is
  type state_types is (DRAW, FINISH);
begin
  process(x0, y0)
    variable var_x0 : std_logic_vector(7 downto 0);
    variable var_y0 : std_logic_vector(6 downto 0);
    
    variable dx : std_logic_vector(8 downto 0);
    variable dy : std_logic_vector(7 downto 0);
    
    variable temp_dx : std_logic_vector(8 downto 0);
    variable temp_dy : std_logic_vector(7 downto 0);
    
    variable sx : integer;
    variable sy : integer;
    
    variable err  : std_logic_vector(8 downto 0);
    variable e2   : std_logic_vector(17 downto 0);
    
    variable state : state_types;
    begin
		--Point difference
      temp_dx := ('0'&x1) - ('0'&x0);
      temp_dy := ('0'&y1) - ('0'&y0);
      
      --Absolute value and type conversion
		dx := std_logic_vector(abs(signed(temp_dx)));
      dy := std_logic_vector(abs(signed(temp_dy)));
      
		--Direction determination (X)
      if (x0 < x1) then sx := 1;
      else              sx := -1;
      end if;
      
		--Direction determination (Y)
      if (y0 < y1) then sy := 1;
      else              sy := -1;
      end if;
      
      err := dx - ('0'&dy);
      
      case state is
      when DRAW =>
		COMPLETE <= '0';
        e2 := std_logic_vector(signed(err)*2);
        
		  --Figure next point (X)
        if (e2 > ("00000000" - dy)) then
          err := err - dy;
          var_x0 := x0 + sx;
        end if;
        
		  --Figure next point (Y)
        if (e2 < dx) then
          err := err + dx;
          var_y0 := y0 + sy;
        end if;
        
		  --Writing next point
        x_out <= var_x0;
        y_out <= var_y0;
        
		  --Check for completion (we've shorten the line in question to length 0)
        if ((x0 = x1) OR (y0 = y1)) then
          state := FINISH;
        end if;
        
      when FINISH =>
        COMPLETE <= '1';
      end case;
    end process;
end behavioural;
