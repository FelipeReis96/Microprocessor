library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registers is 
    port (
        clk: in std_logic; 
        rst: in std_logic;                    
        we: in std_logic;                     
        wr_addr: in unsigned(2 downto 0);     
        wr_data: in unsigned(15 downto 0);    
        rd_addr1: in unsigned(2 downto 0);    
        rd_addr2: in unsigned(2 downto 0);    
        rd_data1: out unsigned(15 downto 0);  
        rd_data2: out unsigned(15 downto 0)   
    );
end entity;

architecture behavior of registers is 
   
    signal reg0_out, reg1_out, reg2_out, reg3_out, reg4_out : unsigned(15 downto 0);
    
    signal we0, we1, we2, we3, we4 : std_logic;
begin


    we0 <= '1' when (wr_addr = "000" and we = '1') else '0';
    we1 <= '1' when (wr_addr = "001" and we = '1') else '0';
    we2 <= '1' when (wr_addr = "010" and we = '1') else '0';
    we3 <= '1' when (wr_addr = "011" and we = '1') else '0';
    we4 <= '1' when (wr_addr = "100" and we = '1') else '0';

    -- Instâncias dos registradores
    reg0 : entity work.reg16bit
        port map(
            clk => clk,
            rst => rst,         
            wr_en => we0,
            data_in => wr_data, 
            data_out => reg0_out
        );
        
    reg1 : entity work.reg16bit
        port map(
            clk => clk,
            rst => rst,         
            wr_en => we1,
            data_in => wr_data, 
            data_out => reg1_out
        );
        
    reg2 : entity work.reg16bit
        port map(
            clk => clk,
            rst => rst,         
            wr_en => we2,
            data_in => wr_data, 
            data_out => reg2_out
        );
        
    reg3 : entity work.reg16bit
        port map(
            clk => clk,
            rst => rst,         
            wr_en => we3,
            data_in => wr_data, 
            data_out => reg3_out
        );
        
    reg4 : entity work.reg16bit
        port map(
            clk => clk,
            rst => rst,         
            wr_en => we4,
            data_in => wr_data, 
            data_out => reg4_out
        );

    
    rd_data1 <= reg0_out when rd_addr1 = "000" else
                reg1_out when rd_addr1 = "001" else
                reg2_out when rd_addr1 = "010" else
                reg3_out when rd_addr1 = "011" else
                reg4_out when rd_addr1 = "100" else
                (others => '0');

    rd_data2 <= reg0_out when rd_addr2 = "000" else
                reg1_out when rd_addr2 = "001" else
                reg2_out when rd_addr2 = "010" else
                reg3_out when rd_addr2 = "011" else
                reg4_out when rd_addr2 = "100" else
                (others => '0');
end behavior;
