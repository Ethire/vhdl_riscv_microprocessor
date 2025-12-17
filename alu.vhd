library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is
port(
	A, B 		: in 	std_logic_vector(7 downto 0);
	control 	: in 	std_logic_vector(2 downto 0);
	S 		: out 	std_logic_vector(7 downto 0);
	Car, Neg, Ovf 	: out 	std_logic
);
end ALU;

architecture behav of ALU is
-- Signaux
	signal A_ex 	: std_logic_vector(15 downto 0);
	signal B_ex 	: std_logic_vector(15 downto 0);
	signal Res_temp : std_logic_vector(15 downto 0);
begin
    -- Et 	100
    -- Ou 	101
    -- XOR	110
    -- Non	111
    -- + 	001
    -- - 	011
    -- x	010
    -- rien	000
    A_ex <= X"00"&A ;
    B_ex <= X"00"&B ;
    
    with control select
        Res_temp <= 
        	X"00"&(A and B) 									when "100",
            X"00"&(A or B)              						when "101",
            X"00"&(A xor B)             						when "110",
            X"00"&(not A)               						when "111",
            std_logic_vector(unsigned(A_ex) + unsigned(B_ex))   when "001",
            std_logic_vector(unsigned(A_ex) - unsigned(B_ex))   when "011",
            std_logic_vector(unsigned(A) * unsigned(B))         when "010",
            A_ex                        						when others;
            
	S 		<= Res_temp(7 downto 0);
	Car 	<= Res_temp(8) when control="001" else '0';
	Ovf 	<= '1' when (Res_temp(15 downto 8) /= X"0000" and control="010") else '0';
	Neg 	<= '1' when (B>A and control="011") else '0';
end behav;