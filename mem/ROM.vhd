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
      0 => "0001010000000000101",  -- LOAD R2, 5 (opcode: 0001, ddd: 010, imediato: 0000101)  CERTO
      1 => "0001011000000001000",  -- LOAD R3, 8 (opcode: 0001, ddd: 011, imedi1ato: 0001000) CERTO
      2 => "1000000010000000000",  -- MOV A, R2 (opcode: 1000, bbb: 000 (A), fff: 010 (R2)) CERTO
      3 => "0101000011000000000",  -- ADD A, R3 opcode: 0101, fff: 011 (R3), bbb: 000 (A) CERTO
      4 => "0010100000000000000",  -- MOV R4, A (opcode: 0010, ddd: 100 (R4), aaa: 000 (A))
      5 => "0000000000000000000",  -- NOP
      6 => "1000000100000000000",  -- MOV A, R4 (opcode: 1000, bbb: 000 (A), fff: 100 (R4))
      7 => "0100000000000000001",  -- SUBI A, 1 (opcode: 0100, ddd: 100 (R4), cccccc: 000001)
      8 => "0010100000000000000",  -- MOV R4, A (opcode: 0010, ddd: 100 (R4), aaa: 000 (A)) CERTO
      9 => "0000000000000000000",  -- NOP
      10 => "0000000000000000000", -- NOP
      11 => "1100000000000010100", -- JUMP 20 (opcode: 1100, eeeeee = 010100) )
      12 => "0001100000000000000", -- LOAD R4, 0
      13 => "0000000000000000000",
      14 => "0000000000000000000",
      15 => "0000000000000000000",
      16 => "0000000000000000000",
      17 => "0000000000000000000",
      18 => "0000000000000000000",
      19 => "0000000000000000000",
      20 => "1000000100001000000", -- MOV B, R4
      21 => "0010010000000000000", -- MOV R2, B
      22 => "1100000000000000010", -- JUMP 2
      23 => "0001010000000000000", -- LOAD R2, 0
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
