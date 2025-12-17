library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity test_mem_instru is
end test_mem_instru;

architecture test of test_mem_instru is
    signal i_ad : std_logic_vector(7 downto 0);
    signal i_clk : std_logic;
    signal i_d_out : std_logic_vector(31 downto 0);

    component mem_instru is
        Port ( ad : in STD_LOGIC_VECTOR (7 downto 0);
               clk : in STD_LOGIC;
               d_out : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    
    
    signal d_ad : std_logic_vector(7 downto 0);
    signal d_d_in : std_logic_vector(7 downto 0);
    signal d_rw : std_logic;
    signal d_rst : std_logic;
    signal d_clk : std_logic;
    signal d_d_out : std_logic_vector(7 downto 0);
    signal plus : std_logic_vector(7 downto 0);
    
    component mem_donnee is
    Port ( ad : in STD_LOGIC_VECTOR (7 downto 0);
       d_in : in STD_LOGIC_VECTOR (7 downto 0);
       rw : in STD_LOGIC;
       rst : in STD_LOGIC;
       clk : in STD_LOGIC;
       d_out : out STD_LOGIC_VECTOR (7 downto 0);
       plus : out std_logic_vector(7 downto 0));
    end component;

begin 
    test_instu : mem_instru port map(i_ad,i_clk,i_d_out);
    test_donne : mem_donnee port map(d_ad,d_d_in,d_rw,d_rst,d_clk,d_d_out, plus);
    clocks : process is
    begin
        i_clk <= '0';
        d_clk <= '0';
        wait for 5 ns;
        i_clk <= '1';
        d_clk <= '1';
        wait for 5 ns;
    end process;
    
    test_donnees : process is
    begin
        wait for 2 ns;          -- On desynchronise pour montrer la detec de front
        
        d_ad    <= "00000000";
        d_d_in  <= "00000000";
        d_rw    <= '0';         -- Ecriture
        d_rst   <= '0';
        wait for 10 ns;
        
        d_rst   <= '1';
        wait for 10 ns;
        
        d_ad    <= "00000001";  --Ecrire a 1
        d_d_in  <= "11111111";  --Ecrire FF
        wait for 10 ns;
        
        d_ad    <= "00000010";  --Ecrire a 2
        d_d_in  <= "01111111";  --Ecrire 7F
        wait for 10 ns;
        
        d_ad    <= "00000100";  --Ecrire a 4
        d_d_in  <= "00111111";  --Ecrire 3F
        wait for 10 ns;
        
        d_ad    <= "00000000";
        d_d_in  <= "00000000";
        d_rw    <= '1';         -- Lire a 0
        wait for 10 ns;
        
        d_ad    <= "00000001";
        wait for 10 ns;
        
        d_ad    <= "00000010";
        wait for 10 ns;
        
        d_ad    <= "00000011";
        wait for 10 ns;
        
        d_ad    <= "00000100";
        wait for 10 ns;
        
        d_ad    <= "00000101";
        wait for 10 ns;
    end process;
    
    test_instru : process is
    begin
        wait for 2 ns;
        
        i_ad <= "00000000";
        wait for 10 ns;
        
        i_ad <= "00000001";
        wait for 10 ns;
        
        i_ad <= "00000010";
        wait for 10 ns;
        
        i_ad <= "00000011";
        wait for 10 ns;
        
        i_ad <= "00000100";
        wait for 10 ns;
        
        i_ad <= "00000101";
        wait for 10 ns;
        
        i_ad <= "00000110";
        wait for 10 ns;
        
        i_ad <= "00000111";
        wait for 10 ns;
    end process;
    
end test;