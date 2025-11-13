library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processador is
    port (
        clk : in std_logic;
        rst : in std_logic;
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

    signal ddd : unsigned(2 downto 0);
    signal aaa : unsigned(2 downto 0);
    signal bbb : unsigned(2 downto 0);
    signal fff : unsigned(2 downto 0);
    signal imediato : unsigned(7 downto 0); 
    signal constante_sub : unsigned(5 downto 0);

    signal instrucao_reg : unsigned(18 downto 0);

    signal addi_const : unsigned(5 downto 0);

    -- Sinais RAM
    signal ram_addr  : unsigned(6 downto 0);
    signal ram_wr_en : std_logic;
    signal ram_din   : unsigned(15 downto 0);
    signal ram_dout  : unsigned(15 downto 0);
    signal sss       : unsigned(2 downto 0);  -- registrador fonte p/ SW

    signal flag_carry : std_logic;
    signal flag_zero : std_logic;
    signal flag_negativo : std_logic;

    -- Sinal para ser guardado em um registrador PSW
    signal flags_wr_en       : std_logic;
    signal psw_in_vec  : std_logic_vector(15 downto 0);
    signal psw_out     : unsigned(15 downto 0);
    signal flag_carry_l      : std_logic;
    signal flag_zero_l       : std_logic;
    signal flag_negativo_l   : std_logic;

   
    signal bhi_cond           : std_logic;              
    signal branch_offset6     : signed(5 downto 0);     -- eeeeee (signed)
    signal branch_offset7     : signed(6 downto 0);
    signal pc_plus1           : unsigned(6 downto 0);
    signal branch_target_rel  : unsigned(6 downto 0);   

begin
    uc_inst : entity work.control_unit
        port map (
            clk         => clk,
            rst         => rst,
            carry_in    => flag_carry_l,
            zero_in     => flag_zero_l,
            data_out_pc => pc_out,      
            dado_rom    => rom_data,
            estado_out  => estado
        );

    -- Decodificação dos campos da instrução
    opcode    <= std_logic_vector(instrucao_reg(18 downto 15)); 
    jump_addr <= ("0" & instrucao_reg(5 downto 0));                  
    ddd       <= instrucao_reg(14 downto 12);           -- destino (LOAD/LW)
    bbb       <= instrucao_reg(8 downto 6);             -- acumulador
    aaa       <= instrucao_reg(8 downto 6);             -- acumulador
    sss       <= instrucao_reg(8 downto 6);             -- SW: fonte (sss)

    -- fff depende do opcode (conforme especificação):
    -- SW: 0110 fff xxx sss xxxxxx  -> fff = 14..12
    -- LW: 1011 ddd xxx fff xxxxxx  -> fff = 8..6
    -- Demais (ex.: MOV A,R, ADD A,R): fff = 11..9
    with opcode select
        fff <= instrucao_reg(14 downto 12) when "0110",  -- SW: ponteiro
               instrucao_reg(8  downto 6 ) when "1011",  -- LW: ponteiro
               instrucao_reg(11 downto 9 ) when others;  -- MOV A,R / ADD A,R

    imediato      <= instrucao_reg(7 downto 0);
    constante_sub <= instrucao_reg(5 downto 0);
    addi_const    <= instrucao_reg(5 downto 0);

    pc_plus1       <= pc_out + 1;
    branch_offset6 <= signed(instrucao_reg(5 downto 0));
    branch_offset7 <= resize(branch_offset6, 7);
    -- Condição BHI desejada: após CMPI (A - X), se X > A ->  (carry=1) e não igual (zero=0)
    bhi_cond       <= '1' when (estado = "10" and opcode = "1110" and flag_zero = '0' and flag_carry = '1') else '0';
    branch_target_rel <= unsigned(signed(pc_plus1) + branch_offset7);

    -- Seleção dos acumuladores para entrada da ULA
    ula_entrada1 <= acc_a when bbb = "000" else acc_b;
    ula_entrada2 <= banco_out1 when (opcode = "1000" or opcode = "0101") else
                    ("0000000000" & constante_sub) when (opcode = "0100" or opcode = "1010") else
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
             '1' when (estado = "10" and opcode = "1011") else -- LW
             '0';

    -- Seleção do dado de escrita para o banco de registradores
    banco_wr_data <= ("00000000" & imediato) when (estado = "10" and opcode = "0001") else -- LOAD
                     acc_a       when (estado = "10" and opcode = "0010" and aaa = "000") else -- MOV R, A
                     acc_b       when (estado = "10" and opcode = "0010" and aaa = "001") else -- MOV R, B
                     ram_dout    when (estado = "10" and opcode = "1011") else -- LW
                     (others => '0');

    -- Seleção do endereço de escrita para o banco de registradores
    reg_wr_addr_int <= ddd when (estado = "10" and (opcode = "0001" or opcode = "0010" or opcode = "1011")) else 
                       (others => '0');

    -- Seleção do endereço de leitura do banco de registradores
    reg_rd_addr1_int <= fff when (opcode = "1000" or opcode = "0101" or 
                                   opcode = "1011" or opcode = "0110") else  -- +LW/SW (ponteiro)
                        (others => '0');
    reg_rd_addr2_int <= sss when (opcode = "0110") else  -- SW: fonte do dado
                        (others => '0');

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
                        "01" when (opcode = "0100" or opcode = "1010") else 
                        "10" when opcode = "0111" else 
                        "11" when opcode = "1001" else 
                        "00";

    ula_result <= ula_out;
    
    flags_wr_en <= '1' when (estado = "10" and 
                             (opcode = "0101" or -- ADD A,R
                              opcode = "0011" or -- ADDI A,const
                              opcode = "0100" or -- SUBI A,const
                              opcode = "1010" or -- CMPI A,const
                              opcode = "0111" or -- OR
                              opcode = "1001"))  -- AND
                   else '0';
    psw_in_vec <= (15 downto 3 => '0') & flag_carry & flag_zero & flag_negativo; -- [2]=C, [1]=Z, [0]=N

    psw : entity work.reg16bit
        port map(
            clk      => clk,
            rst      => rst,
            wr_en    => flags_wr_en,
            data_in  => unsigned(psw_in_vec),
            data_out => psw_out
        );

    flag_carry_l    <= psw_out(2);
    flag_zero_l     <= psw_out(1);
    flag_negativo_l <= psw_out(0);

 
    flags      <= flag_carry_l & flag_zero_l & flag_negativo_l;


    -- RAM: endereço vem do registrador ponteiro; dado para SW da porta 2
    ram_addr  <= banco_out1(6 downto 0);
    ram_din   <= banco_out2;
    ram_wr_en <= '1' when (estado = "10" and opcode = "0110") else '0';

    ram_inst : entity work.ram
        port map (
            clk      => clk,
            endereco => ram_addr,
            wr_en    => ram_wr_en,
            dado_in  => ram_din,
            dado_out => ram_dout
        );


end architecture;