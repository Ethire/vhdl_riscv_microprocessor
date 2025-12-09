library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mem_donnee is
    Port ( ad : 	in STD_LOGIC_VECTOR (7 downto 0);
           d_in 	: in STD_LOGIC_VECTOR (7 downto 0);
           rw : in STD_LOGIC;
           rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           d_out : out STD_LOGIC_VECTOR (7 downto 0));
end mem_donnee;

architecture compo of mem_donnee is

    type t_banc is array (0 to 255) of std_logic_vector(7 downto 0) ;
    signal memoire : t_banc;
    
begin
    process(clk,rst) is
    begin
   		if rst='0' then
			memoire <= (others=>(others=>'0'));
        elsif (clk'event and clk='1' and rw='0') then
                memoire(to_integer(unsigned(ad))) <= d_in;
        end if;
    end process;
    -- Parallel output of the memory line to make the data hazard detections easier
    d_out <= memoire(to_integer(unsigned(ad)));
end compo;
