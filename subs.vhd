library ieee;
use ieee.std_logic_1164.all;

entity subs is
	port (
		Q: in std_logic_vector(7 downto 0);
		R: in std_logic_vector(7 downto 0);
		EnSubs: in std_logic;
		Qout: out std_logic_vector(7 downto 0)
	);
end entity;

architecture behavioral of subs is
begin
	Qout(7) <= (EnSubs AND (Q(7) XOR R(7))) OR ((NOT EnSubs) AND Q(7));
	Qout(6) <= (EnSubs AND (Q(6) XOR R(6))) OR ((NOT EnSubs) AND Q(6));
	Qout(5) <= (EnSubs AND (Q(5) XOR R(5))) OR ((NOT EnSubs) AND Q(5));
	Qout(4) <= (EnSubs AND (Q(4) XOR R(4))) OR ((NOT EnSubs) AND Q(4));
	Qout(3) <= (EnSubs AND (Q(3) XOR R(3))) OR ((NOT EnSubs) AND Q(3));
	Qout(2) <= (EnSubs AND (Q(2) XOR R(2))) OR ((NOT EnSubs) AND Q(2));
	Qout(1) <= (EnSubs AND (Q(1) XOR R(1))) OR ((NOT EnSubs) AND Q(1));
	Qout(0) <= (EnSubs AND (Q(0) XOR R(0))) OR ((NOT EnSubs) AND Q(0));
end behavioral;

