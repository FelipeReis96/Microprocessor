library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity reg7bit is
    port (
        clk     : in std_logic;
        rst     : in std_logic;
        wr_en   : in std_logic;
        data_in : in unsigned(6 downto 0);
        data_out: out unsigned(6 downto 0)
    );
end entity;

architecture behavioral of reg7bit is
    signal registro: unsigned(6 downto 0);
begin
    process(clk, rst, wr_en)
    begin
        if rst='1' then
            registro <= "0000000";
        elsif wr_en='1' then -- talvez inverter o condicional
            if rising_edge(clk) then
                registro <= data_in;
            end if;
        end if;
    end process;
    data_out <= registro;
end architecture;