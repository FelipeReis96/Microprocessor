library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit_tb is
end entity;

architecture testbench of control_unit_tb is
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal data_out_pc : unsigned(6 downto 0);
    signal dado_rom : unsigned(18 downto 0);
    signal estado : std_logic;
    

    constant clk_period : time := 10 ns;
    
    signal sim_done : boolean := false;
    
begin
    
    uut: entity work.control_unit
        port map (
            clk => clk,
            rst => rst,
            data_out_pc => data_out_pc,
            dado_rom => dado_rom,
            estado_out => estado
        );
    
    
    clk_process: process
    begin
        while not sim_done loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
        wait;
    end process;
    
    
    stimulus: process
    begin
       
        rst <= '1';
        wait for clk_period * 2;
        rst <= '0';
        wait for clk_period;
        

        wait for clk_period * 20;
        
    
        rst <= '1';
        wait for clk_period * 2;
        rst <= '0';
        wait for clk_period;
        
        
        wait for clk_period * 30;
        
        
        sim_done <= true;
        wait;
    end process;
    
   
    
end architecture;