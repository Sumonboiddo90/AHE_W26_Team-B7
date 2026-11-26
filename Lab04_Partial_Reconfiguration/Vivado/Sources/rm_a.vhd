-- rm_a: pass-through
library ieee;
use ieee.std_logic_1164.all;

entity rm_a is
    port (
        clk  : in  std_logic;
        din  : in  std_logic_vector(15 downto 0);
        dout : out std_logic_vector(15 downto 0)
    );
end entity rm_a;

architecture rtl of rm_a is
begin
    process (clk)
    begin
        if rising_edge(clk) then
            dout <= din;
        end if;
    end process;
end architecture rtl;
