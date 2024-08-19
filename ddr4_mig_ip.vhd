----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.07.2024 10:20:54
-- Design Name: 
-- Module Name: ddr4_mig_ip - Behavioral
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
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ddr4_mig_ip is
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
           ddr4_app_wdf_rdy           : out STD_LOGIC;
           
           c0_ddr4_adr                : out   STD_LOGIC_VECTOR(16 DOWNTO 0);    
           c0_ddr4_ba                 : out   STD_LOGIC_VECTOR(1 DOWNTO 0);     
           c0_ddr4_cke                : out   STD_LOGIC_VECTOR(0 DOWNTO 0);     
           c0_ddr4_cs_n               : out   STD_LOGIC_VECTOR(0 DOWNTO 0);    
           c0_ddr4_dm_dbi_n           : inout STD_LOGIC_VECTOR(7 DOWNTO 0);
           c0_ddr4_dq                 : inout STD_LOGIC_VECTOR(63 DOWNTO 0);     
           c0_ddr4_dqs_c              : inout STD_LOGIC_VECTOR(7 DOWNTO 0);   
           c0_ddr4_dqs_t              : inout STD_LOGIC_VECTOR(7 DOWNTO 0);   
           c0_ddr4_odt                : out   STD_LOGIC_VECTOR(0 DOWNTO 0);     
           c0_ddr4_bg                 : out   STD_LOGIC_VECTOR(0 DOWNTO 0);      
           c0_ddr4_reset_n            : out   STD_LOGIC;                    
           c0_ddr4_act_n              : out   STD_LOGIC;                      
           c0_ddr4_ck_c               : out   STD_LOGIC_VECTOR(0 DOWNTO 0);    
           c0_ddr4_ck_t               : out   STD_LOGIC_VECTOR(0 DOWNTO 0);
           rd_data                    : out   std_logic_vector(511 downto 0);
           rd_data_valid              : out   std_logic;
           rd_data_end                : out   std_logic
           );       
end ddr4_mig_ip;

architecture Behavioral of ddr4_mig_ip is

    COMPONENT ddr4_0
        PORT (
            c0_init_calib_complete      : OUT   STD_LOGIC;
            dbg_clk                     : OUT   STD_LOGIC;
            c0_sys_clk_p                : IN    STD_LOGIC;
            c0_sys_clk_n                : IN    STD_LOGIC;
            dbg_bus                     : OUT   STD_LOGIC_VECTOR(511 DOWNTO 0);
            c0_ddr4_adr                 : OUT   STD_LOGIC_VECTOR(16 DOWNTO 0);
            c0_ddr4_ba                  : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);
            c0_ddr4_cke                 : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
            c0_ddr4_cs_n                : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
            c0_ddr4_dm_dbi_n            : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            c0_ddr4_dq                  : INOUT STD_LOGIC_VECTOR(63 DOWNTO 0);
            c0_ddr4_dqs_c               : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            c0_ddr4_dqs_t               : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            c0_ddr4_odt                 : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
            c0_ddr4_bg                  : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
            c0_ddr4_reset_n             : OUT   STD_LOGIC;
            c0_ddr4_act_n               : OUT   STD_LOGIC;
            c0_ddr4_ck_c                : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
            c0_ddr4_ck_t                : OUT   STD_LOGIC_VECTOR(0 DOWNTO 0);
            c0_ddr4_ui_clk              : OUT   STD_LOGIC;
            c0_ddr4_ui_clk_sync_rst     : OUT   STD_LOGIC;
            c0_ddr4_app_en              : IN    STD_LOGIC;
            c0_ddr4_app_hi_pri          : IN    STD_LOGIC;
            c0_ddr4_app_wdf_end         : IN    STD_LOGIC;
            c0_ddr4_app_wdf_wren        : IN    STD_LOGIC;
            c0_ddr4_app_rd_data_end     : OUT   STD_LOGIC;
            c0_ddr4_app_rd_data_valid   : OUT   STD_LOGIC;
            c0_ddr4_app_rdy             : OUT   STD_LOGIC;
            c0_ddr4_app_wdf_rdy         : OUT   STD_LOGIC;
            c0_ddr4_app_addr            : IN    STD_LOGIC_VECTOR(27 DOWNTO 0);
            c0_ddr4_app_cmd             : IN    STD_LOGIC_VECTOR(2 DOWNTO 0);
            c0_ddr4_app_wdf_data        : IN    STD_LOGIC_VECTOR(511 DOWNTO 0);
            c0_ddr4_app_wdf_mask        : IN    STD_LOGIC_VECTOR(63 DOWNTO 0);
            c0_ddr4_app_rd_data         : OUT   STD_LOGIC_VECTOR(511 DOWNTO 0);
            sys_rst                     : IN    STD_LOGIC 
        );
    END COMPONENT;
    
--      signal ddr4_reset_n, ddr4_app_rd_data_end : std_logic;
--      signal  ddr4_app_rd_data_valid            : std_logic;
--      signal  ddr4_app_rd_data                  : std_logic_vector(511 downto 0);
      
      
      
--      signal ddr4_adr      : std_logic_vector(16 downto 0);
--      signal ddr4_ba       : std_logic_vector(1 downto 0);
--      signal ddr4_cke      : std_logic_vector(0 downto 0);
--      signal ddr4_cs_n     : std_logic_vector(0 downto 0);
--      signal ddr4_dm_dbi_n : std_logic_vector(7 downto 0);
--      signal ddr4_dq       : std_logic_vector(63 downto 0);
--      signal ddr4_dqs_c    : std_logic_vector(7 downto 0);
--      signal ddr4_dqs_t    : std_logic_vector(7 downto 0);
--      signal ddr4_odt      : std_logic_vector(0 downto 0);
--      signal ddr4_bg       : std_logic_vector(0 downto 0);
--      signal ddr4_act_n    : std_logic;
--      signal ddr4_ck_c     : std_logic_vector(0 downto 0);
--      signal ddr4_ck_t     : std_logic_vector(0 downto 0);
      
    
begin

    
    ddr4_0_inst1 : ddr4_0
      PORT MAP (
        c0_init_calib_complete    => ddr4_init_calib_complete,
        dbg_clk                   => open,
        c0_sys_clk_p              => sys_clk_p,
        c0_sys_clk_n              => sys_clk_n,
        dbg_bus                   => open,
        c0_ddr4_adr               => c0_ddr4_adr,
        c0_ddr4_ba                => c0_ddr4_ba,
        c0_ddr4_cke               => c0_ddr4_cke,
        c0_ddr4_cs_n              => c0_ddr4_cs_n,
        c0_ddr4_dm_dbi_n          => c0_ddr4_dm_dbi_n,
        c0_ddr4_dq                => c0_ddr4_dq,
        c0_ddr4_dqs_c             => c0_ddr4_dqs_c,
        c0_ddr4_dqs_t             => c0_ddr4_dqs_t,
        c0_ddr4_odt               => c0_ddr4_odt,
        c0_ddr4_bg                => c0_ddr4_bg,
        c0_ddr4_reset_n           => c0_ddr4_reset_n,
        c0_ddr4_act_n             => c0_ddr4_act_n,
        c0_ddr4_ck_c              => c0_ddr4_ck_c,
        c0_ddr4_ck_t              => c0_ddr4_ck_t,
        c0_ddr4_ui_clk            => ddr4_ui_clk,
        c0_ddr4_ui_clk_sync_rst   => ddr4_ui_clk_sync_rst,
        c0_ddr4_app_en            => ddr4_app_en,
        c0_ddr4_app_hi_pri        => ddr4_app_hi_pri,
        c0_ddr4_app_wdf_end       => ddr4_app_wdf_end,
        c0_ddr4_app_wdf_wren      => ddr4_app_wdf_wren,
        c0_ddr4_app_rd_data_end   => rd_data_end,
        c0_ddr4_app_rd_data_valid => rd_data_valid,
        c0_ddr4_app_rdy           => ddr4_app_rdy,
        c0_ddr4_app_wdf_rdy       => ddr4_app_wdf_rdy,
        c0_ddr4_app_addr          => ddr4_app_addr,
        c0_ddr4_app_cmd           => ddr4_app_cmd,
        c0_ddr4_app_wdf_data      => ddr4_app_wdf_data,
        c0_ddr4_app_wdf_mask      => ddr4_app_wdf_mask,
        c0_ddr4_app_rd_data       => rd_data,
        sys_rst                   => sys_rst
      );
    
     
   
  
    
    
    
    
    
    
    
    
    
    

end Behavioral;
