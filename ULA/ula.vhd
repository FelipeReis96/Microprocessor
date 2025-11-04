library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ULA is 
    port (
        entrada1, entrada2: in unsigned(15 downto 0); 
        operacao: in STD_LOGIC_VECTOR(1 downto 0); 
    saida : out unsigned(15 downto 0);  
    carry, zero, negativo: out STD_LOGIC
    );
end entity ULA;

architecture teste of ULA is
    signal resultado: unsigned(15 downto 0); 
    -- Sinais auxiliares para soma/subtração com 17 bits
    signal in_a_17, in_b_17, soma_17 : unsigned(16 downto 0);
    signal carry_soma, carry_subtr : std_logic;
begin
    
    -- Expande os operandos para 17 bits
    in_a_17 <= '0' & entrada1;      -- in_a: unsigned(15 downto 0)
    in_b_17 <= '0' & entrada2;

    -- Soma com carry
    soma_17 <= in_a_17 + in_b_17;
    carry_soma <= soma_17(16);  -- Carry da soma (MSB do resultado 17 bits)

    -- Carry da subtração (unsigned)
    carry_subtr <= '0' when entrada2 <= entrada1 else '1';  -- Se in_b > in_a, houve borrow

    resultado <= entrada1 + entrada2 when operacao = "00" else
                 entrada1 - entrada2 when operacao = "01" else
                 entrada1 or entrada2 when operacao = "10" else
                 entrada1 and entrada2 when operacao = "11" else
                 (others => '0');

    saida <= resultado;

    -- Flags
    carry <= carry_soma when operacao = "00" else
              carry_subtr when operacao = "01" else
              '0';

    zero <= '1' when resultado = 0 else '0';

    negativo <= resultado(15);
end architecture teste;
