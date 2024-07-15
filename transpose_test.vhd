----------------------------------------------------------------------------------
-- Company: 
-- Engineer: JOYAL
-- 
-- Create Date: 15.07.2024 22:36:05
-- Design Name: 
-- Module Name: transpose_test - Behavioral
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

entity transpose_test is
    Port ( clock : in STD_LOGIC;
           reset : in STD_LOGIC
           );
end transpose_test;

architecture Behavioral of transpose_test is

    constant row_max    : natural := 16;
    constant col_max    : natural := 64;
    constant read_burst : natural := 32;
    
    signal col_cnt_wr   : std_logic_vector(7 downto 0);
    signal row_cnt_wr   : std_logic_vector(7 downto 0);
    signal col_cnt_rd   : std_logic_vector(7 downto 0);
    signal row_cnt_rd   : std_logic_vector(7 downto 0);
    signal rd_cnt_burst : std_logic_vector(7 downto 0);
    signal read_count   : std_logic_vector(15 downto 0);

begin

    process(clock, reset)
    begin
        if(rising_edge(clock)) then
            if(reset = '1') then
                col_cnt_wr <= (others => '0');
                row_cnt_wr <= (others => '0');
            else
                if(col_cnt_wr < (col_max-1)) then
                    col_cnt_wr <= col_cnt_wr + '1';
                    row_cnt_wr <= row_cnt_wr;
                else   
                    if(row_cnt_wr < (row_max-1)) then
                        row_cnt_wr <= row_cnt_wr + '1';
                        col_cnt_wr <= (others => '0');
                    else
                        row_cnt_wr <= row_cnt_wr;
                        col_cnt_wr <= col_cnt_wr;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    process(clock, reset)
    begin
        if(rising_edge(clock)) then
            if(reset = '1') then
                col_cnt_rd <= (others => '0');
                row_cnt_rd <= (others => '0');
                read_count <= (others => '0');
            else
                if(row_cnt_rd < (row_max-1)) then
                    row_cnt_rd <= row_cnt_rd + '1';
                    col_cnt_rd <= col_cnt_rd;
                    if(read_count < (read_burst-1)) then
                        read_count <= read_count + '1';
                    else
                        read_count <= (others => '0');
                    end if;
                else   
                    if(col_cnt_rd < (col_max-1)) then
                        col_cnt_rd <= col_cnt_rd + '1';
                        row_cnt_rd <= (others => '0');
                        if(read_count < (read_burst-1)) then
                            read_count <= read_count + '1';
                        else
                            read_count <= (others => '0');
                        end if;
                    else
                        row_cnt_rd <= row_cnt_rd;
                        col_cnt_rd <= col_cnt_rd;
                        read_count <= read_count;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
end Behavioral;
