library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg7bit_tb is
end entity;

architecture testbench of reg7bit_tb is
    component reg7bit is
        port (
            clk     : in std_logic;
            rst     : in std_logic;
            wr_en   : in std_logic;
            data_in : in unsigned(6 downto 0);
            data_out: out unsigned(6 downto 0)
        );
    end component;

    -- Sinais de teste
    signal clk_sig     : std_logic := '0';
    signal rst_sig     : std_logic := '0';
    signal wr_en_sig   : std_logic := '0';
    signal data_in_sig : unsigned(6 downto 0) := "0000000";
    signal data_out_sig: unsigned(6 downto 0);

    constant clk_period: time := 10 ns;

begin
    -- Instanciação do componente a ser testado
    uut: reg7bit port map (
        clk      => clk_sig,
        rst      => rst_sig,
        wr_en    => wr_en_sig,
        data_in  => data_in_sig,
        data_out => data_out_sig
    );

    -- Processo de geração de clock
    clk_process: process
    begin
        clk_sig <= '0';
        wait for clk_period/2;
        clk_sig <= '1';
        wait for clk_period/2;
    end process;

    -- Processo de estímulo
    stimulus: process
    begin
        -- Teste 1: Reset inicial
        rst_sig <= '1';
        wait for clk_period * 2;
        
        -- Teste 2: Escrita desabilitada, o valor não deve mudar
        rst_sig <= '0';
        wr_en_sig <= '0';
        data_in_sig <= "0101010";  -- 42 em decimal
        wait for clk_period * 2;
        
        -- Teste 3: Escrita habilitada, o valor deve mudar na próxima borda de subida
        wr_en_sig <= '1';
        wait for clk_period;
        
        -- Teste 4: Mudança de valor com escrita habilitada
        data_in_sig <= "1010101";  -- 85 em decimal
        wait for clk_period;
        
        -- Teste 5: Reset durante operação
        rst_sig <= '1';
        wait for clk_period;
        
        -- Teste 6: Verificar se o reset tem prioridade sobre escrita
        rst_sig <= '1';
        wr_en_sig <= '1';
        data_in_sig <= "1111111";
        wait for clk_period;
        
        -- Teste 7: Retorno à operação normal após reset
        rst_sig <= '0';
        data_in_sig <= "0001111";  -- 15 em decimal
        wait for clk_period;
        
        -- Teste 8: Desabilitar escrita novamente
        wr_en_sig <= '0';
        data_in_sig <= "1111000";
        wait for clk_period * 2;
        
        -- Teste 9: Valor máximo com escrita habilitada
        wr_en_sig <= '1';
        data_in_sig <= "1111111";  -- 127 em decimal
        wait for clk_period;
        
        -- Teste 10: Valor mínimo com escrita habilitada
        data_in_sig <= "0000000";  -- 0 em decimal
        wait for clk_period;
        
        
        wait;
    end process;

end architecture;