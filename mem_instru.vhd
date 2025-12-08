library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity mem_instru is
    Port ( ad 	: in 	STD_LOGIC_VECTOR (7 downto 0);
           clk 	: in 	STD_LOGIC;
           en 	: in	STD_LOGIC;
           d_out : out STD_LOGIC_VECTOR (31 downto 0));
end mem_instru;

architecture compo of mem_instru is
    type t_banc is array (0 to 255) of std_logic_vector(31 downto 0);
    constant memoire : t_banc := (
    					1 =>  	X"0601F000", -- Afc     R1, 0xF0
						2 =>    X"06020F00", -- Afc    R2, 0x0F
						3 =>    X"06030700", -- Afc    R3, 0X07
						4 =>    X"06040A00", -- Afc    R4, 0X0A
						5 =>    X"06050100", -- Afc    R5, 01
						6 =>    X"05050400", -- Cp     R5, R4     attendu 0 car R4 pas encore actu
						7 =>    X"01010102", -- Add    R1, R1, R2 attendu FF
						8 =>    X"02010304", -- Mul    R1, R3, R4 attendu 46
						9 =>    X"03010403", -- Sub    R1, R4, R3 attendu 03
						10 =>   X"14010304", -- And    R1, R3, R4 attendu 02
						11 =>   X"15010304", -- Or     R1, R3, R4 attendu 0F
						12 =>   X"16010304", -- Xor    R1, R3, R4 attendu 0D
						13 =>   X"17010300", -- Not    R1, R3     attendu F8
						14 =>   X"05050400", -- Cp     R5, R4     attendu 0A, cette fois R4 actu
						15 =>   X"08040400", -- Store  @4, R4
						16 =>   X"07070400", -- Charge R7,@4     attendu 0A car pas d'attente memd
						
--						1 =>	X"0601F000", -- Afc     R1, 0xF0		R1=F0
--                      2 => 	X"06020A00", -- Afc     R2, 0x0A		R2=0A
--                      3 => 	X"01030102", -- Add		R3, R1, R2		R3=FA
--                      4 =>	X"03040102", -- Sub		R4, R1, R2		R4=E6
--                      5 =>	X"05050400", -- Cp		R5, R4			R5=E6
						
						others => (others => '0')
								);
						
begin
    process(clk) is
    begin
        if (clk'event and clk='1' and en='0') then
            d_out <= memoire(to_integer(unsigned(ad)));
        end if;
    end process;

end compo;
