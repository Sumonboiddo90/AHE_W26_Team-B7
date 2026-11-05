
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_core is
    generic (
        G_WIDTH : positive := 8
    );

    port (
        clk     : in  std_logic;
        rst_n   : in  std_logic;
        enable  : in  std_logic;

        duty    : in  unsigned(G_WIDTH-1 downto 0);
        pwm_out : out std_logic
    );
end entity;

architecture rtl of pwm_core is

    signal cnt : unsigned(G_WIDTH-1 downto 0)
                 := (others => '0');

begin

    process(clk)
    begin
        if rising_edge(clk) then

            if rst_n = '0' then
                cnt <= (others => '0');
                pwm_out <= '0';

            else
                cnt <= cnt + 1;

                if enable = '1' and cnt < duty then
                    pwm_out <= '1';
                else
                    pwm_out <= '0';
                end if;

            end if;

        end if;
    end process;

end architecture;

