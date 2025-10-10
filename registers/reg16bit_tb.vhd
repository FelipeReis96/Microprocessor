library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg16bit_tb is
end entity;

architecture testbench of reg16bit_tb is

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '0';
    signal wr_en    : std_logic := '0';
    signal data_in  : unsigned(15 downto 0) := (others => '0');
    signal data_out : unsigned(15 downto 0);
    

    constant clk_period : time := 10 ns;
    signal sim_end : boolean := false;
    
begin
  
    uut: entity work.reg16bit
        port map (
            clk      => clk,
            rst      => rst,
            wr_en    => wr_en,
            data_in  => data_in,
            data_out => data_out
        );
    

    clk_process: process
    begin
        while not sim_end loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
        wait;
    end process;
    

    stimulus: process
    begin
        -- Reset inicial
        rst <= '1';
        wr_en <= '0';
        data_in <= x"0000";
        wait for clk_period * 2;
        
        -- Desativa o reset
        rst <= '0';
        wait for clk_period;
        
        -- Tenta escrever com wr_en desativado (não deve mudar o valor)
        data_in <= x"1234";
        wait for clk_period * 2;
        
        -- Ativa wr_en e verifica escrita
        wr_en <= '1';
        wait for clk_period * 2;
        
        -- Muda o valor com wr_en ativado
        data_in <= x"ABCD";
        wait for clk_period * 2;
        
        -- Desativa wr_en novamente
        wr_en <= '0';
        data_in <= x"5678"; -- Não deve ser escrito
        wait for clk_period * 2;
        

        rst <= '1';
        wait for clk_period * 2;
        

        sim_end <= true;
        wait;
    end process;
end architecture;