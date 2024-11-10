-- Testbench for the 'top' entity

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_top is
end entity tb_top;

architecture Behavioral of tb_top is

  -- Component Declaration for the Unit Under Test (UUT)
  component top is
    port (
      clock        : in  std_logic;
      uart_rxd_out : out std_logic;
      sclock       : out std_logic;
		l_data_out   : out std_logic_vector(7 downto 0);
      wss          : out std_logic;
		i2s_check_na : out std_logic_vector(7 downto 0);
      mic_in       : in  std_logic
    );
  end component;

  -- Signals to connect to UUT
  signal clock        : std_logic := '0';
  signal uart_txd_in  : std_logic := '1';
  signal uart_rxd_out : std_logic;
  signal sclock       : std_logic;
  signal wss          : std_logic;
  signal mic_in       : std_logic := '0';
  signal test_i2s		 : std_logic_vector(7 downto 0);
  signal l_data_test  : std_logic_vector(7 downto 0);

  -- Simulation control signal
  signal reset_n      : std_logic := '0';

begin

  -- Instantiate the Unit Under Test (UUT)
  uut: top
    port map (
      clock        => clock,
      uart_rxd_out => uart_rxd_out,
      sclock       => sclock,
		i2s_check_na => test_i2s,
		l_data_out   => l_data_test,
      wss          => wss,
      mic_in       => mic_in
    );

  -- Clock generation: 50 MHz clock (20 ns period)
  clock_process : process
  begin
    while true loop
      clock <= '0';
      wait for 10 ns;
      clock <= '1';
      wait for 10 ns;
    end loop;
  end process;

  -- Stimulus process
  stimulus_process : process
  begin
    -- Wait for global reset to de-assert
    wait for 100 ns;
    reset_n <= '1';

   -- Initialize mic_in
  mic_in <= '0';
  wait for 10000 ns;

  -- Create a while loop to toggle mic_in
  while true loop
    mic_in <= not mic_in; -- Toggle mic_in
    wait for 10000 ns;
  end loop;
    -- Continue simulation for some time
    wait for 1 ms;

    -- End simulation
    wait;
  end process;

end architecture Behavioral;