library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ula_tb is
end entity;

architecture testbench of ula_tb is
    signal entrada1, entrada2 : std_logic_vector(15 downto 0);
    signal operacao : std_logic_vector(1 downto 0);
    signal saida : std_logic_vector(15 downto 0);
    signal flag1, flag2, flag3 : std_logic;

begin
    -- Instância da ULA
    uut: entity work.ULA
        port map (
            entrada1 => entrada1,
            entrada2 => entrada2,
            operacao => operacao,
            saida => saida,
            flag1 => flag1,
            flag2 => flag2,
            flag3 => flag3
        );

    -- Processo de estímulos
    stimulus: process
    begin
        -- Teste de adição
        entrada1 <= x"0001";
        entrada2 <= x"0002";
        operacao <= "00"; -- Adição
        wait for 10 ns;

        -- Teste de subtração
        entrada1 <= x"0003";
        entrada2 <= x"0001";
        operacao <= "01"; -- Subtração
        wait for 10 ns;

        -- Teste de OR
        entrada1 <= x"000F";
        entrada2 <= x"00F0";
        operacao <= "10"; -- OR
        wait for 10 ns;

        -- Teste de AND
        entrada1 <= x"00FF";
        entrada2 <= x"0F0F";
        operacao <= "11"; -- AND
        wait for 10 ns;

        wait;
    end process;
end architecture;