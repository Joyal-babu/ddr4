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
        probe9  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);    
        probe10 : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
        probe11 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        probe12 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        probe13 : IN STD_LOGIC_VECTOR(27 DOWNTO 0);                                         
        probe14 : IN STD_LOGIC_VECTOR(27 DOWNTO 0);
        probe15 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        probe16 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        probe17 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        probe18 : IN STD_LOGIC_VECTOR(15 DOWNTO 0)                                                                 
        );                                                               
END COMPONENT;

    COMPONENT vio_0
    PORT (
        clk        : IN STD_LOGIC;
        probe_out0 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)  
    );
    END COMPONENT;

    constant num_writes : integer := 2048;
    constant num_reads  : integer := 2048;
--    constant wait_count : integer := 20;
--    constant hold_count : integer := 20;
    constant read_burst : integer := 64;
    
    signal wr_count          : std_logic_vector(15 downto 0);
    signal rd_count          : std_logic_vector(15 downto 0);
    signal valid_reads_total : std_logic_vector(15 downto 0);
    signal valid_reads       : std_logic_vector(15 downto 0);
    signal rd_count_total    : std_logic_vector(15 downto 0);
--    signal wait_st_cnt    : std_logic_vector(15 downto 0);
--    signal hold_st_cnt    : std_logic_vector(15 downto 0);
--    signal num_write_vio  : std_logic_vector(15 downto 0);
--    signal num_read_vio   : std_logic_vector(15 downto 0);
--    signal begin_addr     : std_logic_vector(27 downto 0) := (others => '0');
    
    signal app_addr_i, wr_addr, rd_addr : std_logic_vector(27 downto 0);
    signal app_cmd_i                    : std_logic_vector(2 downto 0);
    signal app_en_i, trig               : std_logic;
    signal app_wdf_data_i               : std_logic_vector(511 downto 0);
    signal wr_data                      : std_logic_vector(31 downto 0);
    signal app_wdf_end_i                : std_logic;
    signal app_wdf_mask_i               : std_logic_vector(63 downto 0);
    signal app_wdf_wren_i               : std_logic; 
    signal ip_enabled                   : std_logic;  
    signal app_read_trig                : std_logic;
    signal state_code                   : std_logic_vector(3 downto 0);
    signal trig_edge_1                  : std_logic;
    signal trig_edge_2                  : std_logic;
    signal trig_edge_2_not              : std_logic;
--    signal wait_cnt_en                  : std_logic;
--    signal hold_cnt_en                  : std_logic;
    signal valid_read_en                : std_logic;
    signal trig_edge                    : std_logic;
   
    type ddr_sm is (st0_reset, st1_data_write, st2_data_read, st3_valid_checks);            --st3_rd_st_wait,
    signal state, next_state : ddr_sm;
    

begin

--    process(clock) 
--    begin
--        if(rising_edge(clock)) then
--            ip_enabled <= app_rdy and app_wdf_rdy;
--        end if;
--    end process;
    
    SYNC_PROC_ddr_sm : process (clock, reset)
    begin
        if(rising_edge(clock)) then
            if(reset = '1') then
                state <= st0_reset;
            else    
                state <= next_state;
            end if;    
        end if;
    end process;
    
    app_wdf_mask_i  <= (others => '0');
    app_addr        <= app_addr_i;      
    app_cmd         <= app_cmd_i;     
    app_en          <= app_en_i;      
    app_wdf_data    <= wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data;       --app_wdf_data_i;
    app_wdf_end     <= app_wdf_end_i; 
    app_wdf_mask    <= app_wdf_mask_i;
    app_wdf_wren    <= app_wdf_wren_i;
    ip_enabled      <= app_rdy and app_wdf_rdy;
    
--    vio_inst0 : vio_0
--        PORT MAP (
--            clk           => clock,
--            probe_out0(0) => trig
--        );
    
--    process(clock,reset)
--    begin
--    if(rising_edge(clock)) then
--        if(reset ='1') then
--            trig_edge_1<='0';
--            trig_edge_2<='0';
--        else    
--            trig_edge_1 <=trig;
--            trig_edge_2 <= trig_edge_1;
--         end if;
--        end if; 
--    end process;
    
--    trig_edge_2_not     <=  not trig_edge_2;   
--    trig_edge           <=  trig_edge_1 and trig_edge_2_not;
    
    NEXT_STATE_DECODE_ddr_sm: process (state, init_calib_complete, wr_count, rd_count, valid_reads, ip_enabled, app_rdy, valid_reads_total, rd_data_valid)
    begin
      next_state <= state;  
      case (state) is
      
         when st0_reset =>
            if (init_calib_complete = '1' and ip_enabled = '1') then
               next_state <= st1_data_write;
            else
               next_state <= st0_reset; 
            end if;
    
         when st1_data_write =>
            if(ip_enabled = '1')then
                if (wr_count < (num_writes-1)) then
                    next_state <= st1_data_write;
                else
                    next_state <= st2_data_read;
                end if;             
            else
                next_state <= st1_data_write;
            end if;    
                
--                if (wr_count < (num_writes-1)) then
--                    next_state <= st2_data_write;
--                else
--                    next_state <= st4_data_read;
--                end if; 

--         when st3_rd_st_wait =>
--            if(wait_st_cnt < (wait_count-1)) then
--                next_state <= st3_rd_st_wait;
--            else
--                next_state <= st4_data_read;
--            end if;
                
         when st2_data_read =>
            if(app_rdy = '1')then            
                if(rd_count < (read_burst-1)) then
                    next_state <= st2_data_read;
                else 
                    next_state <= st3_valid_checks;
                end if;
            else
               next_state <= st2_data_read;
            end if;        
            
        when st3_valid_checks =>
            if(rd_data_valid = '1') then
                if(valid_reads_total = (num_reads - 1)) then                            
                    next_state <= st0_reset;
                elsif(valid_reads = (read_burst-1))then 
                    next_state <= st2_data_read;
                else
                   next_state <= st3_valid_checks;
                end if;   
            else
                next_state <= st3_valid_checks;                
            end if;
            
--        when st6_hold_state => 
--            if(hold_st_cnt < (hold_count-1)) then
--                next_state <= st6_hold_state;
--            else
--                next_state <= st1_reset;
--            end if;
                
        when others =>
            next_state <= st0_reset;
            
      end case;
    end process;
    
    OUTPUT_DECODE_ddr_sm: process (state, app_rdy, ip_enabled, wr_addr, rd_addr, rd_data_valid)
    begin
        case (state) is    
            when  st0_reset => 
                state_code     <= "0000";
                app_addr_i     <= (others => '0');
                --app_wdf_data_i <= (others => '0');
                app_cmd_i      <= "111";
                app_en_i       <= '0';  
                app_wdf_end_i  <= '0';     
                app_wdf_wren_i <= '0';
                app_read_trig  <= '0';
--                wait_cnt_en    <= '0';
--                hold_cnt_en    <= '0';
               
            when  st1_data_write =>
                state_code     <= "0001";
                app_cmd_i      <= "000";
                app_addr_i     <= wr_addr(24 downto 0) & "000";
                --app_wdf_data_i <= wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data & wr_data ;
                app_wdf_wren_i <= ip_enabled;
                app_en_i       <= '1';
                app_wdf_end_i  <= ip_enabled;
                app_read_trig  <= '0';
--                wait_cnt_en    <= '0';
--                hold_cnt_en    <= '0';

--            when  st2_rd_st_wait =>
--                state_code     <= "0010";
--                app_cmd_i      <= "111";
--                app_addr_i     <= (others => '0');
--                --app_wdf_data_i <= (others => '0');
--                app_wdf_end_i  <= '0';
--                app_wdf_wren_i <= '0';
--                app_en_i       <= '0';
--                app_read_trig  <= '0';
--                wait_cnt_en    <= '1';
--                hold_cnt_en    <= '0';
           
            when  st2_data_read =>
                state_code     <= "0010";
                app_cmd_i      <= "001";
                app_addr_i     <=  rd_addr(24 downto 0) & "000";
                --app_wdf_data_i <= (others => '0');
                app_wdf_end_i  <= '0';
                app_wdf_wren_i <= '0';
                app_en_i       <= app_rdy;
                app_read_trig  <= app_rdy;
--                wait_cnt_en    <= '0';
--                hold_cnt_en    <= '0';
                
            when  st3_valid_checks =>
                state_code     <= "0011"; 
                app_en_i       <= '0';
                app_cmd_i      <= "111";
                app_addr_i     <= (others => '0');
                --app_wdf_data_i <= (others => '0');
                app_wdf_end_i  <= '0';
                app_wdf_wren_i <= '0';
                app_read_trig  <= '0';
--                wait_cnt_en    <= '0';
--                hold_cnt_en    <= '0';
                
--           when  st6_hold_state =>
--                state_code     <= "0101";
--                app_cmd_i      <= "111";
--                app_addr_i     <= (others => '0');
--                --app_wdf_data_i <= (others => '0');
--                app_wdf_end_i  <= '0';
--                app_wdf_wren_i <= '0';
--                app_en_i       <= '0';
--                app_read_trig  <= '0';
--                wait_cnt_en    <= '0';
--                hold_cnt_en    <= '1';
                
        end case;
    end process;
    
    process(clock, reset)
    begin
        if(rising_edge(clock)) then
            if(reset = '1') then
                wr_addr  <= (others => '0');
                wr_data  <= (others => '0');
                wr_count <= (others => '0');
            else
                if(app_wdf_wren_i = '1')then
                    if(wr_count  < (num_writes-1)) then
                        wr_addr  <= wr_addr + 1;
                        wr_data  <= wr_data  + '1' ;        --x"00080008000800080008000800080008000800080008000800080008000800080008000800080008000800080008000800080008000800080008000800080008";
                        wr_count <= wr_count + '1';
                    else
                        wr_count <= (others => '0');
                        wr_addr  <= (others => '0');
                        wr_data  <= (others => '0');
                    end if;    
                else
                    wr_addr  <= wr_addr;
                    wr_data  <= wr_data;
                    wr_count <= wr_count;
                end if;
            end if;
        end if;
    end process;   
    

    
    process(clock, reset)
    begin
        if(rising_edge(clock)) then
            if(reset = '1') then
                rd_addr         <= (others => '0');
                rd_count_total  <= (others => '0');
                rd_count        <= (others => '0');
            else
                if(app_read_trig = '1')then
                    if(rd_count_total < (num_reads-1)) then
                        rd_addr        <= rd_addr + 1;
                        rd_count_total <= rd_count_total + '1';
                        if(rd_count < (read_burst-1)) then
                           rd_count <= rd_count + '1'; 
                        else
                           rd_count <= (others => '0'); 
                        end if;
                    else 
                        rd_addr        <= (others => '0');
                        rd_count_total <= (others => '0');
                        rd_count       <= (others => '0');               
                    end if; 
                else
                    rd_addr        <= rd_addr;
                    rd_count_total <= rd_count_total;
                    rd_count       <= rd_count;
                end if;          
            end if;
       end if;
    end process; 
    
    process(clock, reset)
    begin
        if(rising_edge(clock)) then
            if(reset = '1') then
                valid_reads_total <= (others => '0');
            else
                if(rd_data_valid = '1') then
                    if(valid_reads_total < (num_reads-1)) then
                        valid_reads_total <= valid_reads_total + '1';
                    else
                        valid_reads_total <= (others => '0');
                    end if;        
                else
                    valid_reads_total <= valid_reads_total;
                end if;
            end if;    
        end if;
    end process;
    
    process(clock, reset)
    begin
        if(rising_edge(clock)) then
            if(reset = '1') then
                valid_reads <= (others => '0');
            else
                if(rd_data_valid = '1') then
                    if(valid_reads < (read_burst-1)) then
                        valid_reads <= valid_reads + '1';
                    else
                        valid_reads <= (others => '0');
                    end if;       
                else
                    valid_reads <= valid_reads;
                end if;
            end if;    
        end if;
    end process;
    
--    process(clock, reset)
--    begin
--        if(rising_edge(clock)) then
--            if(reset = '1') then
--                wait_st_cnt <= (others => '0');
--            else
--                if(wait_cnt_en = '1') then
--                    wait_st_cnt <= wait_st_cnt + '1';
--                else
--                    wait_st_cnt <= (others => '0'); 
--                end if;
--            end if;
--        end if;
--    end process;
    
--    process(clock, reset)
--    begin
--        if(rising_edge(clock)) then
--            if(reset = '1') then
--                hold_st_cnt <= (others => '0');
--            else
--                if(hold_cnt_en = '1') then
--                    hold_st_cnt <= hold_st_cnt + '1';
--                else
--                    hold_st_cnt <= (others => '0'); 
--                end if;
--            end if;
--        end if;
--    end process;
     
    ILA : ila_0
    port map(
        clk     => clock,
        probe0  => init_calib_complete,
        probe1  => app_rdy,
        probe2  => app_wdf_rdy,
        probe3  => ip_enabled,
        probe4  => app_en_i,
        probe5  => app_wdf_wren_i,
        probe6  => rd_data_valid,
        probe7  => app_addr_i,
        probe8  => app_cmd_i,
        probe9  => wr_data,
        probe10 => rd_data(31 downto 0),
        probe11 => wr_count,
        probe12 => rd_count,
        probe13 => wr_addr,
        probe14 => rd_addr,
        probe15 => valid_reads,
        probe16 => state_code,
        probe17 => valid_reads_total,
        probe18 => rd_count_total
        );

end Behavioral;
