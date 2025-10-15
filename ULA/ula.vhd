library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ULA is 
    port (
        entrada1, entrada2: in unsigned(15 downto 0); 
        operacao: in STD_LOGIC_VECTOR(1 downto 0); 
        saida : out unsigned(15 downto 0);  
        flag1, flag2, flag3: out STD_LOGIC
    );
end entity ULA;

architecture teste of ULA is
    signal resultado: unsigned(15 downto 0); 
begin
    

    
    resultado <= entrada1 + entrada2 when operacao = "00" else
                 entrada1 - entrada2 when operacao = "01" else
                 entrada1 or entrada2 when operacao = "10" else
                 entrada1 and entrada2 when operacao = "11" else
                 (others => '0');
    
    
    saida <= resultado;
    
    
end architecture teste;
