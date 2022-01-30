library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity top is

  port (

    CLK100MHZ    : in  std_logic;
    uart_txd_in  : in  std_logic;
    uart_rxd_out : out std_logic);

end entity top;

architecture str of top is
  signal clock            : std_logic;
  signal raw_data       : std_logic_vector(7 downto 0);
  signal filtered_data  : std_logic_vector(7 downto 0);
  signal raw_data_valid : std_logic;
  signal fil_data_valid : std_logic;
  signal busy           : std_logic;
  signal uart_tx        : std_logic;


  -- constant signals: value of the coefficients computed as python_coef*2^8 and then kept the integer part
  signal i_rstb    : std_logic;
  signal i_co_0 : std_logic_vector(7 downto 0) := std_logic_vector(to_signed(4,8));--X"B2";
  signal i_co_1 : std_logic_vector(7 downto 0) := std_logic_vector(to_signed(15,8));--X"01";
  signal i_co_2 : std_logic_vector(7 downto 0) := std_logic_vector(to_signed(42,8));--X"ff";
  signal i_co_3 : std_logic_vector(7 downto 0) := std_logic_vector(to_signed(65,8));--X"ff";
  signal i_co_4 : std_logic_vector(7 downto 0) := std_logic_vector(to_signed(65,8));--X"B2";
  signal i_co_5 : std_logic_vector(7 downto 0) := std_logic_vector(to_signed(42,8));--X"01";
  signal i_co_6 : std_logic_vector(7 downto 0) := std_logic_vector(to_signed(15,8));--X"ff";
  signal i_co_7 : std_logic_vector(7 downto 0) := std_logic_vector(to_signed(4,8));--X"ff";


  component uart_transmitter is
    port (
      clock           : in  std_logic;
      data_valid      : in  std_logic;
      data_to_send    : in  std_logic_vector(7 downto 0);
      uart_tx       : out std_logic;
      busy          : out std_logic);
  end component uart_transmitter;

  component uart_receiver is
    port (
      clock           : in  std_logic;
      uart_rx       : in  std_logic;
      received_data : out std_logic_vector(7 downto 0);
      valid         : out std_logic);
  end component uart_receiver;

  component fir_filter_8 is
    port
    (
        i_clk     : in std_logic;
        i_rstb 	  : in std_logic; -- data valid in
	      o_rstb : out std_logic; --data valid out
        i_co_0 : in std_logic_vector(7 downto 0);
        i_co_1 : in std_logic_vector(7 downto 0);
        i_co_2 : in std_logic_vector(7 downto 0);
        i_co_3 : in std_logic_vector(7 downto 0);
        i_co_4 : in std_logic_vector(7 downto 0);
        i_co_5 : in std_logic_vector(7 downto 0);
        i_co_6 : in std_logic_vector(7 downto 0);
        i_co_7 : in std_logic_vector(7 downto 0);
        i_data    : in std_logic_vector(7 downto 0);
        o_data    : out std_logic_vector(7 downto 0)
    );
  end component fir_filter_8;

begin  -- architecture str

  uart_receiver_1 : uart_receiver
    port map (
      clock        => CLK100MHZ,
      uart_rx    => uart_txd_in,
      received_data   => raw_data,
      valid      => raw_data_valid);

  fir_filter : fir_filter_8
    port map (
      i_clk => CLK100MHZ,
      i_rstb  => raw_data_valid,
      o_rstb => fil_data_valid,
      i_co_0 => i_co_0,
      i_co_1 => i_co_1,
      i_co_2 => i_co_2,
      i_co_3 => i_co_3,
      i_co_4 => i_co_4,
      i_co_5 => i_co_5,
      i_co_6 => i_co_6,
      i_co_7 => i_co_7,
      i_data => raw_data,
      o_data => filtered_data);

  uart_transmitter_1 : uart_transmitter
    port map (
      clock           => CLK100MHZ,
      data_valid      => fil_data_valid,
      data_to_send    => filtered_data,
      busy          => busy,
      uart_tx       => uart_rxd_out);


end architecture str;
