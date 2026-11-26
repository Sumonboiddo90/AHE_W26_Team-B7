-- rm_c: swap upper and lower byte
library ieee;
use ieee.std_logic_1164.all;

entity rm_c is
    port (
        clk  : in  std_logic;
        din  : in  std_logic_vector(15 downto 0);
        dout : out std_logic_vector(15 downto 0)
    );
end entity rm_c;

architecture rtl of rm_c is
begin
    process (clk)
    begin
        if rising_edge(clk) then
            dout <= din(7 downto 0) & din(15 downto 8);
        end if;
    end process;
end architecture rtl;
