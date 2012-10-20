--Amitoj Sandhu 78677093
--Cary Wong ???????

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;

entity lab4_test is
port(     CLOCK_50 : in std_logic;
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
    component vga_adapter                ---- Component from the Verilog file: vga_adapter.v
        generic(RESOLUTION: string);
        port (    resetn : in std_logic;
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
    signal colour : std_logic_vector(2 downto 0) := "000";
    signal plot : std_logic;
    
	 signal clock : std_logic;
	 type state is (disp_A, disp_B, del_A, del_B);
	 
	 signal ENABLE : std_logic;
	 
begin
    resetn <= KEY(3);
	 plot <= '1';
    vga_u0 : vga_adapter 
    generic map(RESOLUTION => "160x120")        ---- Sets the resolution of display (as per vga_adapter.v description)
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
-----------
-----------  Your code goes here
    process (ENABLE)
    variable counter : integer := 0;
	 variable present_state : state := disp_A;
	 variable x1 : integer := 79;
    variable y1 : integer := 59;
	 variable dx1 : integer := 1;
	 variable dy1 : integer := 1;
	 variable x2 : integer := 9;
    variable y2 : integer := 9;
	 variable dx2 : integer := 1;
	 variable dy2 : integer := 1;
	 variable x1_tmp, y1_tmp, x2_tmp, y2_tmp : integer;
	 	 
    begin
	 if (ENABLE = '1') then
		case present_state is
			when disp_A =>
					colour <= "011";
					
					x1_tmp := x1;
					x1 := x1 + dx1;
					y1_tmp := y1;
					y1 := y1 + dy1;
					
					if ((x1 >= 160) or (x1 <= 0)) then
						x1 := x1 - dx1;
						dx1 := -dx1;
						x1_tmp := x1;
						x1 := x1 + dx1;
					end if;
					if ((y1 >= 120) or (y1 <= 0)) then
						y1 := y1-dy1;
						dy1 := -dy1;
						y1_tmp := y1;
						y1 := y1 + dy1;
					end if;
					
					counter := 0;
					x <= conv_std_logic_vector(x1,8);
					y <= conv_std_logic_vector(y1,7);
					present_state := disp_B;			
				
			when disp_B =>
					colour <= "100";
					x2_tmp := x2;
					x2 := x2 + dx2;
					y2_tmp := y2;
					y2 := y2 + dy2;
					
					if ((x2 >= 160) or (x2 <= 0)) then
						x2 := x2 - dx2;
						dx2 := -dx2;
						x2_tmp := x2;
						x2 := x2 + dx2;
					end if;
					
					if ((y2 >= 120) or (y2 <= 0)) then
						y2 := y2 - dy2;
						dy2 := -dy2;
						y2_tmp := y2;
						y2 := y2 + dy2;
					end if;
					
					counter := 0;
					x <= conv_std_logic_vector(x2,8);
					y <= conv_std_logic_vector(y2,7);
					ENABLE <= '0';
					present_state:= del_A;
			
			when del_A =>
				colour <= "000";
				x <= conv_std_logic_vector(x1_tmp,8);
				y <= conv_std_logic_vector(y1_tmp,7);
				present_state := del_B;
			
			when del_B =>
				colour <= "000";
				x <= conv_std_logic_vector(x2_tmp,8);
				y <= conv_std_logic_vector(y2_tmp,7);
				present_state := disp_A;
			end case;
			end if;
    end process;
	 
	 process (CLOCK_50)
		variable count : integer := 0;
		begin
		if (CLOCK_50'event and CLOCK_50 = '1') then
			count := count + 1;
			end if;
		if (count = 2000000) then
			count := 0;
			ENABLE <= '1';
			end if;
			end process;
end rtl;