----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.07.2024 11:11:32
-- Design Name: 
-- Module Name: ddr4_app_interface - Behavioral
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

entity ddr4_app_interface is
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
end ddr4_app_interface;

architecture Behavioral of ddr4_app_interface is

    constant num_writes : integer := 10;
    constant num_reads  : integer := 10;
    
    signal wr_count    : std_logic_vector(7 downto 0);
    signal rd_wait_cnt : std_logic_vector(7 downto 0);
    signal rd_count    : std_logic_vector(7 downto 0);
    signal begin_addr  : std_logic_vector(27 downto 0) := (others => '0');
    
    signal app_addr_i     : std_logic_vector(27 downto 0);
    signal app_cmd_i      : std_logic_vector(2 downto 0);
    signal app_en_i       : std_logic;
    signal app_wdf_data_i : std_logic_vector(511 downto 0);
    signal app_wdf_end_i  : std_logic;
    signal app_wdf_mask_i : std_logic_vector(63 downto 0);
    signal app_wdf_wren_i  : std_logic;   
         
         
    type ddr_sm is (st1_reset, st2_check_app_rdy_wr, st3_data_write, st4_read_wait, st5_check_app_rdy_rd, st6_data_read, st7_hold_state );
    signal state, next_state : ddr_sm;
    

begin

    SYNC_PROC_ddr_sm : process (clock, reset)
    begin
        if(reset = '1') then
            state <= st1_reset;
        elsif(rising_edge(clock)) then
            state        <= next_state;
            app_addr     <= app_addr_i;      
            app_cmd      <= app_cmd_i;     
            app_en       <= app_en_i;      
            app_wdf_data <= app_wdf_data_i;
            app_wdf_end  <= app_wdf_end_i; 
            app_wdf_mask <= app_wdf_mask_i;
            app_wdf_wren <= app_wdf_wren_i;
        end if;
    end process;
    
    
    NEXT_STATE_DECODE_ddr_sm: process (state, init_calib_complete, app_rdy, app_wdf_rdy, wr_count, rd_count, rd_wait_cnt )
    begin
      next_state <= state;  
      case (state) is
      
         when st1_reset =>
            if (init_calib_complete = '1') then
               next_state <= st2_check_app_rdy_wr;
            else
               next_state <= st1_reset; 
            end if;
            
         when st2_check_app_rdy_wr =>
            if (app_rdy = '1' and app_wdf_rdy = '1') then
                next_state <= st3_data_write;
            else
                next_state <= st2_check_app_rdy_wr; 
            end if;
    
         when st3_data_write =>
            if (wr_count < (num_writes-1)) then
                next_state <= st2_check_app_rdy_wr;
            elsif (wr_count = (num_writes-1)) then
                next_state <= st4_read_wait;
            else 
                next_state <= st1_reset; 
            end if;         
            
         when st4_read_wait =>
            if (rd_wait_cnt < x"32") then
                next_state <= st4_read_wait; 
            else
                next_state <= st5_check_app_rdy_rd; 
            end if;
            
         when st5_check_app_rdy_rd =>
            if (app_rdy = '1') then
                next_state <= st6_data_read;
            else
                next_state <= st5_check_app_rdy_rd; 
            end if;
            
         when st6_data_read =>
            if (rd_count < (num_reads-1)) then
                next_state <= st5_check_app_rdy_rd;
            elsif (rd_count = (num_reads-1)) then
                next_state <= st7_hold_state;
            else 
                next_state <= st1_reset; 
            end if; 
            
        when st7_hold_state =>                             
            next_state <= st7_hold_state;
                
        when others =>
            next_state <= st1_reset;
            
      end case;
    end process;
    
    OUTPUT_DECODE_ddr_sm: process (state)
    begin
        case (state) is    
            when  st1_reset => 
                app_addr_i     <= begin_addr;
                app_cmd_i      <= (others => '0');
                app_en_i       <= '0';
                app_wdf_data_i <= (others => '0');  
                app_wdf_end_i  <= '0';
                app_wdf_mask_i <= (others => '0');     
                app_wdf_wren_i <= '0';
                wr_count       <= (others => '0');
                rd_count       <= (others => '0');
                rd_wait_cnt    <= (others => '0');
           
            when  st2_check_app_rdy_wr =>      
                app_cmd_i      <= "000";
                
               
            when  st3_data_write =>
                app_addr_i     <= app_addr_i + "1000";
                app_cmd_i      <= "000";
                app_en_i       <= '1';
                app_wdf_wren_i <= '1';
                app_wdf_end_i  <= '1';
                app_wdf_data_i <=  app_wdf_data_i + x"00080008000800080008000800080008000800080008000800080008000800080008000800080008000800080008000800080008000800080008000800080008";                                                                                                                                               -- app_wdf_data_i + x"4A4A4A4A4A";
                wr_count       <= wr_count + '1';
                 
            when  st4_read_wait =>
                app_addr_i     <= begin_addr;
                app_wdf_data_i <= (others => '0');
                wr_count       <= (others => '0');
                app_en_i       <= '0';
                app_wdf_wren_i <= '0';
                app_wdf_end_i  <= '0';
                rd_wait_cnt    <= rd_wait_cnt + '1';
                
            when  st5_check_app_rdy_rd =>
                app_cmd_i      <= "001";
                rd_wait_cnt    <= (others => '0');
                
            when  st6_data_read =>
                app_addr_i     <= app_addr_i + "1000";
                app_en_i       <= '1';
                rd_count       <= rd_count + '1';
                
            when  st7_hold_state => 
                app_en_i       <= '1';
                app_addr_i     <= begin_addr;
                rd_count       <= (others => '0');
                
        end case;
    end process;


end Behavioral;
