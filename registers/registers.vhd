library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registers is 
    port (
        clk: in STD_LOGIC; 
        reset: in STD_LOGIC;
        wr_en: in STD_LOGIC;
        reg_wr_addr: in std_logic_vector(2 downto 0);
        wr_data: in std_logic_vector(15 downto 0);
        reg_read_addr1 : in std_logic_vector(2 downto 0);
        reg_read_addr2 : in std_logic_vector(2 downto 0);
        data_r1     : out std_logic_vector(15 downto 0); 
        data_r2     : out std_logic_vector(15 downto 0)
    );
end entity;

architecture behavior of registers is 
   
    signal reg0_out, reg1_out, reg2_out, reg3_out, reg4_out : unsigned(15 downto 0);
    

    signal we0, we1, we2, we3, we4 : std_logic;
begin

    we0 <= '1' when (reg_wr_addr = "000" and wr_en = '1') else '0';
    we1 <= '1' when (reg_wr_addr = "001" and wr_en = '1') else '0';
    we2 <= '1' when (reg_wr_addr = "010" and wr_en = '1') else '0';
    we3 <= '1' when (reg_wr_addr = "011" and wr_en = '1') else '0';
    we4 <= '1' when (reg_wr_addr = "100" and wr_en = '1') else '0';


    reg0 : entity work.reg16bit
        port map(
            clk => clk,
            rst => reset,
            wr_en => we0,
            data_in => unsigned(wr_data),
            data_out => reg0_out
        );
        
    reg1 : entity work.reg16bit
        port map(
            clk => clk,
            rst => reset,
            wr_en => we1,
            data_in => unsigned(wr_data),
            data_out => reg1_out
        );
        
    reg2 : entity work.reg16bit
        port map(
            clk => clk,
            rst => reset,
            wr_en => we2,
            data_in => unsigned(wr_data),
            data_out => reg2_out
        );
        
    reg3 : entity work.reg16bit
        port map(
            clk => clk,
            rst => reset,
            wr_en => we3,
            data_in => unsigned(wr_data),
            data_out => reg3_out
        );
        
    reg4 : entity work.reg16bit
        port map(
            clk => clk,
            rst => reset,
            wr_en => we4,
            data_in => unsigned(wr_data),
            data_out => reg4_out
        );


    data_r1 <= std_logic_vector(reg0_out) when reg_read_addr1 = "000" else
               std_logic_vector(reg1_out) when reg_read_addr1 = "001" else
               std_logic_vector(reg2_out) when reg_read_addr1 = "010" else
               std_logic_vector(reg3_out) when reg_read_addr1 = "011" else
               std_logic_vector(reg4_out) when reg_read_addr1 = "100" else
               (others => '0');

    data_r2 <= std_logic_vector(reg0_out) when reg_read_addr2 = "000" else
               std_logic_vector(reg1_out) when reg_read_addr2 = "001" else
               std_logic_vector(reg2_out) when reg_read_addr2 = "010" else
               std_logic_vector(reg3_out) when reg_read_addr2 = "011" else
               std_logic_vector(reg4_out) when reg_read_addr2 = "100" else
               (others => '0');
end behavior;
