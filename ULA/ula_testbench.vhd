library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ula_tb is
end entity ula_tb;

architecture testbench of ula_tb is
    signal entrada1, entrada2 : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal operacao : STD_LOGIC_VECTOR(1 downto 0) := "00"; 
    signal saida : STD_LOGIC_VECTOR(15 downto 0);
    signal flag1, flag2, flag3 : STD_LOGIC;
    -- instância da ULA
    component ULA
        port (
            entrada1, entrada2: in STD_LOGIC_VECTOR(15 downto 0);
            operacao: in STD_LOGIC_VECTOR(1 downto 0);
            saida : out STD_LOGIC_VECTOR(15 downto 0);
            flag1, flag2, flag3: out STD_LOGIC
        );
    end component;

begin
    uut: ULA
        port map (
            entrada1 => entrada1,
            entrada2 => entrada2,
            operacao => operacao,
            saida => saida,
            flag1 => flag1,
            flag2 => flag2,
            flag3 => flag3
        );

    stimulus: process
    begin
        
        entrada1 <= x"0003"; 
        entrada2 <= x"0002"; 
        operacao <= "00"; 
        wait for 100 ns;

        -- Testar soma com números negativos
        entrada1 <= x"FFFD"; 
        entrada2 <= x"FFFE"; 
        operacao <= "00"; -- Soma
        wait for 100 ns;

        -- Testar subtração com números positivos
        entrada1 <= x"0005"; 
        entrada2 <= x"0003"; 
        operacao <= "01"; 
        wait for 100 ns;

        -- Testar subtração com números negativos
        entrada1 <= x"FFFD"; -- -3 em complemento de 2
        entrada2 <= x"FFFE"; -- -2 em complemento de 2
        operacao <= "01"; 
        wait for 100 ns;

        -- Testar OR lógico
        entrada1 <= x"00FF"; -- 255 em decimal
        entrada2 <= x"0F0F"; -- 3855 em decimal
        operacao <= "10"; -- OR
        wait for 100 ns;

        -- Testar AND lógico
        entrada1 <= x"00FF"; -- 255 em decimal
        entrada2 <= x"0F0F"; -- 3855 em decimal
        operacao <= "11"; -- AND
        wait for 100 ns;

        -- Testar overflow na soma
        entrada1 <= x"7FFF"; -- Valor máximo positivo (32767)
        entrada2 <= x"0001"; -- 1 em decimal
        operacao <= "00";
        wait for 100 ns;

        wait;
    end process stimulus;
end architecture testbench;