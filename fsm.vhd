library ieee;
use ieee.std_logic_1164.all;

entity fsm is
	port (
		clk: in std_logic;
		reset: in std_logic;
		send: in std_logic;
		seven_segment: out std_logic_vector(7 downto 0);
		rx: in std_logic;
		tx: out std_logic
	);
end entity;

architecture rtl of fsm is
	
	-- asynchronous circuit
	component lut is
		port (
			polinom: in std_logic_vector(7 downto 0);
			CP: out std_logic
		);
	end component;
	
	component uart is
		port(
			clk 			: in std_logic;
			rst_n 		: in std_logic;
				
			send 			: in std_logic;
			send_data	: in std_logic_vector(7 downto 0) ;
			receive 		: out std_logic;
			receive_data: out std_logic_vector(7 downto 0) ;
				
			rs232_rx 	: in std_logic;
			rs232_tx 	: out std_logic
		);
	end component;
	
	-- asynchronous circuit
	component ff_multiplier_8bit is
		port (
			a: in std_logic_vector(7 downto 0);
			b: in std_logic_vector(7 downto 0);
			Qout: out std_logic_vector (7 downto 0);
			Pout: out std_logic_vector(14 downto 0)
		);
	end component;
	
	component subs is 
		port (
			Q: in std_logic_vector(7 downto 0);
			R: in std_logic_vector(7 downto 0);
			EnSubs: in std_logic;
			Qout: out std_logic_vector(7 downto 0)
		);
	end component;

	component shift_register is
		port (
			Q: inout std_logic_vector(7 downto 0); 
			Last: in std_logic; 
			LR: in std_logic; 
			EnShift: in std_logic; 
			Qout: out std_logic_vector(7 downto 0)

		);
	end component;
	
	type state is (
		S_C, S_L, S_A, S_B, S_0, S_1, S_R, S_2, S_Q, S_3, S_Sub, S_4, S_Y,
		Send1, Send2, Send3, Send4, Send5, Send6, Send7, Send8
	);
	signal CS: state; -- current state
	
	------------------------------------------------------------------------------------------------------------
	-- Sinyal untuk ascii converter
	------------------------------------------------------------------------------------------------------------
	signal count: integer:= 0; -- karena input 1101 akan diterima secara berurut jadi 1 1 0 1, 
										-- jadi input pertama diisi dari paling kiri

	------------------------------------------------------------------------------------------------------------
	-- Sinyal untuk register A
	------------------------------------------------------------------------------------------------------------
	signal regA: std_logic_vector(7 downto 0); -- register A
	
	------------------------------------------------------------------------------------------------------------
	-- Sinyal untuk register B
	------------------------------------------------------------------------------------------------------------
	signal regB: std_logic_vector(7 downto 0); -- register B
	
	------------------------------------------------------------------------------------------------------------
	-- Sinyal untuk register C
	------------------------------------------------------------------------------------------------------------
	signal regC: std_logic_vector(7 downto 0); -- register C
	
	------------------------------------------------------------------------------------------------------------
	-- Sinyal untuk lookup table
	------------------------------------------------------------------------------------------------------------
	signal polinom: std_logic_vector(7 downto 0);
	signal CP: std_logic:= 'U';
	
	------------------------------------------------------------------------------------------------------------
	-- Sinyal untuk modul UART
	------------------------------------------------------------------------------------------------------------
	signal send_data: std_logic_vector(7 downto 0);
	signal receive: std_logic;
	signal receive_data: std_logic_vector (7 downto 0);
	signal receive_c: std_logic;

	------------------------------------------------------------------------------------------------------------
	-- Sinyal untuk modul ff__8bit
	------------------------------------------------------------------------------------------------------------
	signal a_in: std_logic_vector(7 downto 0);
	signal b_in: std_logic_vector(7 downto 0);
	signal QMult_out: std_logic_vector(7 downto 0);
	signal PMult_out: std_logic_vector(14 downto 0);
	
	------------------------------------------------------------------------------------------------------------
	-- Sinyal untuk shift register
	------------------------------------------------------------------------------------------------------------
	signal InShift: std_logic_vector(7 downto 0); -- yang akan masuk ke shift register
	signal OutShift: std_logic_vector(7 downto 0); -- hasil dari shift register
	signal Shout: std_logic_vector(7 downto 0); -- simpan output dari shift register
	signal EnShift: std_logic;
	signal LR: std_logic;
	signal Last: std_logic;
	
	------------------------------------------------------------------------------------------------------------
	-- Sinyal untuk Subs
	------------------------------------------------------------------------------------------------------------
	signal InSubs: std_logic_vector(7 downto 0);
	signal OutSubs: std_logic_vector(7 downto 0);
	signal Suout: std_logic_vector(7 downto 0);
	signal EnSubs: std_logic;
	
	------------------------------------------------------------------------------------------------------------
	-- Sinyal untuk FSM
	------------------------------------------------------------------------------------------------------------
	signal Q: std_logic_vector(7 downto 0); -- 7 bit yang akan di xor dengan basis
	signal R: std_logic_vector(7 downto 0); -- basis (C(x))
	signal cnt: integer:= 0; -- banyaknya operasi sub yang harus dilakukan
	signal N: integer:= 0; -- derajat polinom maksimal
	signal Y: std_logic_vector(7 downto 0); -- output hasil perkalian finite field berbasis polinom
	signal temp_btn: std_logic;
	signal delay_ctr: integer := 0;
	signal ctr_start: std_logic := '0';
begin
	
	lookup_table: lut
	port map(
		polinom => polinom,
		CP => CP
	);
	
	uart_module: uart -- modul uart
	port map (
		clk => clk,
		rst_n => reset,
		send => send,
		send_data => send_data,
		receive => receive,
		receive_data => receive_data,
		rs232_rx => rx,
		rs232_tx => tx
	);
	
	multiplier: ff_multiplier_8bit -- 8 bit finite field multiplier
	port map(
		a => a_in, 
		b => b_in,
		Qout => QMult_out, -- 8 bit hasil perkalian dari yang paling kiri
		Pout => PMult_out -- hasil perkalian (15 bit)
	);
	
	shifter: shift_register
	port map (
		Q => InShift, -- 8 bit input buat di shift
		Last => Last, -- untuk mengisi kekosongan bit
		LR => LR, -- menentukan apakah right shift atau left shift
		EnShift => EnShift, -- enable shift
		Qout => OutShift -- output shift
	);

	subs_block: subs -- operasi pengurangan pada finite field (xor) untuk mencari sisa 
	port map(
		Q => InSubs, -- yang ingin dicari sisanya (8 bit)
		R => R, -- basis polinom (8 bit)
		EnSubs => EnSubs, -- enable signal
		Qout => OutSubs -- hasil xor
	);
	
	Suout <= OutSubs;
	Shout <= OutShift;
	
	process(clk)
	begin

		if reset = '0' then
			seven_segment <= "10111111";
			CS <= S_C;
			count <= 0;
			delay_ctr <= 0;
			ctr_start <= '0';
		else
		if clk = '1' and clk'event then
			case CS is
				when S_C => -- masukkan basis, cek apakah primitif atau tidak
					seven_segment <= "11000110"; -- LED: C
					send_data <= "00110000"; -- reset, buat validasi
					if count = 8 then
						-- kasih delay
						if delay_ctr = 0 then -- masukkan nilai regC, dan cen di lookup table
							polinom <= regC;
						end if;
						if delay_ctr >= 100 then -- kasih delay buat nunggu lookup table selesai
							delay_ctr <= 0;
							count <= 0;
							CS <= S_L;
						else
							delay_ctr <= delay_ctr + 1;
							CS <= S_C;
						end if;
					else
						receive_c <= receive; -- detect start bit
						if receive = '0' and receive_c = '1' then -- start bit detected!
							-- karena input mulai dari polinom paling kiri
							-- masukkan dari yang paling kiri
							if receive_data = "00110001" then -- langsung proses!
								regC(7-count) <= '1'; -- masukkan dari yang paling kiri
							else
								regC(7-count) <= '0';
							end if;
							count <= count + 1;
						end if;
						CS <= S_C;
					end if;
				when S_L => 
					if CP = '1' then -- polinom primitif, lanjut masukkan polinom pertama
						send_data <= "00110001"; -- kirim ascii 1
						CS <= S_A;
					else -- polinom tidak primitif, balik ke state C, minta input basis lagi
						send_data <= "00110000"; -- kirim ascii 0
						CS <= S_C;
					end if;
				when S_A =>
					seven_segment <= "10001000"; -- LED: A
					if count = 8 then -- kalo udah nerima 8 bit, masukkan polinom kedua
						count <= 0;
						CS <= S_B;
					else
						receive_c <= receive; 
						if receive = '0' and receive_c = '1' then -- start bit detected!
							-- karena input mulai dari polinom paling kiri
							-- masukkan dari yang paling kiri
							if receive_data = "00110001" then
								regA(7-count) <= '1';
							else
								regA(7-count) <= '0';
							end if;
							count <= count + 1;
						end if;
						CS <= S_A;
					end if;
				when S_B =>
					seven_segment <= "10000011"; -- LED: B
					if count = 8 then -- kalo udah nerima 8 bit, langsung hitung perkalian
						count <= 0;
						a_in <= regA;
						b_in <= regB;
						CS <= S_0;
					else
						receive_c <= receive;
						if receive = '0' and receive_c = '1' then
							-- karena input mulai dari polinom paling kiri
							-- masukkan dari yang paling kiri
							if receive_data = "00110001" then
								regB(7-count) <= '1';
							else
								regB(7-count) <= '0';
							end if;
							count <= count + 1;
						end if;
						CS <= S_B;
					end if;
				when S_0 => -- mulai operasi perkalian pada finite field
					-- inisiasi semua sinyal yang diperlukan
					seven_segment <= "11000000";
					Y <= "00000000";
					N <= 8; -- ada 8 bit karena derajat maksimalnya 7 (x^7)
					cnt <= 0; -- buat nentuin udah di shift berapa kali
					R <= regC; -- polinom basis
					Q <= QMult_Out; -- 8 bit paling kiri hasil perkalian, akan
										 -- di xor dengan basis pada operasi subs
					CS <= S_1; -- pindah ke state 1

					EnShift <= '0';
					EnSubs <= '0';
				when S_1 =>
					if R(7) = '0' then -- kalO digit paling kiri basis belum 1, left shifts
						InShift <= R; -- masukkan basis yang akan di shift
						Last <= '0'; -- ganti bit paling kanan (setelah shift) dengan 0
						LR <= '1'; -- left shift
						EnShift <= '1'; -- enable shift (lakukan operasi shift)
						EnSubs <= '0';
						CS <= S_R; -- pindah ke state R
					else
						EnShift <= '0';
						EnSubs <= '0';
						CS <= S_2;
					end if;
				when S_R => -- yang terjadi ketika basis di left shift
								-- operasi left shift analog dengan basis yang dikali x
					R <= Shout; -- simpan hasil left shift
					N <= N + 1; -- geser ke kiri, karena derajat maksimalnya 
									-- sekarang jadi N + 1, karena misal (x^3+x^2+1) * x = (x^4+x^3+x) 
					CS <= S_1; -- pindah ke state 1 untuk mengetahui apakah perlu left shift lagi
				when S_2 => -- buat shifting setelah subs dilakukan
					if cnt > 0 then -- kalo gapernah subs, langsung subs aja, tapi kalo udah
										 -- lakukan shift left pada Q agar bisa melakukan 
										 -- operasi subs selanjutnya
						InShift <= Q; -- shift left Q
						case cnt is
							when 1 => Last <= PMult_out(6); -- P 0--7 sudah digunakan, gunakan P(8)
							when 2 => Last <= PMult_out(5); -- P 0--8 sudah digunakan, gunakan P(9)
							when 3 => Last <= PMult_out(4); -- dst
							when 4 => Last <= PMult_out(3);
							when 5 => Last <= PMult_out(2);
							when 6 => Last <= PMult_out(1);
							when 7 => Last <= PMult_out(0);
							when others => Last <= '0'; -- ngisi kekosongan ketika shift left
						end case;
						LR <= '1'; -- shift left
						EnShift <= '1'; -- enable operasi shift left
						EnSubs <= '0';
						CS <= S_Q;
					else -- kalo cnt = 0, artinya belum pernah ngelakuin operasi subs
						  -- langusng subs aja
						EnShift <= '0';
						EnSubs <= '0';
						CS <= S_3; -- operasi subs dilakukan di S_3
					end if;
				when S_Q => -- simpan hasil Q setelah di left shift
					Q <= Shout;
					CS <= S_3; -- lakukan subs
				when S_3 => 
					if Q(7) = '1' then -- hanya lakukan xor jika bit paling kiri Q adalah 1
						InSubs <= Q;
						EnShift <= '0';
						EnSubs <= '1';
					else -- kalo bit paling kiri Q engga 0, jagnan di xor, tapi ttp diitung
						  -- sudah ngelakuin operasi subs
						EnShift <= '0';
						EnSubs <= '0';
					end if;
					CS <= S_Sub;
				when S_Sub => -- subs stands for substract, tapi sebenarnya hanya xor
								  -- karena kita melakukan operasi pada finite field
								  -- apakah subs akan dulang ?
					if cnt < N then -- subs dilakukan jika cnt = 0 hingga cnt = N-1
										 -- jadi bakal ada N kali subs
						if EnSubs = '1' then --  kalo operasi xornya beneran dilakuin, 
													-- simpan hasil hasilnya
							Q <= Suout;
						end if;
						cnt <= cnt + 1;
						CS <= S_2; 
					else
						CS <= S_4; -- kalo sudah N kali operasi subs
					end if;
				when S_4 => -- karena tadi basisnya kita left shift, maka hasilnya
								-- juga harus di right shift, karena ujung kann pada reg Q
								-- masih ada 0 yang sebenarnya tidak kita pedulikan
					if N >= 8 then -- shift right balik
						InShift <= Q;
						Last <= '0';
						LR <= '0';
						
						EnShift <= '1';
						EnSubs <= '0';
						CS <= S_Y;
					else
						EnShift <= '0';
						EnSubs <= '0';
						
						Y <= Q;
						CS <= Send1;
					end if;
				when S_Y => 
					Q <= Shout;
					N <= N - 1;
					CS <= S_4;
				when Send1 => -- kirim mulai dari bit paling kiri dari hasil (Y)
					
					-- hasil direpresentasikan pada seven segment
					-- koefisien 0 akan membuat segment tersebut menyala
					-- koefisien 1 akan membuat seven segment tersebut mati
					-- a merepresentasikan nilai 1
					-- b merepresentasikan nilai x
					-- c merepresentasikan nilai x^2
					-- d merepresentasikan nilai x^3
					-- e merepresentasikan nilai x^4
					-- f merepresentasikan nilai x^5
					-- g merepresentasikan nilai x^6
					-- dot merepresentasikan nilai x^7
					seven_segment <= Y;
					temp_btn <= send;
					
					if Y(7) = '1' then
						send_data <= "00110001";
					else
						send_data <= "00110000";
					end if;
					-- send_data <= data yg ingin dikirim
					-- data akan terkirim bila button ditekan
					-- kalo udah dikirim, pindah state, tapi delay dulu
					if ctr_start = '1' or (send = '0' and temp_btn = '1') then
						-- kasih delay
						if delay_ctr >= 100000 then
							delay_ctr <= 0;
							ctr_start <= '0';
							CS <= Send2;
						else
							delay_ctr <= delay_ctr + 1;
							ctr_start <= '1';
							CS <= Send1;
						end if;
					else
						CS <= Send1;
					end if;
				when Send2 =>
					
					seven_segment <= "10100100";
					temp_btn <= send;
					if Y(6) = '1' then
						send_data <= "00110001";
					else
						send_data <= "00110000";
					end if;
					-- kalo udah dikirim, pindah state, tapi delay dulu
					if ctr_start = '1' or (send = '0' and temp_btn = '1') then 
						if delay_ctr >= 100000 then
							delay_ctr <= 0;
							ctr_start <= '0';
							CS <= Send3;
						else
							delay_ctr <= delay_ctr + 1;
							ctr_start <= '1';
							CS <= Send2;
						end if;
					else
						CS <= Send2;
					end if;
				when Send3 => 
					seven_segment <= "10110000";
					temp_btn <= send;
					if Y(5) = '1' then
						send_data <= "00110001";
					else
						send_data <= "00110000";
					end if;
					
					if ctr_start = '1' or (send = '0' and temp_btn = '1') then -- kalo udah dikirim, pindah state
						if delay_ctr >= 100000 then
							delay_ctr <= 0;
							ctr_start <= '0';
							CS <= Send4;
						else
							delay_ctr <= delay_ctr + 1;
							ctr_start <= '1';
							CS <= Send3;
						end if;
					else
						CS <= Send3;
					end if;
				when Send4 =>
					seven_segment <= "10011001";
					temp_btn <= send;
					if Y(4) = '1' then
						send_data <= "00110001";
					else
						send_data <= "00110000";
					end if;
				
					if ctr_start = '1' or (send = '0' and temp_btn = '1') then -- kalo udah dikirim, pindah state
						if delay_ctr >= 100000 then
							delay_ctr <= 0;
							ctr_start <= '0';
							CS <= Send5;
						else
							delay_ctr <= delay_ctr + 1;
							ctr_start <= '1';
							CS <= Send4;
						end if;
					else
						CS <= Send4;
					end if;
				when Send5 => 
					seven_segment <= "10010010";
					temp_btn <= send;
					if Y(3) = '1' then
						send_data <= "00110001";
					else
						send_data <= "00110000";
					end if;
					
					if ctr_start = '1' or (send = '0' and temp_btn = '1') then -- kalo udah dikirim, pindah state
						if delay_ctr >= 100000 then
							delay_ctr <= 0;
							ctr_start <= '0';
							CS <= Send6;
						else
							delay_ctr <= delay_ctr + 1;
							ctr_start <= '1';
							CS <= Send5;
						end if;
					else
						CS <= Send5;
					end if;
				when Send6 => 
					seven_segment <= "10000010";
					temp_btn <= send;
					if Y(2) = '1' then
						send_data <= "00110001";
					else
						send_data <= "00110000";
					end if;
					
					if ctr_start = '1' or (send = '0' and temp_btn = '1') then -- kalo udah dikirim, pindah state
						if delay_ctr >= 100000 then
							delay_ctr <= 0;
							ctr_start <= '0';
							CS <= Send7;
						else
							delay_ctr <= delay_ctr + 1;
							ctr_start <= '1';
							CS <= Send6;
						end if;
					else
						CS <= Send6;
					end if;
				when Send7 => 
					seven_segment <= "11111000";
					temp_btn <= send;
					if Y(1) = '1' then
						send_data <= "00110001";
					else
						send_data <= "00110000";
					end if;

					if ctr_start = '1' or (send = '0' and temp_btn = '1') then -- kalo udah dikirim, pindah state
						if delay_ctr >= 100000 then
							delay_ctr <= 0;
							ctr_start <= '0';
							CS <= Send8;
						else
							delay_ctr <= delay_ctr + 1;
							ctr_start <= '1';
							CS <= Send7;
						end if;
					else
						CS <= Send7;
					end if;
				when Send8 => 
					seven_segment <= "10000000";
					temp_btn <= send;
					if Y(0) = '1' then
						send_data <= "00110001";
					else
						send_data <= "00110000";
					end if;
					if ctr_start = '1' or (send = '0' and temp_btn = '1') then -- kalo udah dikirim, pindah state
						if delay_ctr >= 100000 then
							delay_ctr <= 0;
							ctr_start <= '0';
							CS <= S_C;
						else
							delay_ctr <= delay_ctr + 1;
							ctr_start <= '1';
							CS <= Send8;
						end if;
					else
						CS <= Send8;
					end if;
				when others => 
			end case;
		end if;
		end if;
	end process;
end rtl;


