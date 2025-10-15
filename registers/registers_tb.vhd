library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registers_tb is
end entity;

architecture testbench of registers_tb is
    signal clk: std_logic := '0';
    signal reset: std_logic := '0';
    signal wr_en: std_logic := '0';
    signal reg_wr_addr: std_logic_vector(2 downto 0) := (others => '0');
    signal wr_data: std_logic_vector(15 downto 0) := (others => '0');
    signal reg_read_addr1: std_logic_vector(2 downto 0) := (others => '0');
    signal reg_read_addr2: std_logic_vector(2 downto 0) := (others => '0');
    signal data_r1: std_logic_vector(15 downto 0);
    signal data_r2: std_logic_vector(15 downto 0);


    component registers
        port (
            clk: in std_logic;
            reset: in std_logic;
            wr_en: in std_logic;
            reg_wr_addr: in std_logic_vector(2 downto 0);
            wr_data: in std_logic_vector(15 downto 0);
            reg_read_addr1: in std_logic_vector(2 downto 0);
            reg_read_addr2: in std_logic_vector(2 downto 0);
            data_r1: out std_logic_vector(15 downto 0);
            data_r2: out std_logic_vector(15 downto 0)
        );
    end component;

begin
    uut: registers
        port map (
            clk => clk,
            reset => reset,
            wr_en => wr_en,
            reg_wr_addr => reg_wr_addr,
            wr_data => wr_data,
            reg_read_addr1 => reg_read_addr1,
            reg_read_addr2 => reg_read_addr2,
            data_r1 => data_r1,
            data_r2 => data_r2
        );


    clk_process: process
        variable cycle_count: integer := 0;
    begin
        while cycle_count < 100 loop  
            clk <= not clk;
            wait for 10 ns;
            cycle_count := cycle_count + 1;
        end loop;
        wait;  
    end process;


    stimulus: process
    begin
     
        reset <= '1';
        wait for 20 ns;
        reset <= '0';


        wr_en <= '1';
        reg_wr_addr <= "000";
        wr_data <= x"1234";
        wait for 20 ns;
        wr_en <= '0';

     
        reg_read_addr1 <= "000";
        wait for 20 ns;

        wr_en <= '1';
        reg_wr_addr <= "001";
        wr_data <= x"5678";
        wait for 20 ns;
        wr_en <= '0';

        reg_read_addr2 <= "001";
        wait for 20 ns;


        wait;
    end process;
end architecture;