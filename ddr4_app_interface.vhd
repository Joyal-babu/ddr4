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
    Port ( clock               : in  STD_LOGIC;                                           -- ddr4_ip_ui_clock
           reset               : in  STD_LOGIC;                                           -- ddr4_ip_ui_reset
           init_calib_complete : in  STD_LOGIC;
           app_rdy             : in  STD_LOGIC;
           app_wdf_rdy         : in  STD_LOGIC;
           rd_data_valid       : in  STD_LOGIC;
           rd_data             : in  STD_LOGIC_VECTOR(511 downto 0);
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


    COMPONENT ila_0                                                          
    port(                                                                
        clk     : IN STD_LOGIC;
        probe0  : IN STD_LOGIC;                      
        probe1  : IN STD_LOGIC;                     
        probe2  : IN STD_LOGIC;                                           
        probe3  : IN STD_LOGIC;                       
        probe4  : IN STD_LOGIC;                       
        probe5  : IN STD_LOGIC;                                           
        probe6  : IN STD_LOGIC;
        probe7  : IN STD_LOGIC_VECTOR(27 DOWNTO 0);
        probe8  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        probe9  : IN STD_LOGIC_VECTOR(511 DOWNTO 0);    
        probe10 : IN STD_LOGIC_VECTOR(511 DOWNTO 0); 
        probe11 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        probe12 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        probe13 : IN STD_LOGIC_VECTOR(27 DOWNTO 0);                                         
        probe14 : IN STD_LOGIC_VECTOR(27 DOWNTO 0)                                                                 
        );                                                               
END COMPONENT;

    constant num_writes : integer := 2048;
    constant num_reads  : integer := 2048;
    
    signal wr_count    : std_logic_vector(15 downto 0);
    signal rd_count    : std_logic_vector(15 downto 0);
    signal begin_addr  : std_logic_vector(27 downto 0) := (others => '0');
    
    signal app_addr_i, wr_addr, rd_addr : std_logic_vector(27 downto 0);
    signal app_cmd_i                    : std_logic_vector(2 downto 0);
    signal app_en_i                     : std_logic;
    signal app_wdf_data_i               : std_logic_vector(511 downto 0);
    signal wr_data                      : std_logic_vector(31 downto 0);
    signal app_wdf_end_i                : std_logic;
    signal app_wdf_mask_i               : std_logic_vector(63 downto 0);
    signal app_wdf_wren_i               : std_logic; 
    signal ip_enabled                   : std_logic;  
         
         
    type ddr_sm is (st1_reset, st2_data_write, st3_data_read, st4_hold_state  );
    signal state, next_state : ddr_sm;
    

begin

    ip_enabled <= app_rdy and app_wdf_rdy;

    SYNC_PROC_ddr_sm : process (clock, reset)
    begin
        if(rising_edge(clock)) then
            if(reset = '1') then
                state <= st1_reset;
                app_addr     <= (others => '0');
                app_cmd      <= (others => '0');
                app_en       <= '0';
                app_wdf_data <= (others => '0');
                app_wdf_end  <= '0';
                app_wdf_mask <= (others => '0');
                app_wdf_wren <= '0';
            else    
                state        <= next_state;
                app_addr     <= app_addr_i;      
                app_cmd      <= app_cmd_i;     
                app_en       <= app_en_i;      
                app_wdf_data <= app_wdf_data_i;
                app_wdf_end  <= app_wdf_end_i; 
                app_wdf_mask <= app_wdf_mask_i;
                app_wdf_wren <= app_wdf_wren_i;
            end if;    
        end if;
    end process;
    
    app_wdf_mask_i <= (others => '0');
    
    NEXT_STATE_DECODE_ddr_sm: process (state, init_calib_complete, wr_count, rd_count)
    begin
      next_state <= state;  
      case (state) is
      
         when st1_reset =>
            if (init_calib_complete = '1') then
               next_state <= st2_data_write;
            else
               next_state <= st1_reset; 
            end if;
    
         when st2_data_write =>
            if (wr_count < (num_writes-1)) then
                next_state <= st2_data_write;
            elsif (wr_count = (num_writes-1)) then
                next_state <= st3_data_read;
            end if;         
                       
         when st3_data_read =>
            if (rd_count < (num_reads-1)) then
                next_state <= st3_data_read;
            elsif (rd_count = (num_reads-1)) then
                next_state <= st4_hold_state;
            else 
                next_state <= st1_reset; 
            end if; 
            
        when st4_hold_state =>                             
            next_state <= st1_reset;
                
        when others =>
            next_state <= st1_reset;
            
      end case;
    end process;
    
    OUTPUT_DECODE_ddr_sm: process (state,app_rdy, ip_enabled, wr_addr, rd_addr, wr_data)
    begin
        case (state) is    
            when  st1_reset => 
                app_addr_i     <= (others => '0');
                app_wdf_data_i <= (others => '0');
                app_cmd_i      <= (others => '0');
                app_en_i       <= '0';  
                app_wdf_end_i  <= '0';     
                app_wdf_wren_i <= '0';
               
            when  st2_data_write =>
                app_cmd_i      <= "000";
                app_addr_i     <= wr_addr;
                app_wdf_data_i <= wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data ;

                app_wdf_wren_i <= ip_enabled;
                app_en_i       <= ip_enabled;
                app_wdf_end_i  <= ip_enabled;

                   
            when  st3_data_read =>
                app_cmd_i      <= "001";
                app_addr_i     <= rd_addr;
                app_wdf_data_i <= (others => '0');
                app_wdf_end_i  <= '0';
                app_wdf_wren_i <= '0';
                app_en_i       <= app_rdy;
                
            when  st4_hold_state => 
                app_en_i       <= '0';
                app_cmd_i      <= "000";
                app_addr_i     <= (others => '0');
                app_wdf_data_i <= (others => '0');
                app_wdf_end_i  <= '0';
                app_wdf_wren_i <= '0';
                
        end case;
    end process;
    
    process(clock, reset)
    begin
        if(rising_edge(clock)) then
            if(reset = '1') then
                wr_addr        <= (others => '0');
                wr_data        <= (others => '0');
                wr_count       <= (others => '0');
            else
                if(state = st1_reset) then
                    wr_count       <= (others => '0');
                    wr_addr        <= (others => '0');
                    wr_data        <= (others => '0'); 
                elsif(state = st2_data_write and ip_enabled = '1') then
                    wr_addr        <= wr_addr  + "1000";
                    wr_data        <= wr_data  + '1' ;        --x"00080008000800080008000800080008000800080008000800080008000800080008000800080008000800080008000800080008000800080008000800080008";
                    wr_count       <= wr_count + '1';
                else
                    wr_addr        <= wr_addr;
                    wr_data        <= wr_data;
                    wr_count       <= wr_count;
                end if;
            end if;
        end if;
    end process;   
    

    
    process(clock, reset)
    begin
        if(rising_edge(clock)) then
            if(reset = '1') then
                rd_addr        <= (others => '0');
                rd_count       <= (others => '0');
            else
                if(state = st1_reset) then
                    rd_addr        <= (others => '0');
                    rd_count       <= (others => '0');
                elsif(state = st3_data_read and app_rdy = '1') then
                    rd_addr  <= rd_addr + "1000";
                    rd_count <= rd_count + '1'; 
                else
                    rd_addr  <= rd_addr;
                    rd_count <= rd_count;
                end if;          
            end if;
       end if;
    end process; 
     
    ILA : ila_0
    port map(
        clk    => clock,
        probe0 => init_calib_complete,
        probe1 => app_rdy,
        probe2 => app_wdf_rdy,
        probe3 => ip_enabled,
        probe4 => app_en_i,
        probe5 => app_wdf_wren_i,
        probe6 => rd_data_valid,
        probe7 => app_addr_i,
        probe8 => app_cmd_i,
        probe9 => app_wdf_data_i,
        probe10 => rd_data,
        probe11 => wr_count,
        probe12 => rd_count,
        probe13 => wr_addr,
        probe14 => rd_addr
        );

end Behavioral;
