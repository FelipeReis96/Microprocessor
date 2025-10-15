library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity somador1_tb is
end entity;

architecture testbench of somador1_tb is
    component somador1 is
        port (
            data_in: in unsigned(6 downto 0);
            data_out: out unsigned(6 downto 0)
        );
    end component;

    signal data_in_sig: unsigned(6 downto 0);
    signal data_out_sig: unsigned(6 downto 0);
    
    constant wait_time: time := 5 ns;

begin
    uut: somador1 port map (
        data_in => data_in_sig,
        data_out => data_out_sig
    );

    
    stimulus: process
    begin
        -- Teste 1: 0 + 1 = 1
        data_in_sig <= "0000000";
        wait for wait_time;
        
        
        -- Teste 2: 1 + 1 = 2
        data_in_sig <= "0000001";
        wait for wait_time;
        
        
        -- Teste 3: 127 + 1 = 0 (overflow - volta para 0)
        data_in_sig <= "1111111";
        wait for wait_time;
        
        
        -- Teste 4: 64 + 1 = 65
        data_in_sig <= "1000000";
        wait for wait_time;
        
        
        -- Teste 5: 42 + 1 = 43
        data_in_sig <= "0101010";
        wait for wait_time;

        wait;
    end process;

end architecture;