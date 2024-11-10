library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity signal_i2s_tb is
    generic (
        d_width : integer := 24
    );
end entity;

architecture behavior of signal_i2s_tb is
    signal clk        : std_logic := '0';
    signal reset_n    : std_logic := '0';
    signal sd_rx      : std_logic := '0';
    signal l_data_rx  : std_logic_vector(7 downto 0);
    signal mclk       : std_logic;
    signal sclk       : std_logic;
    signal ws         : std_logic;
    signal sd_tx      : std_logic;
    signal data_bit   : std_logic_vector(d_width-1 downto 0);
    constant clock_period : time := 20 ns;

    -- Function to convert character '0' or '1' to std_logic
    function to_stdlogic(c: character) return std_logic is
    begin
        if c = '1' then
            return '1';
        else
            return '0';
        end if;
    end function;

 -- Function to convert std_logic_vector to string with correct bit order
function slv_to_string(slv: std_logic_vector) return string is
    variable result : string(1 to slv'length);
begin
    for i in slv'range loop
        if slv(i) = '1' then
            result(slv'length - i) := '1';
        else
            result(slv'length - i) := '0';
        end if;
    end loop;
    return result;
end function;


begin
    uut: entity work.signal_i2s
        port map (
            clk        => clk,
            reset_n    => reset_n,
            l_data_rx  => l_data_rx,
            r_data_rx  => open,
            mclk       => mclk,
            sclk       => sclk,
            ws         => ws,
            sd_tx      => sd_tx,
            sd_rx      => sd_rx
        );

    -- Clock generation
    process
    begin
        while true loop
            clk <= not clk;
            wait for clock_period / 2;
        end loop;
    end process;

    -- Reset signal generation (active low)
    process
    begin
        reset_n <= '0';
        wait for 100 ns;
        reset_n <= '1';
        wait;
    end process;
	 

    -- Data transmission
    process
        -- Variables declared inside the process
        file data_file : text open read_mode is "input_data.txt";
        file output_file : text open write_mode is "output_l_data.txt";
        variable line_in : line;
        variable bit_string : string(1 to d_width);
        variable l_data_output : line;
    begin
        while not endfile(data_file) loop
            readline(data_file, line_in);
            read(line_in, bit_string);

            -- Convert the string to a std_logic_vector
            for i in 1 to d_width loop
                data_bit(d_width-i) <= to_stdlogic(bit_string(i));
            end loop;

            -- Wait for the falling edge of ws
            wait until falling_edge(ws);
            wait until falling_edge(sclk);
				wait until falling_edge(sclk);

            -- Send data serially to sd_rx for the left channel
            for i in d_width-1 downto 0 loop
                sd_rx <= data_bit(i);
                wait until falling_edge(sclk);
            end loop;

            -- Capture l_data_rx and write to output file
            write(l_data_output, slv_to_string(l_data_rx));
            writeline(output_file, l_data_output);
            wait for clock_period;
        end loop;
        wait;
    end process;

end architecture;
