library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
	
  port (
	 rdreq		  : in std_logic;
	 aclr			  : in std_logic;
    clock        : in  std_logic;
    uart_rxd_out : out std_logic;
	 sclock		  : out std_logic;
	 wss			  : out std_logic;
	 mic_in		  : in std_logic
  );
end entity top;

architecture str of top is

	component signal_i2s is
	port (
	    reset_n     : in  std_logic;
		 clk         : in  std_logic;
		 l_data_rx   : out std_logic_vector(7 downto 0);
		 mclk        : out std_logic;
		 sclk        : out std_logic;
		 ws          : out std_logic;
		 sd_rx       : in  std_logic
	  );
	 end component signal_i2s;
  
  component uart_transmitter is
    port (
      clock        : in  std_logic;
      data_to_send : in  std_logic_vector(7 downto 0);
      data_valid   : in  std_logic;
      busy         : out std_logic;
      uart_tx      : out std_logic
    );
  end component uart_transmitter;
  
  signal reset        : std_logic;
  signal busy         : std_logic;
  signal data_output_mic : std_logic_vector(7 downto 0);
  signal s_clk			 : std_logic;
  signal w_s			 : std_logic;
  signal data_valid_filter : std_logic;
  
  signal fifo_empty	 : std_logic;
  signal fifo_full	 : std_logic;
  signal fifo_rdreq	 : std_logic;
  signal fifo_wrreq	 : std_logic;
  signal uart_data_valid : std_logic;
  signal fifo_data_out	: std_logic_vector(7 downto 0);
  
  
  
begin 
	
  reset <= '1';
  
  
	fifo_wrreq <= '1';
	uart_data_valid <= '1' when (fifo_empty = '0' and busy = '0') else '0';
	fifo_rdreq <= '1' when (uart_data_valid = '1') else '0';
  
  i2s_gen     		: signal_i2s
		port map (
			clk		  => clock,
			sd_rx		  => mic_in,
			reset_n    => reset,
			l_data_rx  => data_output_mic,
			sclk		  => sclock,
			ws			  => w_s
		);
		
		wss <= w_s;	
			
		fifo : entity work.aekfifo
		 port map (
			aclr   => aclr,
			clock  => clock,
			data   => data_output_mic,
			rdreq  => rdreq and fifo_rdreq,
			wrreq  => fifo_wrreq,
			empty  => fifo_empty,
			full   => fifo_full,
			q      => fifo_data_out
		 );
		 
  uart_transmitter_1 : uart_transmitter 
    port map (
      clock        => clock,
      data_to_send => fifo_data_out,
      data_valid   => uart_data_valid,
      busy         => busy,
      uart_tx      => uart_rxd_out
    );	 
	 

end architecture str;
