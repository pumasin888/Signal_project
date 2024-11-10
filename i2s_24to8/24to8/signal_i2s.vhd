library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity signal_i2s is
  port(
    clk         : in  std_logic;
    reset_n     : in  std_logic;
    l_data_rx   : out std_logic_vector(23 downto 16);
    r_data_rx   : out std_logic_vector(23 downto 16);
    mclk        : out std_logic;
    sclk        : out std_logic;
    ws          : out std_logic;
    sd_tx       : out std_logic;
    sd_rx       : in  std_logic
  );

end signal_i2s;

architecture behavior of signal_i2s is

  signal l_data_24bit : std_logic_vector(23 downto 0) := (others => '0');
  signal r_data_24bit : std_logic_vector(23 downto 0) := (others => '0');
  signal pll_clk      : std_logic;
  signal pll_sclk     : std_logic;
  signal pll_locked   : std_logic;


  signal scaled_l_data_rx : std_logic_vector(7 downto 0);
  signal scaled_r_data_rx : std_logic_vector(7 downto 0);

begin

  pll_inst : entity work.pll
    port map (
      inclk0 => clk,
      c0     => pll_clk,
      locked => pll_locked
    );

  mclk <= pll_clk when pll_locked = '1' else '0';
  sclk <= pll_sclk when pll_locked = '1' else '0';

  i2s_inst : entity work.i2s_transceiver
    generic map (
      mclk_sclk_ratio => 4,
      sclk_ws_ratio   => 64,
      d_width         => 24
    )
    port map (
      reset_n      => reset_n,
      mclk         => pll_clk,
      sclk         => pll_sclk,
      ws           => ws,
      sd_tx        => sd_tx,
      sd_rx        => sd_rx,
      l_data_tx    => l_data_24bit,
      r_data_tx    => r_data_24bit,
      l_data_rx    => l_data_24bit,
      r_data_rx    => r_data_24bit
    );


  scaled_l_data_rx <= l_data_24bit(23 downto 16);
  scaled_r_data_rx <= r_data_24bit(23 downto 16);


  l_data_rx <= scaled_l_data_rx;
  r_data_rx <= scaled_r_data_rx;

end behavior;
