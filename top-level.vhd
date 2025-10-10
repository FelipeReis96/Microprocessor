library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
    port (
        clk : in std_logic;
        rst : in std_logic;
        operacao : in std_logic_vector(1 downto 0); 
        ula_operacao : in std_logic_vector(1 downto 0);
        reg_wr_addr : in std_logic_vector(2 downto 0); 
        reg_rd_addr1 : in std_logic_vector(2 downto 0); 
        reg_rd_addr2 : in std_logic_vector(2 downto 0); 
        wr_data : in std_logic_vector(15 downto 0); 
        constante : in std_logic_vector(15 downto 0);
        load_const : in std_logic;
        use_imediato : in std_logic;
        use_ula_result : in std_logic;
        ula_result : out std_logic_vector(15 downto 0); 
        flags : out std_logic_vector(2 downto 0) 
    );
end entity;

architecture behavior of top_level is
    
    signal banco_out1_std, banco_out2_std : std_logic_vector(15 downto 0);
    signal banco_out1, banco_out2 : unsigned(15 downto 0);
    signal ula_out_std : std_logic_vector(15 downto 0);  -- Alterado para std_logic_vector
    signal ula_out : unsigned(15 downto 0);
    signal flag1, flag2, flag3 : std_logic;
    signal wr_en : std_logic; 
    
    signal acc_a : unsigned(15 downto 0);
    signal acc_b : unsigned(15 downto 0);
    
    signal acc_a_wr_en : std_logic;
    signal acc_b_wr_en : std_logic;
    
    signal ula_entrada2 : unsigned(15 downto 0);
    
    signal banco_wr_data : std_logic_vector(15 downto 0);

begin
    banco_wr_data <= constante when load_const = '1' else
                     ula_out_std when use_ula_result = '1' else
                     wr_data;

    banco : entity work.registers
        port map (
            clk => clk,
            reset => rst,
            wr_en => wr_en, 
            reg_wr_addr => reg_wr_addr,
            wr_data => banco_wr_data,
            reg_read_addr1 => reg_rd_addr1,
            reg_read_addr2 => reg_rd_addr2,
            data_r1 => banco_out1_std,
            data_r2 => banco_out2_std
        );

    banco_out1 <= unsigned(banco_out1_std);
    banco_out2 <= unsigned(banco_out2_std);

    wr_en <= '1' when operacao = "00" else '0';

    ula_entrada2 <= unsigned(constante) when use_imediato = '1' else banco_out2;
    
    ula : entity work.ULA
        port map (
            entrada1 => std_logic_vector(banco_out1),
            entrada2 => std_logic_vector(ula_entrada2),
            operacao => ula_operacao,
            saida => ula_out_std,  -- Conecta diretamente ao sinal std_logic_vector
            flag1 => flag1,
            flag2 => flag2,
            flag3 => flag3
        );

    -- Conversão após receber o resultado da ULA
    ula_out <= unsigned(ula_out_std);

    acc_a_wr_en <= '1' when operacao = "01" else '0';
    acc_b_wr_en <= '1' when operacao = "10" else '0';
    
    acc_a_reg : entity work.reg16bit
        port map(
            clk => clk,
            rst => rst,
            wr_en => acc_a_wr_en,
            data_in => ula_out,
            data_out => acc_a
        );
        
    acc_b_reg : entity work.reg16bit
        port map(
            clk => clk,
            rst => rst,
            wr_en => acc_b_wr_en,
            data_in => ula_out,
            data_out => acc_b
        );

    ula_result <= ula_out_std;
    flags <= flag1 & flag2 & flag3;

end architecture;