library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity banc_registre is
    Port (
        ad_A : in  std_logic_vector(3 downto 0);
        ad_B : in  std_logic_vector(3 downto 0);
        ad_W : in  std_logic_vector(3 downto 0);
        W    : in  std_logic;
        Data : in  std_logic_vector(7 downto 0);
        Rst  : in  std_logic;
        Clk  : in  std_logic;
        QA  : out std_logic_vector(7 downto 0);
        QB  : out std_logic_vector(7 downto 0);
        S0	: out std_logic_vector(7 downto 0);
        S1	: out std_logic_vector(7 downto 0)
    );
end banc_registre;

architecture behv of banc_registre is
	
    type t_banc is array (0 to 15) of std_logic_vector(7 downto 0);
    signal banc : t_banc;
    
begin
    princip : process(CLK,Rst) is
    begin
    	if (Rst='0') then
			banc <= (others => (others => '0'));
		elsif(Clk'event and Clk='1' and W='1') then
                banc(to_integer(unsigned(ad_W))) <= Data;
        end if;
    end process;
    QA <= banc(to_integer(unsigned(ad_A))) when (ad_A/=ad_W or W='0') else DATA;
    QB <= banc(to_integer(unsigned(ad_B))) when (ad_B/=ad_W or W='0') else DATA;
    -- Alternative : DATA when (ad_B=ad_W and W='1') else banc(to_integer(unsigned(ad_B)))
    S0 <= banc(1);
    S1 <= banc(2);
end behv;
