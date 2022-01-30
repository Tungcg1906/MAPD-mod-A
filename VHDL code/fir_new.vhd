library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_filter_8 is
port (
	i_clk  : in  std_logic;
	i_rstb : in  std_logic; -- data valid in
	--valid : in std_logic;
	o_rstb : out std_logic; -- data valid out
	-- coeff
	i_co_0 : in  std_logic_vector(7 downto 0);
	i_co_1 : in  std_logic_vector(7 downto 0);
	i_co_2 : in  std_logic_vector(7 downto 0);
	i_co_3 : in  std_logic_vector(7 downto 0);
	i_co_4 : in  std_logic_vector(7 downto 0);
	i_co_5 : in  std_logic_vector(7 downto 0);
	i_co_6 : in  std_logic_vector(7 downto 0);
	i_co_7 : in  std_logic_vector(7 downto 0);
	-- in/out data
	i_data : in  std_logic_vector(7 downto 0);
	o_data : out std_logic_vector(7 downto 0));
end fir_filter_8;

architecture rtl of fir_filter_8 is

-- type declaration
type t_buffer   is array (0 to 7) of signed(7    downto 0);
type t_coeff    is array (0 to 7) of signed(7    downto 0);
type t_mult     is array (0 to 7) of signed(15   downto 0);
type t_add_0    is array (0 to 3) of signed(15+1 downto 0);
type t_add_1    is array (0 to 1) of signed(15+2 downto 0);

-- signal declaration
signal s_buffer : t_buffer := (others => (others => '0'));
signal s_coeff  : t_coeff  := (others => (others => '0'));
signal s_mult   : t_mult   := (others => (others => '0'));
signal s_add_0  : t_add_0  := (others => (others => '0'));
signal s_add_1  : t_add_1  := (others => (others => '0'));
signal s_add_2  : signed(15+3 downto 0) := (others => '0');

begin

p_input : process (i_rstb, i_clk)
begin

	if(rising_edge(i_clk)) then  -- inizialization

		if(i_rstb='1') then
			s_buffer   <= signed(i_data)&s_buffer(0 to s_buffer'length-2);
			s_coeff(0) <= signed(i_co_0);
			s_coeff(1) <= signed(i_co_1);
			s_coeff(2) <= signed(i_co_2);
			s_coeff(3) <= signed(i_co_3);
			s_coeff(4) <= signed(i_co_4);
			s_coeff(5) <= signed(i_co_5);
			s_coeff(6) <= signed(i_co_6);
			s_coeff(7) <= signed(i_co_7);

		else
			o_rstb <= '0';

		end if;

	end if;

end process p_input;

p_mult : process (i_rstb, i_clk)
begin
	if(i_rstb='0') then -- reset
		s_mult <= (others =>(others => '0'));
		o_rstb <= '0';


	elsif(rising_edge(i_clk)) then -- multiplication
		for i in 0 to 7 loop
			s_mult(i) <= s_buffer(i)*s_coeff(i);
		end loop;
	end if;
end process p_mult;

p_add_0 : process (i_rstb, i_clk)
begin
	if(i_rstb='0') then -- reset
		s_add_0 <= (others =>(others => '0'));
		o_rstb <= '0';

	elsif(rising_edge(i_clk)) then -- addition of 0-layer
		for i in 0 to 3 loop
			s_add_0(i) <= resize(s_mult(i*2),17) + resize(s_mult(i*2+1),17);
		end loop;
	end if;
end process p_add_0;

p_add_1 : process (i_rstb, i_clk)
begin
	if(i_rstb='0') then -- reset
		--s_add_1 <= (others =>(others => '0'));
			o_rstb <= '0';

	elsif(rising_edge(i_clk)) then -- addition of 1-layer
		for i in 0 to 1 loop
			s_add_1(i) <= resize(s_add_0(i*2),18) + resize(s_add_0(i*2+1),18);
		end loop;
	end if;
end process p_add_1;

p_add_2 : process (i_rstb, i_clk)
begin
	if(i_rstb='0') then -- reset
		s_add_2 <= (others => '0');
			o_rstb <= '0';
	elsif(rising_edge(i_clk)) then -- addition of 2-layer
		s_add_2 <= resize(s_add_1(0),19) + resize(s_add_1(1),19);
	end if;
end process p_add_2;

p_output : process (i_rstb, i_clk)
begin
	if(i_rstb='0') then --reset
		o_data <= (others => '0');
		o_rstb <= '0';
	elsif(rising_edge(i_clk)) then
		--o_data <= std_logic_vector(s_add_2(18 downto 11));
		o_data <= std_logic_vector(s_add_2(18)&s_add_2(14 downto 8));
		o_rstb <= '1';
	end if;
end process p_output;

end rtl;
