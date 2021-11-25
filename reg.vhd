library ieee;
use ieee.std_logic_1164.all;

entity reg is
	port (
		clk: in std_logic;
		count: in integer;
		enReg: in std_logic;
		in_bit: in std_logic;
		reg_data: out std_logic_vector(7 downto 0)
	);
end entity;

architecture rtl of reg is
begin
	process(clk)
	begin
		if enReg = '1' then
			reg_data(7-count) <= in_bit;
		end if;
	end process;
end rtl;
