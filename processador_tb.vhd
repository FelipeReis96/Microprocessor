library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processador_tb is
end entity;

architecture testbench of processador_tb is
    component processador is
        port (
            clk : in std_logic;
            rst : in std_logic;
            instrucao : out unsigned(18 downto 0);
            ula_result : out unsigned(15 downto 0);
            flags : out std_logic_vector(2 downto 0);
            primos_out : out unsigned(15 downto 0)
        );
    end component;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal operacao : std_logic_vector(1 downto 0) := "00";
    signal ula_operacao : std_logic_vector(1 downto 0) := "00";
    signal reg_wr_addr : unsigned(2 downto 0) := "000";
    signal reg_rd_addr1 : unsigned(2 downto 0) := "000";
    signal reg_rd_addr2 : unsigned(2 downto 0) := "000";
    signal constante : unsigned(15 downto 0) := (others => '0');
    signal load_const : std_logic := '0';
    signal use_imediato : std_logic := '0';
    signal instrucao : unsigned(18 downto 0);
    signal ula_result : unsigned(15 downto 0);
    signal flags : std_logic_vector(2 downto 0);
    signal flag_carry    : std_logic;
    signal flag_zero     : std_logic;
    signal flag_negativo : std_logic;

    constant clk_period : time := 10 ns;
    signal stop_sim : boolean := false;
    signal primos_out_int : unsigned(15 downto 0);

begin
    uut: processador port map (
        clk => clk,
        rst => rst,
        instrucao => instrucao,
        ula_result => ula_result,
        flags => flags,
        primos_out => primos_out_int
    );

    -- Separar flags individuais
    flag_carry    <= flags(2);
    flag_zero     <= flags(1);
    flag_negativo <= flags(0);

    clk_process: process
    begin
        while not stop_sim loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
        wait;
    end process;

    stimulus: process
    begin
        rst <= '1';
        wait for clk_period; -- 1 ciclo de clock
        rst <= '0';
        -- ...continua a simulação...
        wait;
    end process;
end architecture;