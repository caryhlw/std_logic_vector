--Amitoj Sandhu 78677093
--Cary Wong 19096072

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
--use ieee.numeric_std.all;

entity lab4_test is
port(	 CLOCK_50 : in std_logic;
		KEY : in std_logic_vector(3 downto 0);
		SW  : in std_logic_vector(17 downto 0);
		VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);
		VGA_HS : out std_logic;
		VGA_VS : out std_logic;
		VGA_BLANK : out std_logic;
		VGA_SYNC : out std_logic;
		VGA_CLK  : out std_logic);
end lab4_test;

architecture rtl of lab4_test is
	component vga_adapter				---- Component from the Verilog file: vga_adapter.v
		generic(RESOLUTION: string);
		port (	resetn : in std_logic;
				 clock : in std_logic;
				colour : in std_logic_vector(2 downto 0);
				     x : in std_logic_vector(7 downto 0);
				     y : in std_logic_vector(6 downto 0);
				  plot : in std_logic;
				VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);
				VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK : out std_logic);
	end component;

	signal resetn : std_logic;
	signal x : std_logic_vector(7 downto 0);
	signal y : std_logic_vector(6 downto 0);
	signal colour : std_logic_vector(2 downto 0);
	signal plot : std_logic;
	
	signal enable : std_logic;
	
begin
	resetn <= KEY(3);
	x <= SW(7 downto 0);
	y <= SW(14 downto 8);
	colour <= SW(17 downto 15);
	plot <= not KEY(0);
	vga_u0 : vga_adapter 
	generic map(RESOLUTION => "160x120")		---- Sets the resolution of display (as per vga_adapter.v description)
	port map(resetn => resetn, 
				clock => CLOCK_50, 
				colour => colour, 
				x => x, 
				y => y, 
				plot => plot, 
				VGA_R => VGA_R, 
				VGA_G => VGA_G, 
				VGA_B => VGA_B, 
				VGA_HS => VGA_HS, 
				VGA_VS => VGA_VS, 
				VGA_BLANK => VGA_BLANK, 
				VGA_SYNC => VGA_SYNC, 
				VGA_CLK => VGA_CLK);

  process (CLOCK_50)
    variable counter : integer;
    begin
      if (CLOCK_50'event and CLOCK_50 = '1') then
        counter := counter + 1;
        if (counter = 2000000) then
          enable <= '1';
        end if;
      end if;
    end process;
    
  process (CLOCK_50)
    variable A_x : integer;
    variable A_y : integer;
    
    variable B_x : integer;
    variable B_y : integer;
    
    variable temp_A_x : integer;
    variable temp_A_y : integer;
    
    variable temp_B_x : integer;
    variable temp_B_y : integer;
    
    variable A_dx : integer;
    variable A_dy : integer;
    
    variable B_dx : integer;
    variable B_dy : integer;
    
    type state is (drawA, drawB, delA, delB);
    variable present_state : state := drawA;
    begin
      case present_state is
      when drawA =>
        if (enable = '1') then
          temp_A_x := A_x;
          temp_A_y := A_y;
          if ((A_x >= 160) or (A_x <= 0)) then
            A_dx := -A_dx;
          end if;
          if ((A_y >= 120) or (A_y <= 0)) then
            A_dy := -A_dy;
          end if;
          A_x := A_x + A_dx;
          A_y := A_y + A_dy;
          x <= conv_std_logic_vector(A_x, 8);
          y <= conv_std_logic_vector(A_y, 7);
          present_state := drawB;
          enable <= '0';
        end if;
      when drawB =>
        temp_B_x := B_x;
        temp_B_y := B_y;
        if ((B_x >= 160) or (B_y <= 0)) then
          B_dx := -B_dx;
        end if;
        if ((B_y >= 120) or (B_y <= 0)) then
          B_dy := -B_dy;
        end if;
        A_x := A_x + A_dx;
        A_y := A_y + A_dy;
        x <= conv_std_logic_vector(B_x, 8);
        y <= conv_std_logic_vector(B_y, 7);
        present_state := delA;
      when delA =>
        colour <= "000";
        x <= conv_std_logic_vector(temp_A_x, 8);
        y <= conv_std_logic_vector(temp_A_y, 7);
        present_state := delB;
      when delB =>
        colour <= "000";
        x <= conv_std_logic_vector(temp_B_x, 8);
        y <= conv_std_logic_vector(temp_B_y, 7);
        present_state := drawA;
      end case;
    end process;
    
end rtl;