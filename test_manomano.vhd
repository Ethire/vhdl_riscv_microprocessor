library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_manomano is
end test_manomano;

architecture comportementalement of test_manomano is
    signal CLK : std_logic;
    signal RST : std_logic;
    signal sortieA : std_logic_vector( 7 downto 0);
    signal sortieB : std_logic_vector( 7 downto 0);
    
    component manomano is
         Port (CLK, RST  : in std_logic;
          
               sortieA, sortieB : out std_logic_vector(7 downto 0)
               );
    end component;
    
begin
    test_manomano : manomano port map ( CLK, RST, sortieA, sortieB );
    
    clock : process is
        begin   
            clk <= '0';
            wait for 5ns;
            clk <= '1';
            wait for 5ns;
         end process;
         
     principal : process is
        begin
            rst <= '0';
            wait for 7ns;
            rst <= '1';
            
            wait for 20000ns;
        end process;

end comportementalement;
