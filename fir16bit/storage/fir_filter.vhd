-- Design and implementation of a reconfigurable FIR filter in FPGA
-- Students: Nagaro Gianmarco, Ninni Daniele, Rodrigues Vero Filho Emerson, Valentini Lorenzo

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

package TYPES is

  constant taps         : integer := 35;                                                         -- number of FIR coefficients
  constant coeff_width  : integer := 8;                                                          -- width of each FIR coefficient
  constant data_width   : integer := 8;                                                          -- width of input/output data
  constant result_width : integer := data_width + coeff_width + integer(ceil(log2(real(taps)))); -- width of FIR filter result
  
  type coeff_array   is array (0 to taps-1) of std_logic_vector(coeff_width-1 downto 0);         -- array of FIR coefficients
  type data_array    is array (0 to taps-1) of signed(data_width-1 downto 0);                    -- array of data
  type product_array is array (0 to taps-1) of signed((data_width + coeff_width)-1 downto 0);    -- array of (coefficient * data) products
  
end package TYPES;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use WORK.TYPES.ALL;

entity fir_filter is
  port (clock     : in  std_logic;
        reset     : in  std_logic;
        data_in   : in  std_logic_vector(data_width-1 downto 0);
        valid_in  : in  std_logic;
        data_out  : out std_logic_vector(data_width-1 downto 0);
        valid_out : out std_logic);
end fir_filter;

architecture Behavioral of fir_filter is

--	constant coeffs : coeff_array := (
--"00000001",
--"00000001",
--"00000001",
--"00000001",
--"00000001",
--"00000010",
--"00000010",
--"00000011",
--"00000011",
--"00000100",
--"00000101",
--"00000101",
--"00000110",
--"00000110",
--"00000110",
--"00000111",
--"00000111",
--"00000111",
--"00000111",
--"00000111",
--"00000110",
--"00000110",
--"00000110",
--"00000101",
--"00000101",
--"00000100",
--"00000011",
--"00000011",
--"00000010",
--"00000010",
--"00000001",
--"00000001",
--"00000001",
--"00000001",
--"00000001"
--	);

	
	constant coeffs : coeff_array := (
	"00000000","00000000","00000000","00000000",
	"00000000","00000000","00000000","00000000",
	"00000000","00000000","00000000","00000000",
	"00000000","00000000","00000000","00000000",
	"00000000","00000000","00000000","00000000",
	"00000000","00000000","00000000","00000000",
	"00000000","00000000","00000000","00000000",
	"00000000","00000000","00000000","00000000",
	"00000000","00000000","00000000"
	);


  signal data_pipeline : data_array    := (others => (others => '0'));
  signal products      : product_array := (others => (others => '0'));

begin

  main : process (clock, reset) is
  
  variable result : signed(result_width-1 downto 0);
  
  begin -- process main
    if reset = '0' then
    
      data_pipeline <= (others => (others => '0'));
      products      <= (others => (others => '0'));
      result        := (others => '0'); 
  
    elsif rising_edge(clock) then
    
      if valid_in = '1' then
  
        data_pipeline <= signed(data_in) & data_pipeline(0 to taps-2); -- shift old data inside data_pipeline to insert data_in
        
        result := (others => '0');                                     -- initialize result to 0
        for i in 0 to taps-1 loop                                      -- for each FIR coefficient
          products(i) <= signed(coeffs(i)) * data_pipeline(i);         -- compute product
          result      := result + products(i);                         -- add product to result
        end loop;
        
        data_out  <= std_logic_vector(resize(shift_right(result, data_width-1), data_width));
        valid_out <= '1';
        
      else
        
        valid_out <= '0';
        
      end if;
    end if;
  end process main;

end Behavioral;

--
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
--
--entity FIR_Filter is
--    Port ( clk     : in  std_logic;
--           reset   : in  std_logic;
--           data_in : in  std_logic_vector(7 downto 0);
--           data_out: out std_logic_vector(7 downto 0));
--end FIR_Filter;
--
--architecture Behavioral of FIR_Filter is
--
--    -- Define the filter coefficients here (for illustration, these are placeholders)
--    -- Replace with actual coefficients, properly scaled for your application
--    constant COEFFS : array (0 to 34) of integer := (1, -1, 2, -2, 3, -3, 4, -4, 5, -5,
--                                                     6, -6, 7, -7, 8, -8, 9, -9, 10, -10,
--                                                     11, -11, 12, -12, 13, -13, 14, -14, 15, -15,
--                                                     16, -16, 17, -17, 18);
--
--    -- Shift register for input samples
--    signal x : array (0 to 34) of integer := (others => 0);
--
--    -- Accumulator for the filter output
--    signal acc : integer := 0;
--
--begin
--
--    process(clk)
--    begin
--        if rising_edge(clk) then
--            if reset = '1' then
--                -- Reset all shift registers and output
--                x <= (others => 0);
--                acc <= 0;
--                data_out <= (others => '0');
--            else
--                -- Shift the input data into the shift register
--                for i in 34 downto 1 loop
--                    x(i) <= x(i - 1);
--                end loop;
--                x(0) <= to_integer(unsigned(data_in));
--
--                -- Accumulate the output by multiplying and summing
--                acc := 0;
--                for i in 0 to 34 loop
--                    acc := acc + x(i) * COEFFS(i);
--                end loop;
--
--                -- Output the result with rounding or truncation as needed
--                if acc > 127 then
--                    data_out <= "01111111"; -- Cap to max 8-bit value
--                elsif acc < -128 then
--                    data_out <= "10000000"; -- Cap to min 8-bit value
--                else
--                    data_out <= std_logic_vector(to_signed(acc, 8)); -- Convert to 8-bit output
--                end if;
--            end if;
--        end if;
--    end process;
--
--end Behavioral;
