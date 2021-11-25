library ieee;
use ieee.std_logic_1164.all;

-- asynchronous circuit
entity ascii_conv is
	port (
		conv_toogle: in std_logic;
		orig_data: in std_logic_vector (7 downto 0); -- ascii yg akan didecode
		binary_in: in std_logic; -- 1 bit binary yg akan diencode ke ascii
		conv_data: out std_logic; -- data yang telah di decode
		ascii_out: out std_logic_vector(7 downto 0); -- ascii yg telah diencode
		conv_mode: in std_logic;
		out_ready: inout std_logic
	);
end entity;

architecture rtl of ascii_conv is
begin 
	process(conv_toogle)
	begin
		-- conv_mode = 1 artinya decode dari 8 bit binary ascii ke 1 bit binary 
		-- conv_mode = 0 artinya encode dari 1 bit binary ke 8 bit binary ascii
		if conv_mode = '1' then
			case orig_data is
				when "00110001" => conv_data <= '1';
				when "00110000" => conv_data <= '0';
				when others =>
			end case;
			out_ready <= '1';
		else
			if binary_in = '1' then
				ascii_out <= "00110001";
			else
				ascii_out <= "00110000";
			end if;
		end if;
		
	end process;
end rtl;
