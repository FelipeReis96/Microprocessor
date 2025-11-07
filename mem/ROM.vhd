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

         0 => "0001010000000000000",  -- LOAD R3,0  
         -- B. Carrega R4 com 0
         1 => "0001011000000000000",  -- LOAD R4,0  
         -- C. Soma R3 com R4 e guarda em R4  (R4 = R3 + R4)
         2 => "1000000010000000000",  -- MOV A, R3  (bbb=000(A), fff=010(R3))
         3 => "0101000011000000000",  -- ADD A, R4  (bbb=000(A), fff=011(R4))
         4 => "0010011000000000000",  -- MOV R4, A  (ddd=011(R4), aaa=000(A))
         -- D. Soma 1 em R3  (R3 = R3 + 1)
         5 => "1000000010000000000",  -- MOV A, R3  (bbb=000(A), fff=010(R3))
         6 => "0011000000000000001",  -- ADDI A, 1  (bbb=000(A), const=000001)
         7 => "0010010000000000000",  -- MOV R3, A  (ddd=010(R3), aaa=000(A))
         -- Comparação e loop: Se R3 < 30 volta para passo C (endereço 2)
         8  => "1000000010000000000",  -- MOV A, R3 (prepara para comparar) 
         9  => "1010000000000011110",  -- CMPI A,30 (opcode 1010, bbb=000(A), const=011110) 
      10 => "1110000000000110111",  -- BHI -9 (opcode 1110, offset=110111 -> -9) 
      11 => "1000000011000000000",  -- MOV A, R4 (bbb=000 A, fff=011 R4)
      12 => "0010100000000000000",  -- MOV R5, A (ddd=100 R5, aaa=000 A)
      others => (others=>'0')
   );
begin
   process(clk)
   begin
      if(rising_edge(clk)) then
         dado <= conteudo_rom(to_integer(endereco));
      end if;
   end process;
end architecture;
