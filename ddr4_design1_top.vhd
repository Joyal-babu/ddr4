----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.07.2024 10:18:50
-- Design Name: 
-- Module Name: ddr4_design1_top - Behavioral
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

entity ddr4_design1_top is
    Port ( sys_clk_p : in STD_LOGIC;
           sys_clk_n : in STD_LOGIC;
           sys_rst : in STD_LOGIC);
end ddr4_design1_top;

architecture Behavioral of ddr4_design1_top is

    component ddr4_app_interface is
    Port ( clock               : in STD_LOGIC;                                           -- ddr4_ip_ui_clock
           reset               : in STD_LOGIC;                                           -- ddr4_ip_ui_reset
           init_calib_complete : in STD_LOGIC;
           app_rdy             : in STD_LOGIC;
           app_wdf_rdy         : in STD_LOGIC;
           app_addr            : out STD_LOGIC_VECTOR(27 DOWNTO 0);
           app_cmd             : out STD_LOGIC_VECTOR(2 DOWNTO 0);
           app_en              : out STD_LOGIC;
           app_wdf_data        : out STD_LOGIC_VECTOR(511 DOWNTO 0);
           app_wdf_end         : out STD_LOGIC;
           app_wdf_mask        : out STD_LOGIC_VECTOR(63 DOWNTO 0);
           app_wdf_wren        : out STD_LOGIC
           );
    end component;
    
    component ddr4_mig_ip is
    Port ( sys_clk_p                  : in STD_LOGIC;
           sys_clk_n                  : in STD_LOGIC;
           sys_rst                    : in STD_LOGIC;
           ddr4_app_addr              : in STD_LOGIC_VECTOR(27 DOWNTO 0);
           ddr4_app_cmd               : in STD_LOGIC_VECTOR(2 DOWNTO 0);
           ddr4_app_en                : in STD_LOGIC;
           ddr4_app_hi_pri            : in STD_LOGIC;
           ddr4_app_wdf_data          : in STD_LOGIC_VECTOR(511 DOWNTO 0);
           ddr4_app_wdf_mask          : in STD_LOGIC_VECTOR(63 DOWNTO 0);
           ddr4_app_wdf_wren          : in STD_LOGIC;
           ddr4_app_wdf_end           : in STD_LOGIC;
           
           ddr4_init_calib_complete   : out STD_LOGIC;
           ddr4_ui_clk                : out STD_LOGIC;
           ddr4_ui_clk_sync_rst       : out STD_LOGIC;
           ddr4_app_rdy               : out STD_LOGIC;  
           ddr4_app_wdf_rdy           : out STD_LOGIC   
           );       
    end component;
    
    constant active_low : std_logic := '0';
    
    signal ddr4_ui_clock, ddr4_ui_reset : std_logic;
    signal ddr4_init_calib_complete, ddr4_app_rdy, ddr4_app_wdf_rdy, app_en, app_wdf_end, app_wdf_wren : std_logic;
    signal app_addr      : std_logic_vector(27 downto 0);
    signal app_cmd       : std_logic_vector(2 downto 0);
    signal app_wdf_data  : std_logic_vector(511 downto 0);
    signal app_wdf_mask  : std_logic_vector(63 downto 0);
    
begin

    ddr4_mig_ip_inst1 : ddr4_mig_ip
        port map (
            sys_clk_p                => sys_clk_p, 
            sys_clk_n                => sys_clk_n, 
            sys_rst                  => sys_rst, 
            ddr4_app_addr            => app_addr, 
            ddr4_app_cmd             => app_cmd, 
            ddr4_app_en              => app_en, 
            ddr4_app_hi_pri          => active_low, 
            ddr4_app_wdf_data        => app_wdf_data, 
            ddr4_app_wdf_mask        => app_wdf_mask, 
            ddr4_app_wdf_wren        => app_wdf_wren, 
            ddr4_app_wdf_end         => app_wdf_end, 
                                      
            ddr4_init_calib_complete => ddr4_init_calib_complete, 
            ddr4_ui_clk              => ddr4_ui_clock, 
            ddr4_ui_clk_sync_rst     => ddr4_ui_reset, 
            ddr4_app_rdy             => ddr4_app_rdy, 
            ddr4_app_wdf_rdy         => ddr4_app_wdf_rdy
        
        );
    
    ddr4_app_interface_inst1 : ddr4_app_interface
        port map (
            clock               => ddr4_ui_clock,
            reset               => ddr4_ui_reset,
            init_calib_complete => ddr4_init_calib_complete,
            app_rdy             => ddr4_app_rdy,
            app_wdf_rdy         => ddr4_app_wdf_rdy,
            
            app_addr            => app_addr,
            app_cmd             => app_cmd,
            app_en              => app_en,
            app_wdf_data        => app_wdf_data,
            app_wdf_end         => app_wdf_end,
            app_wdf_mask        => app_wdf_mask,
            app_wdf_wren        => app_wdf_wren
        );


end Behavioral;
