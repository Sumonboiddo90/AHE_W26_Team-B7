-- top: static block design + one reconfigurable partition (instance u_rm)
library ieee;
use ieee.std_logic_1164.all;

entity top is
    port (
        CLK100MHZ    : in  std_logic;
        CPU_RESETN   : in  std_logic;
        UART_TXD_IN  : in  std_logic;   -- PC -> FPGA
        UART_RXD_OUT : out std_logic;   -- FPGA -> PC
        LED          : out std_logic_vector(15 downto 0)
    );
end entity top;

architecture rtl of top is

    -- Compare name and ports with your generated design_1_wrapper.vhd
    component design_1_wrapper is
        port (
            clk_in  : in  std_logic;
            resetn  : in  std_logic;
            rm_clk  : out std_logic;
            rm_din  : out std_logic_vector(15 downto 0);
            rm_dout : in  std_logic_vector(15 downto 0);
            uart_rx : in  std_logic;
            uart_tx : out std_logic
        );
    end component;

    component rm_a is
        port (
            clk  : in  std_logic;
            din  : in  std_logic_vector(15 downto 0);
            dout : out std_logic_vector(15 downto 0)
        );
    end component;

    signal rm_clk : std_logic;
    signal din    : std_logic_vector(15 downto 0);
    signal dout   : std_logic_vector(15 downto 0);

begin

    u_sys : design_1_wrapper
        port map (
            clk_in  => CLK100MHZ,
            resetn  => CPU_RESETN,
            uart_rx => UART_TXD_IN,
            uart_tx => UART_RXD_OUT,
            rm_clk  => rm_clk,
            rm_din  => din,
            rm_dout => dout
        );

    -- This instance becomes the reconfigurable partition
    u_rm : rm_a
        port map (
            clk  => rm_clk,
            din  => din,
            dout => dout
        );

    LED <= dout;

end architecture rtl;
