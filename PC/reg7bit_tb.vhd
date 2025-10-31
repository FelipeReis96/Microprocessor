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

    signal clk_sig     : std_logic := '0';
    signal rst_sig     : std_logic := '0';
    signal wr_en_sig   : std_logic := '0';
    signal data_in_sig : unsigned(6 downto 0) := "0000000";
    signal data_out_sig: unsigned(6 downto 0);

    constant clk_period: time := 10 ns;

begin
   
    uut: reg7bit port map (
        clk      => clk_sig,
        rst      => rst_sig,
        wr_en    => wr_en_sig,
        data_in  => data_in_sig,
        data_out => data_out_sig
    );

    
    clk_process: process
    begin
        clk_sig <= '0';
        wait for clk_period/2;
        clk_sig <= '1';
        wait for clk_period/2;
    end process;


    stimulus: process
    begin
       
        rst_sig <= '1';
        wait for clk_period * 2;
        
        
        rst_sig <= '0';
        wr_en_sig <= '0';
        data_in_sig <= "0101010";  
        wait for clk_period * 2;
        
        
        wr_en_sig <= '1';
        wait for clk_period;
        
       
       
        data_in_sig <= "0000000"; 
        wait for clk_period;
        
        
        wait;
    end process;

end architecture;