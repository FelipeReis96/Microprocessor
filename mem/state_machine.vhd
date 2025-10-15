library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity state_machine is 
    port (
        clk: in std_logic;
        rst: in std_logic;
        state_out: out std_logic
    );
end entity;

architecture behavioral of state_machine is
    signal state: std_logic;
begin
    process(clk, rst)
    begin
        if rst = '1' then
            state <= '0';
        elsif rising_edge(clk) then
            state <= not state;
        end if;
    end process;
    state_out <= state;
end architecture;
