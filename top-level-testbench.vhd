library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level_tb is
end entity;

architecture testbench of top_level_tb is
    -- Sinais para o top-level
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal operacao : std_logic_vector(1 downto 0) := "00";
    signal reg_wr_addr : std_logic_vector(2 downto 0) := "000";
    signal reg_rd_addr1 : std_logic_vector(2 downto 0) := "000";
    signal reg_rd_addr2 : std_logic_vector(2 downto 0) := "000";
    signal wr_data : std_logic_vector(15 downto 0) := (others => '0');
    signal result : std_logic_vector(15 downto 0);
    signal flags : std_logic_vector(2 downto 0);

    -- Constantes para simulação
    constant clk_period : time := 20 ns;
    signal clk_stop : boolean := false;

begin

    -- Instância do top-level
    uut: entity work.top_level
        port map (
            clk => clk,
            rst => rst,
            operacao => operacao,
            reg_wr_addr => reg_wr_addr,
            reg_rd_addr1 => reg_rd_addr1,
            reg_rd_addr2 => reg_rd_addr2,
            wr_data => wr_data,
            ula_result => result,
            flags => open
        );

    -- Processo de clock
    clk_process: process
    begin
        while not clk_stop loop
            clk <= not clk;
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    -- Processo de estímulos - APENAS escrita nos registradores
    stimulus: process
    begin
        -- Valores iniciais
        operacao <= "11";  -- Começa sem permitir escrita
        reg_wr_addr <= "000";
        wr_data <= x"0000";
        
        -- RESET INICIAL - zera todos os registradores
        rst <= '1';
        wait for clk_period * 4;  -- Reset mais longo para garantir
        rst <= '0';
        wait for clk_period * 4;  -- Tempo para estabilizar após reset

        -- Primeiro configurar registrador 0
        reg_wr_addr <= "000";  -- Seleciona registrador 0
        wr_data <= x"0001";    -- Valor 1
        wait for clk_period * 4;  -- Espera estabilizar
        
        operacao <= "00";      -- Ativa escrita
        wait for clk_period * 4;  -- Mantém escrita ativa
        
        operacao <= "11";      -- Desativa escrita
        wait for clk_period * 4;  -- Espera estabilizar
        
        -- Agora configurar registrador 1
        reg_wr_addr <= "001";  -- Seleciona registrador 1
        wr_data <= x"0002";    -- Valor 2
        wait for clk_period * 4;  -- Espera estabilizar
        
        operacao <= "00";      -- Ativa escrita
        wait for clk_period * 4;  -- Mantém escrita ativa
        
        operacao <= "11";      -- Desativa escrita
        wait for clk_period * 8;  -- Espera final
        
        -- Configurar leitura dos registradores para teste de ULA e acumuladores
        reg_rd_addr1 <= "000";  -- Ler registrador 0 (valor 1)
        reg_rd_addr2 <= "001";  -- Ler registrador 1 (valor 2)
        wait for clk_period * 2;
        
        -- Teste do acumulador A - deve armazenar o resultado da ULA
        operacao <= "01";      -- Operação para carregar resultado no acc_a
        wait for clk_period * 4;
        
        -- Teste do acumulador B - deve armazenar o resultado da ULA
        operacao <= "10";      -- Operação para carregar resultado no acc_b
        wait for clk_period * 4;
        
        -- RESET FINAL - zera todos os registradores novamente
        rst <= '1';
        wait for clk_period * 6;  -- Reset ainda mais longo no final
        rst <= '0';
        wait for clk_period * 6;  -- Tempo maior para observar após reset

        -- Fim da simulação
        clk_stop <= true;
        wait;
    end process;
end architecture;