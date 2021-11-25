library ieee;
use ieee.std_logic_1164.all;

entity clockdiv is
	port (
		clk: in std_logic;
		clk_out: buffer std_logic
	);
signal count: integer := 0;
signal div: integer := 2500000;
end entity;

architecture rtl of clockdiv is
begin 
	process(clk)
	begin
		if clk = '1' and clk'event then
			if count < div then
				count <= count + 1;
			else
				clk_out <= not clk_out;
				count <= 0;
			end if;
		end if;
	end process;
end;
