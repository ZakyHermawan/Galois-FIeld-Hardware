library ieee;
use ieee.std_logic_1164.all;

-- asynchronous circuit
entity lut is
	port(
		polinom: in std_logic_vector(7 downto 0);
		CP: out std_logic
	);
end entity;

architecture rtl of lut is
begin
	process(polinom) is
	begin
		case polinom is
			when "00000111" => CP <= '1';
			when "00001011" => CP <= '1';
			when "00010011" => CP <= '1';
			when "00100101" => CP <= '1';

			when "00110111" => CP <= '1';
			when "00111101" => CP <= '1';
			when "01000011" => CP <= '1';
			when "01100111" => CP <= '1';
					
			when "01101101" => CP <= '1';
			when "10000011" => CP <= '1';
			when "10001001" => CP <= '1';
			when "10001111" => CP <= '1';
					
			when "10011101" => CP <= '1';
			when "10111111" => CP <= '1';
			when "11001011" => CP <= '1';
			when "11010101" => CP <= '1';
					
			when "11100101" => CP <= '1';
			when "11110111" => CP <= '1';
					
			when others => CP <= '0';
		end case;
	end process;
end rtl;


