
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_pwm is
end entity;

architecture sim of tb_pwm is

    constant W : positive := 4;

    signal clk     : std_logic := '0';
    signal rst_n   : std_logic := '0';
    signal enable  : std_logic := '0';
    signal pwm_out : std_logic := '0';

    signal duty : unsigned(W-1 downto 0)
                  := to_unsigned(15, W);

begin

    -- Clock generation: 10 ns period
    clk <= not clk after 5 ns;

    -- Device Under Test
    dut : entity work.pwm_core
        generic map (
            G_WIDTH => W
        )
        port map (
            clk     => clk,
            rst_n   => rst_n,
            enable  => enable,
            duty    => duty,
            pwm_out => pwm_out
        );

    -- Test process
    process

        variable n : natural := 0;

    begin

        -- Keep reset active initially
        wait for 20 ns;

        -- Release reset and enable PWM
        rst_n <= '1';
        enable <= '1';

        -- Sample 16 consecutive clock cycles
        wait until rising_edge(clk);
        wait for 1 ns;

        for i in 0 to 15 loop

            if pwm_out = '1' then
                n := n + 1;
            end if;

            if i < 15 then
                wait until rising_edge(clk);
                wait for 1 ns;
            end if;

        end loop;

        -- Verify expected duty
        assert n = 15
            report "Duty error"
            severity failure;

        report "TEST PASSED";

        wait;

    end process;

end architecture;
