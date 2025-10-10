library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level_tb is
end entity;

architecture testbench of top_level_tb is

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal operacao : std_logic_vector(1 downto 0) := "00";
    signal ula_operacao : std_logic_vector(1 downto 0) := "00";
    signal reg_wr_addr : std_logic_vector(2 downto 0) := "000";
    signal reg_rd_addr1 : std_logic_vector(2 downto 0) := "000";
    signal reg_rd_addr2 : std_logic_vector(2 downto 0) := "000";
    signal wr_data : std_logic_vector(15 downto 0) := (others => '0');
    signal constante : std_logic_vector(15 downto 0) := (others => '0');
    signal load_const : std_logic := '0';
    signal use_imediato : std_logic := '0';
    signal use_ula_result : std_logic := '0';  -- Sinal para usar resultado da ULA para escrita
    signal result : std_logic_vector(15 downto 0);
    signal flags : std_logic_vector(2 downto 0);

    constant clk_period : time := 20 ns;
    signal clk_stop : boolean := false;

begin

    uut: entity work.top_level
        port map (
            clk => clk,
            rst => rst,
            operacao => operacao,
            ula_operacao => ula_operacao,
            reg_wr_addr => reg_wr_addr,
            reg_rd_addr1 => reg_rd_addr1,
            reg_rd_addr2 => reg_rd_addr2,
            wr_data => wr_data,
            constante => constante,
            load_const => load_const,
            use_imediato => use_imediato,
            use_ula_result => use_ula_result,
            ula_result => result,
            flags => flags
        );

    clk_process: process
    begin
        while not clk_stop loop
            clk <= not clk;
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    stimulus: process
    begin
    
        -- Configuração inicial
        operacao <= "11";
        ula_operacao <= "00";
        reg_wr_addr <= "000";
        wr_data <= x"0000";
        constante <= x"0000";
        load_const <= '0';
        use_imediato <= '0';
        use_ula_result <= '0';
        
        -- Reset inicial
        rst <= '1';
        wait for clk_period * 4;  
        rst <= '0';
        wait for clk_period * 4;  

        -- Teste 1: Escrita normal no registrador 0 (valor 1)
        reg_wr_addr <= "000";  
        wr_data <= x"0001";    
        load_const <= '0';
        wait for clk_period * 4;  
    
        operacao <= "00";
        wait for clk_period * 4;  
    
        operacao <= "11";
        wait for clk_period * 4;  
    
        -- Teste 2: Escrita normal no registrador 1 (valor 2)
        reg_wr_addr <= "001";  
        wr_data <= x"0002";    
        wait for clk_period * 4;  
    
        operacao <= "00";
        wait for clk_period * 4;  
    
        operacao <= "11";
        wait for clk_period * 4;  
    
        -- Teste 3: Carga de constante direta (LD) no registrador 2 (valor 5)
        reg_wr_addr <= "010";
        constante <= x"0005";
        load_const <= '1';
        wait for clk_period * 4;
    
        operacao <= "00";
        wait for clk_period * 4;
    
        operacao <= "11";
        load_const <= '0';
        wait for clk_period * 4;
    
        -- Teste 4: Operação normal ADD (reg0 + reg1 = 1 + 2 = 3)
        reg_rd_addr1 <= "000";
        reg_rd_addr2 <= "001";
        use_imediato <= '0';
        ula_operacao <= "00";
        wait for clk_period * 2;
    
        operacao <= "01";
        wait for clk_period * 4;
    
        operacao <= "11";
        wait for clk_period * 2;
    
        -- Teste 5: Operação ADDI (reg0 + constante = 1 + 10 = 11)
        reg_rd_addr1 <= "000";
        constante <= x"000A";
        use_imediato <= '1';
        ula_operacao <= "00";
        wait for clk_period * 2;
    
        operacao <= "10";
        wait for clk_period * 4;
    
        operacao <= "11";
        wait for clk_period * 2;
    
        -- Teste 6: Operação SUBI (reg2 - constante = 5 - 3 = 2)
        reg_rd_addr1 <= "010";
        constante <= x"0003";
        use_imediato <= '1';
        ula_operacao <= "01";
        wait for clk_period * 2;
    
        operacao <= "01";
        wait for clk_period * 4;
    
        operacao <= "11";
        wait for clk_period * 2;
    
      
        reg_rd_addr1 <= "001";  
        reg_rd_addr2 <= "010";  
        use_imediato <= '0';    -- Usar registradores
        ula_operacao <= "00";   -- Soma
        reg_wr_addr <= "011";   -- Resultado vai para reg3
        use_ula_result <= '1';  -- Usar resultado da ULA para escrita
        wait for clk_period * 2;
    
        operacao <= "00";       -- Modo de escrita (agora escreve resultado da ULA)
        wait for clk_period * 4;
    
        operacao <= "11";      
        use_ula_result <= '0'; 
        wait for clk_period * 2;
    
        -- Reset final
        rst <= '1';
        wait for clk_period * 6; 
        rst <= '0';
        wait for clk_period * 6;  

        clk_stop <= true;
        wait;
    end process;
end architecture;