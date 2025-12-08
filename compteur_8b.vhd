library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity compteur_8b is
    Port ( CK   : in    STD_LOGIC;
           RST  : in    STD_LOGIC;
           LOAD : in    STD_LOGIC;
           SENS : in    STD_LOGIC;
           EN   : in    STD_LOGIC;
           Din  : in    STD_LOGIC_VECTOR (7 downto 0);
           Dout : out   STD_LOGIC_VECTOR (7 downto 0));
end compteur_8b;

architecture Behavioral of compteur_8b is
    signal s_Dout : std_logic_vector (7 downto 0);
begin
    clock : process(CK) is
    begin
        if (CK'event and CK='1') then
            if RST='0' then                     s_Dout <= (others => '0');
            elsif LOAD='1' then                 s_Dout <= Din;
            elsif (SENS='1' and EN='0') then    s_Dout <= std_logic_vector(unsigned(s_Dout)+1);
            elsif (SENS='0' and EN='0') then    s_Dout <= std_logic_vector(unsigned(s_Dout)-1);
            end if;
        end if;
    end process;
    Dout <= s_Dout;
end Behavioral;
