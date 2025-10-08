library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
    port (
        clk : in std_logic;
        rst : in std_logic;
        operacao : in std_logic_vector(1 downto 0); -- Operação para a ULA
        reg_wr_addr : in std_logic_vector(2 downto 0); -- Endereço de escrita no banco
        reg_rd_addr1 : in std_logic_vector(2 downto 0); -- Endereço de leitura 1
        reg_rd_addr2 : in std_logic_vector(2 downto 0); -- Endereço de leitura 2
        wr_data : in std_logic_vector(15 downto 0); -- Dados para escrita no banco
        ula_result : out std_logic_vector(15 downto 0); -- Resultado da ULA
        flags : out std_logic_vector(2 downto 0) -- Flags da ULA
    );
end entity;

architecture behavior of top_level is
    -- Sinais internos
    signal banco_out1, banco_out2 : std_logic_vector(15 downto 0);
    signal ula_out : std_logic_vector(15 downto 0);
    signal flag1, flag2, flag3 : std_logic;
    signal wr_en : std_logic; -- Sinal de habilitação de escrita
    
    -- Acumuladores
    signal acc_a : unsigned(15 downto 0); -- Acumulador A
    signal acc_b : unsigned(15 downto 0); -- Acumulador B
    
    -- Sinais de controle para acumuladores
    signal acc_a_wr_en : std_logic;
    signal acc_b_wr_en : std_logic;
    
    -- Sinal para operação da ULA (separado do sinal de controle)
    signal ula_op : std_logic_vector(1 downto 0);

begin
    -- Instância do banco de registradores
    banco : entity work.registers
        port map (
            clk => clk,
            reset => rst,
            wr_en => wr_en, 
            reg_wr_addr => reg_wr_addr,
            wr_data => wr_data,
            reg_read_addr1 => reg_rd_addr1,
            reg_read_addr2 => reg_rd_addr2,
            data_r1 => banco_out1,
            data_r2 => banco_out2
        );

    -- Controle do sinal wr_en
    wr_en <= '1' when operacao = "00" else '0'; -- Habilitar escrita apenas quando operacao = "00"

    -- Lógica para determinar a operação da ULA com base no modo de operação
    -- Aqui escolhemos uma operação padrão para cada modo:
    -- operacao = "00" (modo escrita): soma (para possível indexação)
    -- operacao = "01" (modo acc_a): subtração 
    -- operacao = "10" (modo acc_b): OR lógico
    -- operacao = "11" (modo inativo): AND lógico
    with operacao select
        ula_op <= "00" when "00",  -- Soma quando em modo escrita
                  "01" when "01",  -- Subtração quando em modo acc_a
                  "10" when "10",  -- OR quando em modo acc_b
                  "11" when others; -- AND em outros casos
    
    -- Instância da ULA
    ula : entity work.ULA
        port map (
            entrada1 => banco_out1,
            entrada2 => banco_out2,
            operacao => ula_op,    -- Usa o sinal dedicado para operação da ULA
            saida => ula_out,
            flag1 => flag1,
            flag2 => flag2,
            flag3 => flag3
        );

    -- Lógica para controle dos acumuladores
    acc_a_wr_en <= '1' when operacao = "01" else '0';  -- Ativa escrita quando operacao = "01"
    acc_b_wr_en <= '1' when operacao = "10" else '0';  -- Ativa escrita quando operacao = "10"
    
    -- Registradores para os acumuladores usando componente reg16bit
    acc_a_reg : entity work.reg16bit
        port map(
            clk => clk,
            rst => rst,
            wr_en => acc_a_wr_en,
            data_in => unsigned(ula_out),
            data_out => acc_a
        );
        
    acc_b_reg : entity work.reg16bit
        port map(
            clk => clk,
            rst => rst,
            wr_en => acc_b_wr_en,
            data_in => unsigned(ula_out),
            data_out => acc_b
        );

    -- Conexões de saída
    ula_result <= ula_out;
    flags <= flag1 & flag2 & flag3;

end architecture;