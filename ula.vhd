library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ULA is 
    port (
        entrada1, entrada2: in STD_LOGIC_VECTOR(15 downto 0); 
        operacao: in STD_LOGIC_VECTOR(1 downto 0); -- Alterado para 2 bits
        saida : out STD_LOGIC_VECTOR(15 downto 0);
        flag1, flag2, flag3: out STD_LOGIC
    );
end entity ULA;

architecture teste of ULA is
begin
    -- Atribuição condicional para operações
    saida <= std_logic_vector(signed(entrada1) + signed(entrada2)) when operacao = "00" else
             std_logic_vector(signed(entrada1) - signed(entrada2)) when operacao = "01" else
             entrada1 or entrada2 when operacao = "10" else
             entrada1 and entrada2 when operacao = "11" else
             (others => '0'); -- Valor padrão
end architecture teste;
