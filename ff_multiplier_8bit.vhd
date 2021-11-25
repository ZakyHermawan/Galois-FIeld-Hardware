library ieee;
USE ieee.std_logic_1164.all;

-- asynchronous circuit
entity ff_multiplier_8bit IS
	port (a, b	: in std_logic_vector (7 downto 0);
		  Qout	: out std_logic_vector (7 downto 0);
		  Pout	: buffer std_logic_vector (14 downto 0)); -- biar bisa diassign ke Qout
end entity;

architecture behavioral of ff_multiplier_8bit is
	
begin
	Pout(0) <= a(0) and b(0);
	Pout(1) <= (a(1) and b(0)) xor (a(0) and b(1));
	Pout(2) <= (a(2) and b(0)) xor (a(1) and b(1)) xor (a(0) and b(2));
	Pout(3) <= (a(3) and b(0)) xor (a(2) and b(1)) xor (a(1) and b(2)) xor
				  (a(0) and b(3));
	Pout(4) <= (a(4) and b(0)) xor (a(3) and b(1)) xor (a(2) and b(2)) xor
				  (a(1) and b(3)) xor (a(0) and b(4));
	Pout(5) <= (a(5) and b(0)) xor (a(4) and b(1)) xor (a(3) and b(2)) xor
				  (a(2) and b(3)) xor (a(1) and b(4)) xor (a(0) and b(5));
	Pout(6) <= (a(6) and b(0)) xor (a(5) and b(1)) xor (a(4) and b(2)) xor
				  (a(3) and b(3)) xor (a(2) and b(4)) xor (a(1) and b(5)) xor
				  (a(0) and b(6));
	Pout(7) <= (a(7) and b(0)) xor (a(6) and b(1)) xor (a(5) and b(2)) xor
				  (a(4) and b(3)) xor (a(3) and b(4)) xor (a(2) and b(5)) xor
				  (a(1) and b(6)) xor (a(0) and b(7));
	Pout(8) <= (a(7) and b(1)) xor (a(6) and b(2)) xor (a(5) and b(3)) xor
				  (a(4) and b(4)) xor (a(3) and b(5)) xor (a(2) and b(6)) xor
				  (a(1) and b(7));
	Pout(9) <= (a(7) and b(2)) xor (a(6) and b(3)) xor (a(5) and b(4)) xor
				  (a(4) and b(5)) xor (a(3) and b(6)) xor (a(2) and b(7));
	Pout(10)<= (a(7) and b(3)) xor (a(6) and b(4)) xor (a(5) and b(5)) xor
				  (a(4) and b(6)) xor (a(3) and b(7));
	Pout(11)<= (a(7) and b(4)) xor (a(6) and b(5)) xor (a(5) and b(6)) xor
				  (a(4) and b(7));
	Pout(12)<= (a(7) and b(5)) xor (a(6) and b(6)) xor (a(5) and b(7));
	Pout(13)<= (a(7) and b(6)) xor (a(6) and b(7));
	Pout(14)<= (a(7) and b(7));
	
	Qout(7) <= Pout(14);
	Qout(6) <= Pout(13);
	Qout(5) <= Pout(12);
	Qout(4) <= Pout(11);
	Qout(3) <= Pout(10);
	Qout(2) <= Pout(9);
	Qout(1) <= Pout(8);
	Qout(0) <= Pout(7);

end behavioral;
