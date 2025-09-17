library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_tb is
end entity mux_tb;

architecture testbench of mux_tb is
    -- Sinais para conectar ao módulo
    signal entrada1, entrada2 : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal soma, sub, mul, sel_and : STD_LOGIC := '0'; -- Adicionado sel_and
    signal saida : STD_LOGIC_VECTOR(15 downto 0);
    signal flag1, flag2, flag3 : STD_LOGIC;

    -- Instância do módulo a ser testado
    component mux
        port (
            entrada1, entrada2: in STD_LOGIC_VECTOR(15 downto 0);
            soma, sub, mul, sel_and: in STD_LOGIC; -- Substituído op4 por sel_and
            saida : out STD_LOGIC_VECTOR(15 downto 0);
            flag1, flag2, flag3: out STD_LOGIC
        );
    end component;

begin
    uut: mux
        port map (
            entrada1 => entrada1,
            entrada2 => entrada2,
            soma => soma,
            sub => sub,
            mul => mul, -- Substituído op3 por mul
            sel_and => sel_and, -- Substituído op4 por sel_and
            saida => saida,
            flag1 => flag1,
            flag2 => flag2,
            flag3 => flag3
        );

    -- Processo de teste
    stimulus: process
    begin
        -- Testar soma
        entrada1 <= x"0003"; -- 3 em hexadecimal
        entrada2 <= x"0002"; -- 2 em hexadecimal
        soma <= '1';
        wait for 100 ns;
        soma <= '0';

        -- Testar subtração
        sub <= '1';
        wait for 200 ns; -- Aumentar o tempo de ativação
        sub <= '0';
        wait for 100 ns; -- Esperar para capturar o valor da saída

        -- Testar multiplicação
        mul <= '1';
        wait for 100 ns;
        mul <= '0';

        -- Testar AND
        entrada1 <= x"00FF"; -- 255 em hexadecimal
        entrada2 <= x"0F0F"; -- 3855 em hexadecimal
        sel_and <= '1';
        wait for 100 ns;
        sel_and <= '0';

        -- Finalizar simulação
        wait;
    end process stimulus;
end architecture testbench;