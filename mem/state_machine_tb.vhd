library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity state_machine_tb is
end entity;

architecture testbench of state_machine_tb is
    component state_machine is
        port (
            clk        : in std_logic;
            rst        : in std_logic;
            state_out  : out std_logic
        );
    end component;

    signal clk_in     : std_logic := '0';
    signal rst_in     : std_logic := '0';
    signal state_out  : std_logic;

    constant clk_period : time := 10 ns;

begin
    uut: state_machine port map (
        clk       => clk_in,
        rst       => rst_in,
        state_out => state_out
    );

    clk_process: process
    begin
        clk_in <= '0';
        wait for clk_period/2;
        clk_in <= '1';
        wait for clk_period/2;
    end process;

    stimulus: process
    begin
        -- Inicia com reset
        rst_in <= '1';
        wait for clk_period * 2;
        
        -- Desativa reset e observa alternância de estados
        rst_in <= '0';
        
        -- Observa 10 ciclos de clock (5 ciclos completos de fetch-execute)
        wait for clk_period * 10;
        
        -- Testa reset durante execução
        rst_in <= '1';
        wait for clk_period;
        rst_in <= '0';
        
        -- Observa mais alguns ciclos após o reset
        wait for clk_period * 6;
        
        wait;
    end process;

end architecture;