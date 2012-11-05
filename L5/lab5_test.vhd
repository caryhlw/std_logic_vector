library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity lab5_test is
port(	 	CLOCK_50 : in std_logic;
		KEY : in std_logic_vector(3 downto 0);
		SW  : in std_logic_vector(17 downto 0);
		VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0); -- The outs go to VGA controller
		VGA_HS : out std_logic;
		VGA_VS : out std_logic;
		VGA_BLANK : out std_logic;
		VGA_SYNC : out std_logic;
		VGA_CLK  : out std_logic);
end lab5_test;

architecture rtl of lab5_test is
--Component declarations here:	
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
	
	Component line is
	PORT(
		signal x0, x1 : in std_logic_vector(7 downto 0);
		signal y0, y1 : in std_logic_vector(6 downto 0);
		signal x_out  : out std_logic_vector(7 downto 0);
		signal y_out  : out std_logic_vector(6 downto 0)
	);
	end component;
--End of component declarations.

--Signal declarations here:
	signal resetn : std_logic;
	signal x : std_logic_vector(7 downto 0);
	signal y : std_logic_vector(6 downto 0);
	signal colour : std_logic_vector(2 downto 0);
	signal plot : std_logic;
	--Declared signals to map to line here:		
	signal x0, x1 : std_logic_vector(7 downto 0);
	signal y0, y1 : std_logic_vector(6 downto 0);
	signal x_out  : std_logic_vector(7 downto 0);
	signal y_out  : std_logic_vector(6 downto 0);
--End of signal declarations

begin
	resetn <= key(3);
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

				
-----------  Your code goes here

--Port map for Line:	
	L1: line port map(x0 => x0, 
							y0 => y0,
							x1 => x1,
							y1 => y1,
							x_out => x_out,
							y_out => y_out);

	process(plot)
	begin
		if (plot'event and plot = '1') then
			x <= x_out;
			y <= y_out;
		end if;
	end process;


end rtl;
