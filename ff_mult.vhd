library ieee;
use ieee.std_logic_1164.all;

entity ff_mult is 
	port (
		clk: in std_logic;
		reset: in std_logic;
		button: in std_logic;
		seven_segment: out std_logic_vector(7 downto 0);
		dss: out std_logic_vector(3 downto 0);
		rx: in std_logic;
		tx: out std_logic
	);
end entity;


architecture rtl of ff_mult is
	component fsm is
		port (
			clk: in std_logic;
			reset: in std_logic;
			send: in std_logic;
			seven_segment: out std_logic_vector(7 downto 0);
			rx: in std_logic;
			tx: out std_logic
		);
	end component;
begin
	-- sinyal langsung di pasang ke modul uart
	-- input dan output uart bakal dipasang ke modul uart
	dss <= "1110";
	controller: fsm
	port map(
		clk => clk,
		reset => reset,
		seven_segment => seven_segment,
		send => button,
		rx => rx,
		tx => tx
	);
	
end rtl;
