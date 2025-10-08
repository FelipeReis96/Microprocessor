library ieee;
use ieee.std_logic_1164.all;

entity acumuladores is
    port (
        clk      : in std_logic;
        rst      : in std_logic;
        wr_en_A  : in std_logic;
        wr_en_B  : in std_logic;
        data_in_A: in std_logic_vector(15 downto 0);
        data_in_B: in std_logic_vector(15 downto 0);
        A_out    : out std_logic_vector(15 downto 0);
        B_out    : out std_logic_vector(15 downto 0)
    );
end entity;

architecture structural of acumuladores is
    signal reg_A : std_logic_vector(15 downto 0);
    signal reg_B : std_logic_vector(15 downto 0);
begin

    regA_inst : entity work.reg16bit
        port map (
            clk      => clk,
            rst      => rst,
            wr_en    => wr_en_A,
            data_in  => data_in_A,
            data_out => reg_A
        );


    regB_inst : entity work.reg16bit
        port map (
            clk      => clk,
            rst      => rst,
            wr_en    => wr_en_B,
            data_in  => data_in_B,
            data_out => reg_B
        );

    A_out <= reg_A;
    B_out <= reg_B;
end architecture;
