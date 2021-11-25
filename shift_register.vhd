library ieee;
use ieee.std_logic_1164.all;

entity shift_register is
	port (
		 --sinyal yg di assign kesini bisa dibaca dan ditulis
		Q: inout std_logic_vector(7 downto 0); -- Yang ingin di shift
		Last: in std_logic; -- Yang akan mengisi bit kosong setelah operasi shift
		LR: in std_logic; -- LR = 1, artinya left shift, LR = 0 artinya right shift
		EnShift: in std_logic; -- EnShift = 1 maka lakukan shift, EnShift = 0, Q = Qout
		Qout: out std_logic_vector(7 downto 0)
	);
end entity;

architecture behavioral of shift_register is
begin
	Qout (7) <= (EnShift AND ((LR AND Q(6)) OR ((NOT LR) AND Last))) OR ((NOT EnShift) AND Q(7));
	Qout (6) <= (EnShift AND ((LR AND Q(5)) OR ((NOT LR) AND Q(7)))) OR ((NOT EnShift) AND Q(6));
	Qout (5) <= (EnShift AND ((LR AND Q(4)) OR ((NOT LR) AND Q(6)))) OR ((NOT EnShift) AND Q(5));
	Qout (4) <= (EnShift AND ((LR AND Q(3)) OR ((NOT LR) AND Q(5)))) OR ((NOT EnShift) AND Q(4));
	Qout (3) <= (EnShift AND ((LR AND Q(2)) OR ((NOT LR) AND Q(4)))) OR ((NOT EnShift) AND Q(3));
	Qout (2) <= (EnShift AND ((LR AND Q(1)) OR ((NOT LR) AND Q(3)))) OR ((NOT EnShift) AND Q(2));
	Qout (1) <= (EnShift AND ((LR AND Q(0)) OR ((NOT LR) AND Q(2)))) OR ((NOT EnShift) AND Q(1));
	Qout (0) <= (EnShift AND ((LR AND Last) OR ((NOT LR) AND Q(1)))) OR ((NOT EnShift) AND Q(0));
end behavioral;

