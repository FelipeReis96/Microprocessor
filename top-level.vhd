library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
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
        
        -- Controles para selecionar fontes para ULA
        sel_entrada1 : in std_logic_vector(1 downto 0);  -- 00: banco, 01: acc_a, 10: acc_b, 11: constante
        sel_entrada2 : in std_logic_vector(1 downto 0);  -- 00: banco, 01: acc_a, 10: acc_b, 11: constante
        
        -- Nova saída: instrução lida da ROM
        instrucao : out unsigned(18 downto 0);
        
        ula_result : out unsigned(15 downto 0);
        flags : out std_logic_vector(2 downto 0)
    );
end entity;

architecture behavior of top_level is
    
    signal banco_out1, banco_out2 : unsigned(15 downto 0);
    signal ula_out : unsigned(15 downto 0);
    signal flag1, flag2, flag3 : std_logic;
    signal wr_en : std_logic; 
    
    signal acc_a : unsigned(15 downto 0);
    signal acc_b : unsigned(15 downto 0);
    
    signal acc_a_wr_en : std_logic;
    signal acc_b_wr_en : std_logic;
    
    -- Sinais para MUXs
    signal ula_entrada1 : unsigned(15 downto 0);
    signal ula_entrada2 : unsigned(15 downto 0);
    
    signal banco_wr_data : unsigned(15 downto 0);
    
    -- Novos sinais para PC e ROM
    signal pc_out : unsigned(6 downto 0);
    signal pc_in : unsigned(6 downto 0);
    signal rom_data : unsigned(18 downto 0);
    signal estado : std_logic;
    signal pc_wr_en : std_logic;

begin
    -- Máquina de estados de dois estados (fetch e execute)
    state_machine_inst : entity work.state_machine
        port map (
            clk => clk,
            rst => rst,
            state_out => estado
        );
    
    -- Lógica do PC (Program Counter)
    -- PC só incrementa no estado de fetch (estado = '0')
    pc_wr_en <= '1' when estado = '0' else '0';
    
    -- Somador para incrementar o PC
    pc_incrementador : entity work.somador1
        port map (
            data_in => pc_out,
            data_out => pc_in
        );
    
    -- Registrador PC
    pc_reg : entity work.reg7bit
        port map (
            clk => clk,
            rst => rst,
            wr_en => pc_wr_en,
            data_in => pc_in,
            data_out => pc_out
        );
    
    -- ROM
    rom_inst : entity work.ROM
        port map (
            clk => clk,
            endereco => pc_out,
            dado => rom_data
        );
    
    -- Dados para escrita no banco de registradores
    banco_wr_data <= constante when load_const = '1' else ula_out;

    banco : entity work.registers
        port map (
            clk => clk,
            rst => rst,
            we => wr_en,
            wr_addr => reg_wr_addr,
            wr_data => banco_wr_data,
            rd_addr1 => reg_rd_addr1,
            rd_addr2 => reg_rd_addr2,
            rd_data1 => banco_out1,
            rd_data2 => banco_out2
        );

    -- Controle de escrita para banco de registradores
    wr_en <= '1' when operacao = "00" else '0';

    -- MUX para selecionar primeira entrada da ULA
    with sel_entrada1 select
        ula_entrada1 <= banco_out1 when "00",
                        acc_a when "01",
                        acc_b when "10",
                        constante when others;

    -- MUX para selecionar segunda entrada da ULA
    with sel_entrada2 select
        ula_entrada2 <= banco_out2 when "00",
                        acc_a when "01",
                        acc_b when "10",
                        constante when others;
    
    -- Instância da ULA
    ula : entity work.ULA
        port map (
            entrada1 => ula_entrada1,
            entrada2 => ula_entrada2,
            operacao => ula_operacao,
            saida => ula_out,
            flag1 => flag1,
            flag2 => flag2,
            flag3 => flag3
        );

    -- Controle de escrita para acumuladores
    acc_a_wr_en <= '1' when operacao = "01" else '0';
    acc_b_wr_en <= '1' when operacao = "10" else '0';
    
    -- Instância do acumulador A
    acc_a_reg : entity work.reg16bit
        port map(
            clk => clk,
            rst => rst,
            wr_en => acc_a_wr_en,
            data_in => ula_out,
            data_out => acc_a
        );
    
    -- Instância do acumulador B
    acc_b_reg : entity work.reg16bit
        port map(
            clk => clk,
            rst => rst,
            wr_en => acc_b_wr_en,
            data_in => ula_out,
            data_out => acc_b
        );

    -- Saídas
    ula_result <= ula_out;
    flags <= flag1 & flag2 & flag3;
    instrucao <= rom_data;  -- Conecta a saída da ROM ao pino instrucao

end architecture;