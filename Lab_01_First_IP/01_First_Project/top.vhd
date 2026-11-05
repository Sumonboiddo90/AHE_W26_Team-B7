
library ieee;
use ieee.std_logic_1164.all;

entity top is
    port (
        sw  : in  std_logic_vector(15 downto 0);
        led : out std_logic_vector(15 downto 0)
    );
end entity;

architecture rtl of top is

begin

    led <= sw;

end architecture;

