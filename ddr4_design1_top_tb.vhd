----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.07.2024 16:33:36
-- Design Name: 
-- Module Name: ddr4_design1_top_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ddr4_design1_top_tb is
--  Port ( );
end ddr4_design1_top_tb;

architecture Behavioral of ddr4_design1_top_tb is

    component ddr4_design1_top is
    Port ( sys_clk_p : in STD_LOGIC;
           sys_clk_n : in STD_LOGIC;
           sys_rst   : in STD_LOGIC);
    end component;
    
    signal sys_clk_p, sys_clk_n, sys_rst : std_logic := '0';

begin

    process_reset : process
    begin
        sys_rst <= '1'; wait for 500 ns;
        sys_rst <= '0'; wait;
    end process;

    sys_clk_process : process
    begin
        sys_clk_p <= '1'; sys_clk_n <= '0'; wait for 1666 ps;
        sys_clk_p <= '0'; sys_clk_n <= '1'; wait for 1666 ps;
    end process;
    
    DUT : ddr4_design1_top
        port map(
            sys_clk_p => sys_clk_p,
            sys_clk_n => sys_clk_n,
            sys_rst   => sys_rst
        );

end Behavioral;
