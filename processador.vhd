library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processador is
    port (
        clk : in std_logic;
        rst : in std_logic;
    -- sinais removidos: operacao, ula_operacao, reg_wr_addr, reg_rd_addr1, reg_rd_addr2, constante, load_const, use_imediato
        instrucao : out unsigned(18 downto 0);
        ula_result : out unsigned(15 downto 0);
        flags : out std_logic_vector(2 downto 0)
    );
end entity;

architecture behavior of processador is

    signal banco_out1, banco_out2 : unsigned(15 downto 0) := (others => '0');
    signal ula_out : unsigned(15 downto 0);
    signal flag1, flag2, flag3 : std_logic;
    signal wr_en : std_logic; 
    signal wr_en_instrucao : std_logic; 

    signal acc_a : unsigned(15 downto 0) := (others => '0');
    signal acc_b : unsigned(15 downto 0) := (others => '0');

    signal acc_a_wr_en : std_logic;
    signal acc_b_wr_en : std_logic;

    signal ula_entrada1 : unsigned(15 downto 0);
    signal ula_entrada2 : unsigned(15 downto 0);

    signal banco_wr_data : unsigned(15 downto 0);

    -- Sinais vindos da UC
    signal pc_out : unsigned(6 downto 0);
    signal rom_data : unsigned(18 downto 0);
    signal estado : unsigned(1 downto 0);

    signal opcode : std_logic_vector(3 downto 0);
    signal constante_rom : unsigned(15 downto 0);
    signal reg_wr_addr_int : unsigned(2 downto 0);
    signal ula_operacao_int : std_logic_vector(1 downto 0);
    signal reg_rd_addr1_int : unsigned(2 downto 0);
    signal reg_rd_addr2_int : unsigned(2 downto 0);

    signal acc_a_in : unsigned(15 downto 0);
    signal acc_b_in : unsigned(15 downto 0);

    signal jump_addr : unsigned(6 downto 0);

    -- Campos da instrução
    signal ddd : unsigned(2 downto 0);
    signal aaa : unsigned(2 downto 0);
    signal bbb : unsigned(2 downto 0);
    signal fff : unsigned(2 downto 0);
    signal imediato : unsigned(7 downto 0); -- 8 bits
    signal constante_sub : unsigned(5 downto 0);

    signal instrucao_reg : unsigned(18 downto 0);

    signal addi_const : unsigned(5 downto 0);

    signal flag_carry : std_logic;
    signal flag_zero : std_logic;
    signal flag_negativo : std_logic;

begin
    uc_inst : entity work.control_unit
        port map (
            clk         => clk,
            rst         => rst,
            data_out_pc => pc_out,      
            dado_rom    => rom_data,
            estado_out  => estado
        );

    -- Decodificação dos campos da instrução
    opcode    <= std_logic_vector(rom_data(18 downto 15)); 
    jump_addr <= ("0" & rom_data(5 downto 0));                  
    ddd      <= rom_data(14 downto 12);
    fff      <= rom_data(11 downto 9);
    bbb      <= rom_data(8 downto 6); -- acumulador destino (MOV A, R e ADD A, R)
    aaa      <= rom_data(8 downto 6); -- acumulador fonte (MOV R, A)
    imediato <= rom_data(7 downto 0);
    constante_sub <= rom_data(5 downto 0);

    addi_const <= rom_data(5 downto 0);

    -- Seleção dos acumuladores para entrada da ULA
    ula_entrada1 <= acc_a when bbb = "000" else acc_b;
    ula_entrada2 <= banco_out1 when (opcode = "1000" or opcode = "0101") else
                    ("0000000000" & constante_sub) when opcode = "0100" else
                    ("0000000000" & addi_const) when opcode = "0011" else
                    (others => '0');

    -- Controle de escrita nos acumuladores
    acc_a_wr_en <= '1' when (estado = "10" and (
                        (opcode = "1000" and bbb = "000") or
                        (opcode = "0101" and bbb = "000") or
                        (opcode = "0100" and bbb = "000") or
                        (opcode = "0011" and bbb = "000")
                    )) else '0';

    acc_b_wr_en <= '1' when (estado = "10" and (
                        (opcode = "1000" and bbb = "001") or
                        (opcode = "0101" and bbb = "001")
                    )) else '0';

    -- Mux de entrada dos acumuladores
    acc_a_in <= banco_out1 when (estado = "10" and opcode = "1000" and bbb = "000") else
                ula_out    when (estado = "10" and ((opcode = "0101" or opcode = "0100" or opcode = "0011") and bbb = "000")) else
                acc_a;

    acc_b_in <= banco_out1 when (estado = "10" and opcode = "1000" and bbb = "001") else
                ula_out    when (estado = "10" and opcode = "0101" and bbb = "001") else
                acc_b;

    -- Controle de escrita no banco de registradores
    wr_en <= '1' when (estado = "10" and opcode = "0001") else -- LOAD
             '1' when (estado = "10" and opcode = "0010") else -- MOV R, A
             '0';

    

    -- Seleção do dado de escrita para o banco de registradores
    banco_wr_data <= ("00000000" & imediato) when (estado = "10" and opcode = "0001") else -- LOAD
                     acc_a when (estado = "10" and opcode = "0010" and aaa = "000") else -- MOV R, A
                     acc_b when (estado = "10" and opcode = "0010" and aaa = "001") else -- MOV R, B
                     banco_wr_data;

    -- Seleção do endereço de escrita para o banco de registradores
    reg_wr_addr_int <= ddd when (estado = "10" and (opcode = "0001" or opcode = "0010")) else (others => '0');

    -- Seleção do endereço de leitura do banco de registradores
    reg_rd_addr1_int <= fff when (opcode = "1000" or opcode = "0101") else (others => '0');
    reg_rd_addr2_int <= (others => '0');

    -- Instância do banco de registradores
    banco : entity work.registers
        port map (
            clk      => clk,
            rst      => rst,
            we       => wr_en,
            wr_addr  => reg_wr_addr_int,
            wr_data  => banco_wr_data,
            rd_addr1 => reg_rd_addr1_int,
            rd_addr2 => reg_rd_addr2_int,
            rd_data1 => banco_out1,
            rd_data2 => banco_out2
        );


    ula : entity work.ULA
        port map (
            entrada1 => ula_entrada1,
            entrada2 => ula_entrada2,
            operacao => ula_operacao_int,
            saida    => ula_out,
            carry    => flag_carry,
            zero     => flag_zero,
            negativo => flag_negativo
        );


    acc_a_reg : entity work.reg16bit
        port map(
            clk      => clk,
            rst      => rst,
            wr_en    => acc_a_wr_en,
            data_in  => acc_a_in,
            data_out => acc_a
        );

    acc_b_reg : entity work.reg16bit
        port map(
            clk      => clk,
            rst      => rst,
            wr_en    => acc_b_wr_en,
            data_in  => acc_b_in,
            data_out => acc_b
        );

    -- Controle de escrita do registrador de instruções
    wr_en_instrucao <= '1' when estado = "10" else '0';

    reg_instrucao : entity work.reg19bit
    port map (
        clk      => clk,
        rst      => rst,
        wr_en    => wr_en_instrucao,
        data_in  => rom_data,
        data_out => instrucao_reg
    );

    instrucao <= instrucao_reg;


    ula_operacao_int <= "00" when (opcode = "0101" or opcode = "0011") else 
                        "01" when opcode = "0100" else 
                        "10" when opcode = "0111" else 
                        "11" when opcode = "1001" else 
                        "00";

    ula_result <= ula_out;
    flags      <= flag_carry & flag_zero & flag_negativo;
    instrucao  <= rom_data;


end architecture;