library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registers_tb is
end entity;

architecture testbench of registers_tb is
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal wr_en : std_logic;
    signal reg_wr_addr : std_logic_vector(2 downto 0);
    signal wr_data : std_logic_vector(15 downto 0);
    signal reg_read_addr1 : std_logic_vector(2 downto 0);
    signal reg_read_addr2 : std_logic_vector(2 downto 0);
    signal data_r1, data_r2 : std_logic_vector(15 downto 0);

begin
    -- Clock process
    clk_process: process
    begin
        while true loop
            clk <= not clk;
            wait for 10 ns;
        end loop;
    end process;

    -- Instância do banco de registradores
    uut: entity work.registers
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

    -- Processo de estímulos
    stimulus: process
    begin
        -- Reset
        reset <= '1';
        wait for 20 ns;
        reset <= '0';

        -- Escrever no registrador 0
        wr_en <= '1';
        reg_wr_addr <= "000";
        wr_data <= x"0001";
        wait for 20 ns;

        -- Escrever no registrador 1
        reg_wr_addr <= "001";
        wr_data <= x"0002";
        wait for 20 ns;

        -- Ler dos registradores
        wr_en <= '0';
        reg_read_addr1 <= "000";
        reg_read_addr2 <= "001";
        wait for 20 ns;

        wait;
    end process;
end architecture;