library ieee;
use ieee.std_logic_1164.all;
entity test_banc_registre is -- entity declaration
end test_banc_registre;
---------------------------------------------------------------------
architecture archi of test_banc_registre is
 signal ad_A, ad_B, ad_W: std_logic_vector(3 downto 0);
 signal W,Rst,Clk: std_logic;
 signal Data, QA, QB: std_logic_vector(7 downto 0);

 component banc_registre is
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
        S1	: out std_logic_vector(7 downto 0);
        S2	: out std_logic_vector(7 downto 0)
 );
 end component;

begin
    test_banc_obj : banc_registre port map (ad_A,ad_B,ad_W,W,Data,Rst,Clk,QA,QB);
    clock : process is
    begin
        Clk <= '1';
        wait for 5 ns;
        Clk <= '0';
        wait for 5 ns;
    end process;

    princi : process is
    begin
        ad_A <= "0000";
        ad_B <= "0000";
        ad_W <= "0000";
        Data <= "00000000";
        Rst <= '0';
        W <= '0';
        wait for 17 ns;
        Rst <= '1';
        wait for 10 ns;
        
        -- Ecriture
        ad_W <= "0001";
        Data <= "00100100";
        W <= '1';
        wait for 10 ns;
        ad_W <= "0010";
        Data <= "01000010";
        wait for 10 ns;
        ad_W <= "0011";
        Data <= "10000001";
        wait for 10 ns;
        ad_W <= "0010";
        W <= '0';
        wait for 10 ns;
        
        -- Lecture
        
        ad_A <= "0000";
        ad_B <= "0001";
        wait for 20 ns;
        ad_A <= "0010";
        ad_B <= "0011";
        wait for 20 ns;
        
        wait for 20 ns;
    end process;
   
end archi;

