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
         -- Inicialização
         0  => "0001001000000101001",  -- LOAD R1, 41
         1  => "0001000000000101001",  -- LOAD R0, 41

         -- loop_sw (PC 2):
         2  => "0110001000000000000",  -- SW   R1, R0

         -- Incrementa R1: MOV A,R1; ADDI A,1; MOV R1,A
         3  => "1000000001000000000",  -- MOV  A, R1
         4  => "0011000000000000001",  -- ADDI A, 1
         5  => "0010001000000000000",  -- MOV  R1, A

         -- Incrementa R0: MOV A,R0; ADDI A,1; MOV R0,A
         6  => "1000000000000000000",  -- MOV  A, R0
         7  => "0011000000000000001",  -- ADDI A, 1
         8  => "0010000000000000000",  -- MOV  R0, A

         -- Compara R1 com 33: MOV A, R1; CMPI A, 33
         9  => "1000000001000000000",  -- MOV A, R1
         10 => "1010000000001001010",  -- CMPI A, 74 

         -- BHI -9 (se R1 < 33, volta para SW em PC=2)
         11 => "1110000000000110111",  -- BHI -9 (offset=110111, PC=11-9=2)

         12 => "0000000000000000000",  -- NOP


         -- Zera múltiplos de 2 a partir do 4
         20 => "0001001000000000100",  -- LOAD R1, 4      
         21 => "0001000000000000000",  -- LOAD R0, 0      

         -- loop_zeros2:
         22 => "0110001000000000000",  -- SW R1, R0       

         -- Incrementa R1 em 2: MOV A,R1; ADDI A,2; MOV R1,A
         23 => "1000000001000000000",  -- MOV A, R1
         24 => "0011000000000000010",  -- ADDI A, 2
         25 => "0010001000000000000",  -- MOV R1, A

         -- Compara R1 com 73: MOV A, R1; CMPI A, 73
         26 => "1000000001000000000",  -- MOV A, R1
         27 => "1010000000001001010",  -- CMPI A, 74 (zeros de 2)

         -- BHI -5 (volta para SW em PC=22)
         28 => "1110000000000111001",  -- BHI -7 (offset=111001, PC=29-7=22)

         29 => "0000000000000000000",  -- NOP

         -- Zera múltiplos de 3 a partir do 6
         30 => "0001001000000000110",  -- LOAD R1, 6      
         31 => "0001000000000000000",  -- LOAD R0, 0      

         -- loop_zeros3:
         32 => "0110001000000000000",  -- SW R1, R0       

         -- Incrementa R1 em 3: MOV A,R1; ADDI A,3; MOV R1,A
         33 => "1000000001000000000",  -- MOV A, R1
         34 => "0011000000000000011",  -- ADDI A, 3
         35 => "0010001000000000000",  -- MOV R1, A

         -- Compara R1 com 73: MOV A, R1; CMPI A, 73
         36 => "1000000001000000000",  -- MOV A, R1
         37 => "1010000000001001010",  -- CMPI A, 74 

         -- BHI -7 (volta para SW em PC=32)
         38 => "1110000000000111001",  -- BHI -7 (offset=111001, PC=39-7=32)

         -- Fim
         39 => "0000000000000000000",  -- NOP

         -- Zera múltiplos de 5 a partir do 10
         40 => "0001001000000001010",  -- LOAD R1, 10      
         41 => "0001000000000000000",  -- LOAD R0, 0       

         -- loop_zeros5:
         42 => "0110001000000000000",  -- SW R1, R0       

         -- Incrementa R1 em 5: MOV A,R1; ADDI A,5; MOV R1,A
         43 => "1000000001000000000",  -- MOV A, R1
         44 => "0011000000000000101",  -- ADDI A, 5
         45 => "0010001000000000000",  -- MOV R1, A

         -- Compara R1 com 73: MOV A, R1; CMPI A, 73
         46 => "1000000001000000000",  -- MOV A, R1
         47 => "1010000000001001010",  -- CMPI A, 74 

         -- BHI -7 (volta para SW em PC=42)
         48 => "1110000000000111001",  -- BHI -7 (offset=111001, PC=49-7=42)

         49 => "0000000000000000000",  -- NOP

         -- Zera múltiplos de 7 a partir do 14
         50 => "0001001000000001110",  -- LOAD R1, 14      
         51 => "0001000000000000000",  -- LOAD R0, 0       

         -- loop_zeros7:
         52 => "0110001000000000000",  -- SW R1, R0       

         -- Incrementa R1 em 7: MOV A,R1; ADDI A,7; MOV R1,A
         53 => "1000000001000000000",  -- MOV A, R1
         54 => "0011000000000000111",  -- ADDI A, 7
         55 => "0010001000000000000",  -- MOV R1, A

         -- Compara R1 com 73: MOV A, R1; CMPI A, 73
         56 => "1000000001000000000",  -- MOV A, R1
         57 => "1010000000001001010",  -- CMPI A, 74 (zeros de 7)

         -- BHI -7 (volta para SW em PC=52)
         58 => "1110000000000111001",  -- BHI -7 (offset=111001, PC=59-7=52)
         59 => "0000000000000000000",  -- NOP

         60 => "0001000000000101001",  -- LOAD R0, 41      
         61 => "1011001000000000000",  -- LW R1, R0       

         62 => "1000000000000000000",  -- MOV A, R0
         63 => "0011000000000000001",  -- ADDI A, 1
         64 => "0010000000000000000",  -- MOV R0, A

         65 => "1000000000000000000",  -- MOV A, R0
         66 => "1010000000001001010",  -- CMPI A, 74 

         -- BHI -6 (volta para LW em PC=61)
         67 => "1110000000000111010",  -- BHI -6 (offset=111010, PC=68-6=62)

         others => (others => '0')
   );
begin
   process(clk)
   begin
      if(rising_edge(clk)) then
         dado <= conteudo_rom(to_integer(endereco));
      end if;
   end process;
end architecture;