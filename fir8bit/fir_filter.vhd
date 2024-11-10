library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use WORK.TYPES.ALL;

package TYPES is
  constant taps         : integer := 101;                                                         -- number of FIR coefficients
  constant coeff_width  : integer := 16;                                                         -- width of each FIR coefficient in fixed-point
  constant data_width   : integer := 8;                                                          -- width of input/output data
  constant frac_bits    : integer := 11;                                                         -- number of fractional bits for scaling
  constant result_width : integer := data_width + coeff_width + integer(ceil(log2(real(taps)))); -- width of FIR filter result
  
  -- Integer representation of fixed-point values with 11 fractional bits
  subtype fixed_point_type is integer range -2**(coeff_width-1) to 2**(coeff_width-1) - 1;

  type coeff_array   is array (0 to taps-1) of fixed_point_type;                                 -- array of FIR coefficients
  type data_array    is array (0 to taps-1) of signed(data_width-1 downto 0);                    -- array of data
  type product_array is array (0 to taps-1) of fixed_point_type;                                 -- array of (coefficient * data) products
  
end package TYPES;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
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

  -- Define the coefficients scaled by 2^frac_bits (11 fractional bits)
constant coeffs : coeff_array := (
integer(7.6110460686915e-05 * 2.0**frac_bits),
integer(6.218156561769517e-05 * 2.0**frac_bits),
integer(5.347877993531048e-06 * 2.0**frac_bits),
integer(-0.00010113296637765058 * 2.0**frac_bits),
integer(-0.00026528150849860176 * 2.0**frac_bits),
integer(-0.0004946057312683678 * 2.0**frac_bits),
integer(-0.0007937082971931348 * 2.0**frac_bits),
integer(-0.0011616625391892349 * 2.0**frac_bits),
integer(-0.0015896190014876694 * 2.0**frac_bits),
integer(-0.002059134111849069 * 2.0**frac_bits),
integer(-0.0025416718203892397 * 2.0**frac_bits),
integer(-0.0029996172242676617 * 2.0**frac_bits),
integer(-0.003388967108214279 * 2.0**frac_bits),
integer(-0.0036636435533671024 * 2.0**frac_bits),
integer(-0.0037811380149115783 * 2.0**frac_bits),
integer(-0.0037089637655774465 * 2.0**frac_bits),
integer(-0.0034312047698797617 * 2.0**frac_bits),
integer(-0.0029543268778736646 * 2.0**frac_bits),
integer(-0.00231138470342763 * 2.0**frac_bits),
integer(-0.001563827646739359 * 2.0**frac_bits),
integer(-0.0008002830171496216 * 2.0**frac_bits),
integer(-0.00013196273923442642 * 2.0**frac_bits),
integer(0.00031531946277604426 * 2.0**frac_bits),
integer(0.00041215337764800343 * 2.0**frac_bits),
integer(3.881244379112522e-05 * 2.0**frac_bits),
integer(-0.0009002778524282094 * 2.0**frac_bits),
integer(-0.0024622261646016913 * 2.0**frac_bits),
integer(-0.004652997777408102 * 2.0**frac_bits),
integer(-0.007417851967138386 * 2.0**frac_bits),
integer(-0.010636216511861718 * 2.0**frac_bits),
integer(-0.014122016565580788 * 2.0**frac_bits),
integer(-0.017630041505223192 * 2.0**frac_bits),
integer(-0.020868406076941824 * 2.0**frac_bits),
integer(-0.023516587821203975 * 2.0**frac_bits),
integer(-0.025247955466664498 * 2.0**frac_bits),
integer(-0.025755199174235296 * 2.0**frac_bits),
integer(-0.024776686246137592 * 2.0**frac_bits),
integer(-0.022121539348349088 * 2.0**frac_bits),
integer(-0.017691198849362676 * 2.0**frac_bits),
integer(-0.011495399631733006 * 2.0**frac_bits),
integer(-0.003660859456500717 * 2.0**frac_bits),
integer(0.005568484957359158 * 2.0**frac_bits),
integer(0.015840189657270368 * 2.0**frac_bits),
integer(0.026710717899887534 * 2.0**frac_bits),
integer(0.037670564965638316 * 2.0**frac_bits),
integer(0.04817541524177428 * 2.0**frac_bits),
integer(0.057681093389690574 * 2.0**frac_bits),
integer(0.06567969092039515 * 2.0**frac_bits),
integer(0.07173408688751293 * 2.0**frac_bits),
integer(0.07550815540874972 * 2.0**frac_bits),
integer(0.07679026046437214 * 2.0**frac_bits),
integer(0.07550815540874972 * 2.0**frac_bits),
integer(0.07173408688751293 * 2.0**frac_bits),
integer(0.06567969092039515 * 2.0**frac_bits),
integer(0.05768109338969057 * 2.0**frac_bits),
integer(0.04817541524177427 * 2.0**frac_bits),
integer(0.037670564965638316 * 2.0**frac_bits),
integer(0.026710717899887527 * 2.0**frac_bits),
integer(0.015840189657270368 * 2.0**frac_bits),
integer(0.0055684849573591575 * 2.0**frac_bits),
integer(-0.0036608594565007164 * 2.0**frac_bits),
integer(-0.011495399631733003 * 2.0**frac_bits),
integer(-0.017691198849362672 * 2.0**frac_bits),
integer(-0.022121539348349088 * 2.0**frac_bits),
integer(-0.02477668624613759 * 2.0**frac_bits),
integer(-0.025755199174235296 * 2.0**frac_bits),
integer(-0.025247955466664487 * 2.0**frac_bits),
integer(-0.02351658782120397 * 2.0**frac_bits),
integer(-0.020868406076941813 * 2.0**frac_bits),
integer(-0.017630041505223185 * 2.0**frac_bits),
integer(-0.014122016565580786 * 2.0**frac_bits),
integer(-0.010636216511861715 * 2.0**frac_bits),
integer(-0.0074178519671383855 * 2.0**frac_bits),
integer(-0.004652997777408099 * 2.0**frac_bits),
integer(-0.0024622261646016904 * 2.0**frac_bits),
integer(-0.0009002778524282092 * 2.0**frac_bits),
integer(3.88124437911252e-05 * 2.0**frac_bits),
integer(0.0004121533776480034 * 2.0**frac_bits),
integer(0.000315319462776044 * 2.0**frac_bits),
integer(-0.00013196273923442634 * 2.0**frac_bits),
integer(-0.0008002830171496216 * 2.0**frac_bits),
integer(-0.0015638276467393579 * 2.0**frac_bits),
integer(-0.00231138470342763 * 2.0**frac_bits),
integer(-0.0029543268778736615 * 2.0**frac_bits),
integer(-0.0034312047698797595 * 2.0**frac_bits),
integer(-0.0037089637655774417 * 2.0**frac_bits),
integer(-0.003781138014911574 * 2.0**frac_bits),
integer(-0.0036636435533671024 * 2.0**frac_bits),
integer(-0.003388967108214274 * 2.0**frac_bits),
integer(-0.00299961722426766 * 2.0**frac_bits),
integer(-0.0025416718203892363 * 2.0**frac_bits),
integer(-0.0020591341118490676 * 2.0**frac_bits),
integer(-0.0015896190014876694 * 2.0**frac_bits),
integer(-0.0011616625391892327 * 2.0**frac_bits),
integer(-0.0007937082971931343 * 2.0**frac_bits),
integer(-0.0004946057312683672 * 2.0**frac_bits),
integer(-0.0002652815084986016 * 2.0**frac_bits),
integer(-0.00010113296637765058 * 2.0**frac_bits),
integer(5.347877993531045e-06 * 2.0**frac_bits),
integer(6.218156561769517e-05 * 2.0**frac_bits),
integer(7.6110460686915e-05 * 2.0**frac_bits)
);

--constant coeffs : coeff_array := (
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits),
--integer(0.5 * 2.0**frac_bits)
--);

  signal data_pipeline : data_array := (others => (others => '0'));
  signal products      : product_array := (others => 0);
  signal result        : fixed_point_type := 0;

begin

  main : process (clock, reset) is
    variable result_accum : fixed_point_type := 0; -- Accumulator in fixed-point
  begin
    if reset = '0' then
      data_pipeline <= (others => (others => '0'));
      products      <= (others => 0);
      result        <= 0;

    elsif rising_edge(clock) then
      if valid_in = '1' then
        -- Shift data in the pipeline
        data_pipeline <= signed(data_in) & data_pipeline(0 to taps-2); -- shift in new input
        
        result_accum := 0; -- Initialize accumulator to zero

        -- Fixed-point multiplication and accumulation
        for i in 0 to taps-1 loop
          products(i) <= coeffs(i) * to_integer(data_pipeline(i));  -- Multiply coefficients with data
          result_accum := result_accum + products(i);               -- Accumulate the result
        end loop;

        -- Scale and convert final result to 8-bit output
        result <= result_accum / (2**frac_bits);                    -- Scale back to match data width
        data_out <= std_logic_vector(to_signed(result, data_width)); -- Convert to 8-bit signed integer
        valid_out <= '1';

      else
        valid_out <= '0';
      end if;
    end if;
  end process main;

end Behavioral;
