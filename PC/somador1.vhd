library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity somador1 is 
    port (
        data_in: in unsigned(6 downto 0);  
        data_out: out unsigned(6 downto 0)  
    );
end entity;

architecture behavioral of somador1 is
    signal registro: unsigned(6 downto 0);
begin
    registro <= data_in + "0000001";
    data_out <= registro;
end architecture;