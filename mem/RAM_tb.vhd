library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM_tb is
end entity;

architecture tb of RAM_tb is
    signal clk      : std_logic := '0';
    signal endereco : unsigned(6 downto 0) := (others => '0');
    signal wr_en    : std_logic := '0';
    signal dado_in  : unsigned(15 downto 0) := (others => '0');
    signal dado_out : unsigned(15 downto 0);
begin
    dut : entity work.ram
        port map (
            clk      => clk,
            endereco => endereco,
            wr_en    => wr_en,
            dado_in  => dado_in,
            dado_out => dado_out
        );

    clk_p : process
    begin
        clk <= '0'; wait for 5 ns;
        clk <= '1'; wait for 5 ns;
    end process;

    stim : process
    begin

        endereco <= to_unsigned(5, 7);  dado_in <= to_unsigned(37, 16); wr_en <= '1';
        wait until rising_edge(clk); wr_en <= '0';

        endereco <= to_unsigned(58, 7); dado_in <= to_unsigned(42, 16); wr_en <= '1';
        wait until rising_edge(clk); wr_en <= '0';

        endereco <= to_unsigned(23, 7); dado_in <= to_unsigned(55, 16); wr_en <= '1';
        wait until rising_edge(clk); wr_en <= '0';

r
        wait until rising_edge(clk);

        wr_en <= '0';

        endereco <= to_unsigned(58, 7); wait for 1 ns;
        assert dado_out = to_unsigned(42, 16);

        endereco <= to_unsigned(23, 7); wait for 1 ns;
        assert dado_out = to_unsigned(55, 16);

        endereco <= to_unsigned(5, 7); wait for 1 ns;
        assert dado_out = to_unsigned(37, 16);

        wait;
    end process;
end architecture;