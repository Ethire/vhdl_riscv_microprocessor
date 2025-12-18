library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_alu is

end test_alu;

architecture Behavioral of test_alu is
    component ALU is
        port(
            A, B 		: in 	std_logic_vector(7 downto 0);
            control 	: in 	std_logic_vector(2 downto 0);
            S 		: out 	std_logic_vector(7 downto 0);
            Car, Neg, Ovf 	: out 	std_logic
        );
    end component;
    signal A, B 	: 	std_logic_vector(7 downto 0);
	signal control 	:  	std_logic_vector(2 downto 0);
	signal S 		:  	std_logic_vector(7 downto 0);
	signal Car, Neg, Ovf 	: std_logic;
begin
    al_test : ALU port map(A => A, 
                            B => B, 
                            control => control,
                            S => S,
                            Car => Car,
                            Neg => Neg,
                            Ovf => Ovf);
    process begin
    A <= "00001001";
    B <= "11111000";
    control <= "000";
    wait for 100 ns;
    
    control <= "001";
    wait for 100 ns;
    
    control <= "010";
    wait for 100 ns;
    
    control <= "011";
    wait for 100 ns;
    
    control <= "100";
    wait for 100 ns;
    
    control <= "101";
    wait for 100 ns;
    
    control <= "110";
    wait for 100 ns;
    
    control <= "111";
    wait for 100 ns;
    end process;
end Behavioral;
