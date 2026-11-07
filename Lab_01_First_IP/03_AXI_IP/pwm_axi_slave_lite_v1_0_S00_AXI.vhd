-- ============================================================
-- pwm_axi_slave_lite_v1_0_S00_AXI.vhd
-- The "door and mailboxes" of the IP.
--   * AXI4-Lite slave with 4 registers (slv_reg0 .. slv_reg3)
--   * three pwm_core robots (red, green, blue)
--
-- Register map (byte offsets):
--   0x00  CTRL    bit 0 = 1 -> enable all PWM channels   (slv_reg0)
--   0x04  DUTY_R  bits 7:0  duty of the red channel      (slv_reg1)
--   0x08  DUTY_G  bits 7:0  duty of the green channel    (slv_reg2)
--   0x0C  DUTY_B  bits 7:0  duty of the blue channel     (slv_reg3)
-- ============================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_axi_slave_lite_v1_0_S00_AXI is
  generic (
    C_S_AXI_DATA_WIDTH : integer := 32;
    C_S_AXI_ADDR_WIDTH : integer := 4
  );
  port (
    -- Users to add ports here
    pwm_r : out std_logic;
    pwm_g : out std_logic;
    pwm_b : out std_logic;
    -- User ports ends

    S_AXI_ACLK    : in  std_logic;
    S_AXI_ARESETN : in  std_logic;
    S_AXI_AWADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
    S_AXI_AWVALID : in  std_logic;
    S_AXI_AWREADY : out std_logic;
    S_AXI_WDATA   : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_WSTRB   : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    S_AXI_WVALID  : in  std_logic;
    S_AXI_WREADY  : out std_logic;
    S_AXI_BRESP   : out std_logic_vector(1 downto 0);
    S_AXI_BVALID  : out std_logic;
    S_AXI_BREADY  : in  std_logic;
    S_AXI_ARADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
    S_AXI_ARVALID : in  std_logic;
    S_AXI_ARREADY : out std_logic;
    S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_RRESP   : out std_logic_vector(1 downto 0);
    S_AXI_RVALID  : out std_logic;
    S_AXI_RREADY  : in  std_logic
  );
end pwm_axi_slave_lite_v1_0_S00_AXI;

architecture arch_imp of pwm_axi_slave_lite_v1_0_S00_AXI is

  -- word address = address bits 3:2 (4 registers, 4 bytes each)
  constant ADDR_LSB : integer := (C_S_AXI_DATA_WIDTH/32) + 1;

  signal axi_awready : std_logic;
  signal axi_wready  : std_logic;
  signal axi_bvalid  : std_logic;
  signal axi_arready : std_logic;
  signal axi_rvalid  : std_logic;
  signal axi_rdata   : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal axi_araddr  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);

  -- the four mailboxes
  signal slv_reg0 : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal slv_reg1 : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal slv_reg2 : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal slv_reg3 : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);

  -- Keep old bits, replace only the bytes whose strobe bit is 1
  function apply_strobe (old_v : std_logic_vector;
                         new_v : std_logic_vector;
                         strb  : std_logic_vector) return std_logic_vector is
    variable r      : std_logic_vector(old_v'range) := old_v;
    variable nbytes : integer := old_v'length/8;
  begin
    for i in 0 to nbytes-1 loop
      if strb(i) = '1' then
        r(i*8+7 downto i*8) := new_v(i*8+7 downto i*8);
      end if;
    end loop;
    return r;
  end function;

begin

  -- connect internal signals to the outside
  S_AXI_AWREADY <= axi_awready;
  S_AXI_WREADY  <= axi_wready;
  S_AXI_BRESP   <= "00";          -- OKAY
  S_AXI_BVALID  <= axi_bvalid;
  S_AXI_ARREADY <= axi_arready;
  S_AXI_RDATA   <= axi_rdata;
  S_AXI_RRESP   <= "00";          -- OKAY
  S_AXI_RVALID  <= axi_rvalid;

  -- --------------------------------------------------------
  -- WRITE side: CPU puts a message into a mailbox
  -- --------------------------------------------------------
  write_proc : process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        axi_awready <= '0';
        axi_wready  <= '0';
        axi_bvalid  <= '0';
        slv_reg0    <= (others => '0');
        slv_reg1    <= (others => '0');
        slv_reg2    <= (others => '0');
        slv_reg3    <= (others => '0');
      else
        -- ready pulses last exactly one clock
        axi_awready <= '0';
        axi_wready  <= '0';
        if axi_awready = '0' and axi_wready = '0' and axi_bvalid = '0'
           and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' then
          axi_awready <= '1';
          axi_wready  <= '1';
        end if;

        -- the real handshake happens now: store the data
        if axi_awready = '1' and axi_wready = '1'
           and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' then
          case to_integer(unsigned(S_AXI_AWADDR(ADDR_LSB+1 downto ADDR_LSB))) is
            when 0 => slv_reg0 <= apply_strobe(slv_reg0, S_AXI_WDATA, S_AXI_WSTRB);
            when 1 => slv_reg1 <= apply_strobe(slv_reg1, S_AXI_WDATA, S_AXI_WSTRB);
            when 2 => slv_reg2 <= apply_strobe(slv_reg2, S_AXI_WDATA, S_AXI_WSTRB);
            when 3 => slv_reg3 <= apply_strobe(slv_reg3, S_AXI_WDATA, S_AXI_WSTRB);
            when others => null;
          end case;
          axi_bvalid <= '1';                       -- "message received"
        elsif axi_bvalid = '1' and S_AXI_BREADY = '1' then
          axi_bvalid <= '0';
        end if;
      end if;
    end if;
  end process;

  -- --------------------------------------------------------
  -- READ side: CPU reads a mailbox
  -- --------------------------------------------------------
  read_proc : process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        axi_arready <= '0';
        axi_rvalid  <= '0';
        axi_rdata   <= (others => '0');
        axi_araddr  <= (others => '0');
      else
        axi_arready <= '0';
        if axi_arready = '0' and S_AXI_ARVALID = '1' and axi_rvalid = '0' then
          axi_arready <= '1';
          axi_araddr  <= S_AXI_ARADDR;
        end if;

        if axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0' then
          axi_rvalid <= '1';
          case to_integer(unsigned(axi_araddr(ADDR_LSB+1 downto ADDR_LSB))) is
            when 0 => axi_rdata <= slv_reg0;
            when 1 => axi_rdata <= slv_reg1;
            when 2 => axi_rdata <= slv_reg2;
            when 3 => axi_rdata <= slv_reg3;
            when others => axi_rdata <= (others => '0');
          end case;
        elsif axi_rvalid = '1' and S_AXI_RREADY = '1' then
          axi_rvalid <= '0';
        end if;
      end if;
    end if;
  end process;

  -- --------------------------------------------------------
  -- Add user logic here: the three PWM robots
  -- --------------------------------------------------------
  u_pwm_r : entity work.pwm_core
    generic map (G_WIDTH => 8)
    port map (clk     => S_AXI_ACLK,
              rst_n   => S_AXI_ARESETN,
              enable  => slv_reg0(0),
              duty    => unsigned(slv_reg1(7 downto 0)),
              pwm_out => pwm_r);

  u_pwm_g : entity work.pwm_core
    generic map (G_WIDTH => 8)
    port map (clk     => S_AXI_ACLK,
              rst_n   => S_AXI_ARESETN,
              enable  => slv_reg0(0),
              duty    => unsigned(slv_reg2(7 downto 0)),
              pwm_out => pwm_g);

  u_pwm_b : entity work.pwm_core
    generic map (G_WIDTH => 8)
    port map (clk     => S_AXI_ACLK,
              rst_n   => S_AXI_ARESETN,
              enable  => slv_reg0(0),
              duty    => unsigned(slv_reg3(7 downto 0)),
              pwm_out => pwm_b);
  -- User logic ends

end arch_imp;
