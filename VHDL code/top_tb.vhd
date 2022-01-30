library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;

entity top_tb is
end entity top_tb;

architecture test of top_tb is

constant c_CLKS_PER_BIT : integer := 867;
constant c_BIT_PERIOD   : time := 8670 ns;

signal clock    : std_logic := '0';
signal uart_in  : std_logic := '1';
signal uart_out : std_logic;
signal data     : std_logic_vector(7 downto 0);

procedure UART_WRITE_BYTE (
  i_data_in : in std_logic_vector(7 downto 0);
  signal o_serial : out std_logic) is
begin
  o_serial <= '0';
  wait for c_BIT_PERIOD;

  for i in 0 to 7 loop
    o_serial <= i_data_in(i);
    wait for c_BIT_PERIOD;
  end loop;

  o_serial <= '1';
  wait for c_BIT_PERIOD;
end UART_WRITE_BYTE;


begin
  DUT : entity work.top
  port map(
    CLK100MHZ    => clock,
    uart_txd_in  => uart_in,
    uart_rxd_out => uart_out);

  clock <= not clock after 5 ns;

  process is
  begin

    wait until rising_edge(clock);
    data<=std_logic_vector(to_signed(100,8));
    wait for c_BIT_PERIOD;
    UART_WRITE_BYTE(data,uart_in);
    wait for c_BIT_PERIOD;
    data<=std_logic_vector(to_signed(50,8));
    wait for c_BIT_PERIOD;
    UART_WRITE_BYTE(data,uart_in);
    wait for c_BIT_PERIOD;
    data<=std_logic_vector(to_signed(120,8));
    wait for c_BIT_PERIOD;
    UART_WRITE_BYTE(data,uart_in);
    wait for c_BIT_PERIOD;
    data<=std_logic_vector(to_signed(70,8));
    wait for c_BIT_PERIOD;
    UART_WRITE_BYTE(data,uart_in);
    wait for c_BIT_PERIOD;
    data<=std_logic_vector(to_signed(100,8));
    wait for c_BIT_PERIOD;
    UART_WRITE_BYTE(data,uart_in);
    wait for c_BIT_PERIOD;
    data<=std_logic_vector(to_signed(30,8));
    wait for c_BIT_PERIOD;
    UART_WRITE_BYTE(data,uart_in);
    wait for c_BIT_PERIOD;
    data<=std_logic_vector(to_signed(10,8));
    wait for c_BIT_PERIOD;
    UART_WRITE_BYTE(data,uart_in);
    wait for c_BIT_PERIOD;
    data<=std_logic_vector(to_signed(120,8));
    wait for c_BIT_PERIOD;
    UART_WRITE_BYTE(data,uart_in);
    wait for c_BIT_PERIOD;
    wait for 300 us;
    data<=std_logic_vector(to_signed(30,8));
    wait for c_BIT_PERIOD;
    UART_WRITE_BYTE(data,uart_in);
    wait for c_BIT_PERIOD;
    data<=std_logic_vector(to_signed(10,8));
    wait for c_BIT_PERIOD;
    UART_WRITE_BYTE(data,uart_in);
    wait for c_BIT_PERIOD;
    data<=std_logic_vector(to_signed(120,8));
    wait for c_BIT_PERIOD;
    UART_WRITE_BYTE(data,uart_in);
    wait for c_BIT_PERIOD;
  end process;

end architecture test;

configuration top_tb_test_cfg of top_tb is
  for test
  end for;
end top_tb_test_cfg;
