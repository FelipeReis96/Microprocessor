library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit is
    port(
        clk         : in  std_logic;
        rst         : in  std_logic;
        -- Flags ULA
        carry_in    : in  std_logic;
        zero_in     : in  std_logic;
        data_out_pc : out unsigned(6 downto 0);
        dado_rom    : out unsigned(18 downto 0);
        estado_out  : out unsigned(1 downto 0)
    );
end entity;

architecture behavior of control_unit is
    signal pc_out_s        : unsigned(6 downto 0);
    signal pc_next_s       : unsigned(6 downto 0);
    signal jump_en         : std_logic; -- JUMP absoluto (1100)
    signal jump_rel_en     : std_logic; -- BHI relativo (1110)
    signal jump_rel_en_bhs : std_logic; -- BHS relativo (1111)
    signal entrada_do_pc   : unsigned(6 downto 0);
    signal estado_s        : unsigned(1 downto 0); 
    signal pc_wr_en_s      : std_logic;
    signal dado_rom_s      : unsigned(18 downto 0);  
    signal instrucao_s     : unsigned(18 downto 0);
    signal opcode_s        : unsigned(3 downto 0);
    signal endereco_jump_s : unsigned(6 downto 0);
    
    signal offset6_s       : signed(5 downto 0);
    signal offset7_s       : signed(6 downto 0);
    signal pc_rel_s        : unsigned(6 downto 0);

begin
    pc_wr_en_s <= '1' when estado_s = "10" else '0'; 

    state_machine_inst : entity work.state_machine
        port map (
            clk => clk,
            rst => rst,
            state_out => estado_s
        );

    pc_inst : entity work.reg7bit  
        port map (
            clk => clk,
            rst => rst,
            wr_en => pc_wr_en_s,
            data_in => entrada_do_pc,
            data_out => pc_out_s
        );

    incrementador : entity work.somador1
        port map (
            data_in => pc_out_s,
            data_out => pc_next_s
        );

    rom_inst : entity work.ROM
        port map (
            clk => clk,
            endereco => pc_out_s,
            dado => dado_rom_s
        );

    data_out_pc <= pc_out_s;
    estado_out  <= estado_s; 
    dado_rom    <= dado_rom_s;

    instrucao_s     <= dado_rom_s;
    opcode_s        <= instrucao_s(18 downto 15);  
    endereco_jump_s <= "0" & instrucao_s(5 downto 0); 
    
    offset6_s   <= signed(instrucao_s(5 downto 0));
    offset7_s   <= resize(offset6_s, 7);
    pc_rel_s    <= unsigned(signed(pc_next_s) + offset7_s);

    -- 1100: salto absoluto incondicional (JUMP)
    jump_en     <= '1' when opcode_s = "1100" and estado_s = "10" else '0';
    -- 1110: BHI relativo (X > A após CMPI A,X): zero=0 e carry=1 (borrow)
    jump_rel_en <= '1' when opcode_s = "1110" and estado_s = "10" and zero_in = '0' and carry_in = '1' else '0';
    -- 1111: BHS relativo (X >= A após CMPI A,X): zero=1 (igual) ou carry=1 (borrow -> X > A)
    jump_rel_en_bhs <= '1' when opcode_s = "1111" and estado_s = "10" and (zero_in = '1' or carry_in = '1') else '0';

    entrada_do_pc <= pc_rel_s        when (jump_rel_en = '1' or jump_rel_en_bhs = '1') else
                     endereco_jump_s when jump_en     = '1' else
                     pc_next_s;

end architecture;