library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ROM is
   port( clk      : in std_logic;
         endereco : in unsigned(6 downto 0);
         dado     : out unsigned(18 downto 0) 
   );
end entity;

architecture a_ROM of ROM is
   type mem is array (0 to 127) of unsigned(18 downto 0); 
   constant conteudo_rom : mem := (
         -- Escritas (dados/endereços embaralhados)
         0  => "0001010000000000101",  -- LOAD R2, 5      ; ponteiro #1
         1  => "0001000000000100101",  -- LOAD R0, 37     ; dado #1
         2  => "0110010000000000000",  -- SW R2, R0       ; RAM[5]  = 37

         3  => "0001100000000111010",  -- LOAD R4, 58     ; ponteiro #2
         4  => "0001001000000101010",  -- LOAD R1, 42     ; dado #2
         5  => "0110100000001000000",  -- SW R4, R1       ; RAM[58] = 42

         6  => "0001011000000010111",  -- LOAD R3, 23     ; ponteiro #3
         7  => "0001000000000110111",  -- LOAD R0, 55     ; dado #3
         8  => "0110011000000000000",  -- SW R3, R0       ; RAM[23] = 55

         9  => "0000000000000000000",  -- NOP

         -- Contamina registros (evitar “falso ok”)
         10 => "0001000000000111111",  -- LOAD R0, 63
         11 => "0001001000000000000",  -- LOAD R1, 0
         12 => "0001010000000000000",  -- LOAD R2, 0
         13 => "0001011000000000000",  -- LOAD R3, 0
         14 => "0001100000000000000",  -- LOAD R4, 0

         -- Leituras, com distância temporal e regs diferentes
         15 => "0001010000000111010",  -- LOAD R2, 58     ; ponteiro p/ RAM[58]
         16 => "0000000000000000000",  -- NOP
         17 => "1011011000010000000",  -- LW R3, R2       ; R3 = RAM[58] = 42

         18 => "0001100000000010111",  -- LOAD R4, 23     ; ponteiro p/ RAM[23]
         19 => "0000000000000000000",  -- NOP
         20 => "1011001000100000000",  -- LW R1, R4       ; R1 = RAM[23] = 55

         21 => "0001010000000000101",  -- LOAD R2, 5      ; ponteiro p/ RAM[5]
         22 => "0000000000000000000",  -- NOP
         23 => "1011100000010000000",  -- LW R4, R2       ; R4 = RAM[5]  = 37

         others => (others => '0')
   );
begin
   process(clk)
   begin
      if rising_edge(clk) then
         dado <= conteudo_rom(to_integer(endereco));
      end if;
   end process;
end architecture;
