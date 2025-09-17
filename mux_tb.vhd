library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ULA is 
    port (
        entrada1, entrada2: in STD_LOGIC_VECTOR(15 downto 0); 
        soma, sub, mul, sel_and: in std_logic; 
        saida : out std_logic_vector(15 downto 0);
        flag1, flag2, flag3: out std_logic
    );
end entity ULA;

architecture teste of ULA is
begin
    -- Atribuição condicional para soma, subtração e valor padrão
    saida <= std_logic_vector(unsigned(entrada1) + unsigned(entrada2)) when soma = '1' else
             std_logic_vector(unsigned(entrada1) - unsigned(entrada2)) when sub = '1' else
             std_logic_vector(resize(unsigned(entrada1) * unsigned(entrada2), 16)) when mul = '1' else 
             std_logic_vector(unsigned(entrada1) and unsigned(entrada2)) when sel_and = '1' else
                (others => '0'); -- Valor padrão
end architecture teste;
