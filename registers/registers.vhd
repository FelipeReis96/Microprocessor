library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registers is 
    port (
        clk: in STD_LOGIC; 
        reset: in STD_LOGIC;
        wr_en: in STD_LOGIC;
        reg_wr_addr: in std_logic_vector(2 downto 0);
        wr_data: in std_logic_vector(15 downto 0);
        reg_read_addr1 : in std_logic_vector(2 downto 0);
        reg_read_addr2 : in std_logic_vector(2 downto 0);
        data_r1     : out std_logic_vector(15 downto 0); 
        data_r2     : out std_logic_vector(15 downto 0)
    );
end entity;

architecture behavior of registers is 
    type registers_array is array (0 to 4) of unsigned(15 downto 0);

    signal reg_array : registers_array;
begin

    process(clk, reset)
    begin
        if reset = '1' then

            for i in 0 to 4 loop
                reg_array(i) <= (others => '0');
            end loop;
        elsif rising_edge(clk) then

            if wr_en = '1' then
                case reg_wr_addr is
                    when "000" => reg_array(0) <= unsigned(wr_data);
                    when "001" => reg_array(1) <= unsigned(wr_data);
                    when "010" => reg_array(2) <= unsigned(wr_data);
                    when "011" => reg_array(3) <= unsigned(wr_data);
                    when "100" => reg_array(4) <= unsigned(wr_data);
                    when others => null;
                end case;
            end if;
        end if;
    end process;

    -- Leitura assíncrona dos registradores
    data_r1 <= std_logic_vector(reg_array(0)) when reg_read_addr1 = "000" else
               std_logic_vector(reg_array(1)) when reg_read_addr1 = "001" else
               std_logic_vector(reg_array(2)) when reg_read_addr1 = "010" else
               std_logic_vector(reg_array(3)) when reg_read_addr1 = "011" else
               std_logic_vector(reg_array(4)) when reg_read_addr1 = "100" else
               (others => '0');

    data_r2 <= std_logic_vector(reg_array(0)) when reg_read_addr2 = "000" else
               std_logic_vector(reg_array(1)) when reg_read_addr2 = "001" else
               std_logic_vector(reg_array(2)) when reg_read_addr2 = "010" else
               std_logic_vector(reg_array(3)) when reg_read_addr2 = "011" else
               std_logic_vector(reg_array(4)) when reg_read_addr2 = "100" else
               (others => '0');
end behavior;
