library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level_tb is
end entity;

architecture testbench of top_level_tb is
    -- Componente a ser testado
    component top_level is
        port (
            clk : in std_logic;
            rst : in std_logic;
            operacao : in std_logic_vector(1 downto 0);
            ula_operacao : in std_logic_vector(1 downto 0);
            reg_wr_addr : in unsigned(2 downto 0);
            reg_rd_addr1 : in unsigned(2 downto 0);
            reg_rd_addr2 : in unsigned(2 downto 0);
            constante : in unsigned(15 downto 0);
            load_const : in std_logic;
            use_imediato : in std_logic;
            sel_entrada1 : in std_logic_vector(1 downto 0);
            sel_entrada2 : in std_logic_vector(1 downto 0);
            instrucao : out unsigned(18 downto 0);
            ula_result : out unsigned(15 downto 0);
            flags : out std_logic_vector(2 downto 0)
        );
    end component;

    -- Sinais para conectar ao componente
    signal clk_sig : std_logic := '0';
    signal rst_sig : std_logic := '0';
    signal operacao_sig : std_logic_vector(1 downto 0) := "11"; -- No operation
    signal ula_operacao_sig : std_logic_vector(1 downto 0) := "00"; -- ADD
    signal reg_wr_addr_sig : unsigned(2 downto 0) := "000";
    signal reg_rd_addr1_sig : unsigned(2 downto 0) := "000";
    signal reg_rd_addr2_sig : unsigned(2 downto 0) := "000";
    signal constante_sig : unsigned(15 downto 0) := x"0000";
    signal load_const_sig : std_logic := '0';
    signal use_imediato_sig : std_logic := '0';
    signal sel_entrada1_sig : std_logic_vector(1 downto 0) := "00";
    signal sel_entrada2_sig : std_logic_vector(1 downto 0) := "00";
    signal instrucao_sig : unsigned(18 downto 0);
    signal ula_result_sig : unsigned(15 downto 0);
    signal flags_sig : std_logic_vector(2 downto 0);

    -- Constante para período do clock
    constant clk_period : time := 10 ns;

begin
    -- Instancia o componente a ser testado
    uut: top_level port map (
        clk => clk_sig,
        rst => rst_sig,
        operacao => operacao_sig,
        ula_operacao => ula_operacao_sig,
        reg_wr_addr => reg_wr_addr_sig,
        reg_rd_addr1 => reg_rd_addr1_sig,
        reg_rd_addr2 => reg_rd_addr2_sig,
        constante => constante_sig,
        load_const => load_const_sig,
        use_imediato => use_imediato_sig,
        sel_entrada1 => sel_entrada1_sig,
        sel_entrada2 => sel_entrada2_sig,
        instrucao => instrucao_sig,
        ula_result => ula_result_sig,
        flags => flags_sig
    );

    -- Processo para geração de clock
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
        -- Reset inicial
        rst_sig <= '1';
        wait for clk_period * 2;
        
        -- Desativa o reset e observa a operação da máquina de estados e PC
        rst_sig <= '0';
        
        -- Deixa a máquina de estados executar várias vezes (fetch, execute, fetch, execute...)
        -- O PC deve incrementar durante os estados de fetch
        wait for clk_period * 20;
        
        -- Aplicar reset novamente para verificar reinicialização
        rst_sig <= '1';
        wait for clk_period * 2;
        
        -- Desativa o reset e observa novamente
        rst_sig <= '0';
        
        -- Continua observando por mais alguns ciclos
        wait for clk_period * 20;
        
        wait;
    end process;

end architecture;