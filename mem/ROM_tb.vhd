library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ROM_tb is
end entity;

architecture a_ROM_tb of ROM_tb is
    component ROM is
        port(
            clk      : in std_logic;
            endereco : in unsigned(6 downto 0);
            dado     : out unsigned(18 downto 0)
        );
    end component;
    
    signal clk_in      : std_logic := '0';
    signal endereco_in : unsigned(6 downto 0) := "0000000";
    signal dado_out    : unsigned(18 downto 0);
    
    constant clk_period : time := 10 ns;
    
begin
    uut: ROM port map (
        clk      => clk_in,
        endereco => endereco_in,
        dado     => dado_out
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
        wait for 2*clk_period;
        
        endereco_in <= "0000000";  
        wait for clk_period;       
        
        endereco_in <= "0000001";  
        wait for clk_period;       
        
        endereco_in <= "0000110";
        wait for clk_period;
        
        endereco_in <= "0001111";
        wait for clk_period;
        
        endereco_in <= "1111111";
        wait for clk_period;
        
        for i in 0 to 10 loop
            endereco_in <= to_unsigned(i, 7);
            wait for clk_period;
        end loop;
        
        wait;
    end process;
    
end architecture;