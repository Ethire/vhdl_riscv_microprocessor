library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity manomano is
  Port (CLK, RST  	: in std_logic;
        sortieA, sortieB 	: out std_logic_vector(7 downto 0);
        pc_out				: out std_logic_vector(7 downto 0)
  );
  
end manomano;

architecture compotement of manomano is
	attribute DONT_TOUCH : string;
	
----------------------------- Declaration composants ----------------------------------------------
  
    component ALU is
    port(
        A, B 		    : in 	std_logic_vector(7 downto 0);
        control 	    : in 	std_logic_vector(2 downto 0);
        S 		        : out 	std_logic_vector(7 downto 0);
        Car, Neg, Ovf 	: out 	std_logic
    );      
    end component;
    signal alu_A, alu_B    : 	std_logic_vector(7 downto 0);
	signal alu_control     :  	std_logic_vector(2 downto 0);
	signal alu_S 		   :  	std_logic_vector(7 downto 0);
		
    component banc_registre is
    Port (
        ad_A : in  std_logic_vector(3 downto 0);
        ad_B : in  std_logic_vector(3 downto 0);
        ad_W : in  std_logic_vector(3 downto 0);
        W    : in  std_logic;
        Data : in  std_logic_vector(7 downto 0);
        Rst  : in  std_logic;
        Clk  : in  std_logic;
        QA   : out std_logic_vector(7 downto 0);
        QB   : out std_logic_vector(7 downto 0);
        S0	: out std_logic_vector(7 downto 0);
        S1	: out std_logic_vector(7 downto 0)
    );
    end component;
    signal banc_ad_A : std_logic_vector(3 downto 0) := "0000";
    signal banc_ad_B : std_logic_vector(3 downto 0) := "0000";
    signal banc_ad_W : std_logic_vector(3 downto 0) := "0000";
    signal banc_W    : std_logic;
    signal banc_Data, banc_QA, banc_QB, banc_S0, banc_S1: std_logic_vector(7 downto 0);

    
    component compteur_8b is
        Port ( CK   : in    STD_LOGIC;
               RST  : in    STD_LOGIC;
               LOAD : in    STD_LOGIC;
               SENS : in    STD_LOGIC;
               EN   : in    STD_LOGIC;
               Din  : in    STD_LOGIC_VECTOR (7 downto 0);
               Dout : out   STD_LOGIC_VECTOR (7 downto 0));
    end component;
    signal cpt_en : std_logic;

    component mem_donnee is
        Port ( ad    : in STD_LOGIC_VECTOR (7 downto 0);
               d_in  : in STD_LOGIC_VECTOR (7 downto 0);
               rw    : in STD_LOGIC;
               rst   : in STD_LOGIC;
               clk   : in STD_LOGIC;
               d_out : out STD_LOGIC_VECTOR (7 downto 0));
    end component;
    signal memd_ad   : std_logic_vector(7 downto 0);
    signal memd_din  : std_logic_vector(7 downto 0);
    signal memd_rw   : std_logic;
    signal memd_dout : std_logic_vector(7 downto 0);
    
    component mem_instru is
        Port ( ad 	: in 	STD_LOGIC_VECTOR (7 downto 0);
               clk 	: in	STD_LOGIC;
               en	: in	STD_LOGIC;
               d_out : out 	STD_LOGIC_VECTOR (31 downto 0));
    end component;
    signal memi_ad 	:  std_logic_vector( 7 downto 0);
    signal memi_dout : std_logic_vector(31 downto 0);
	
	signal lidi_op, lidi_a, lidi_b, lidi_c     : std_logic_vector(7 downto 0);
	signal diex_op, diex_a, diex_b, diex_c     : std_logic_vector(7 downto 0);
	signal exmem_op, exmem_a, exmem_b          : std_logic_vector(7 downto 0);
	signal memre_op, memre_a, memre_b          : std_logic_vector(7 downto 0);
	
	attribute DONT_TOUCH of ALU : component is "TRUE";
	attribute DONT_TOUCH of banc_registre : component is "TRUE";
	attribute DONT_TOUCH of mem_donnee : component is "TRUE";
	attribute DONT_TOUCH of mem_instru : component is "TRUE";
	attribute DONT_TOUCH of compteur_8b : component is "TRUE";
	
begin

----------------------------- Port maps -----------------------------------------------------------

    compo_alu : ALU port map(A => alu_A, 
                            B => alu_B, 
                            control => alu_control,
                            S => alu_S,
                            Car => open,
                            Neg => open,
                            Ovf => open);
                            
    compo_Banc : banc_registre port map (ad_A => banc_ad_A,
                             ad_B => banc_ad_B,
                             ad_W => banc_ad_W,
                             W => banc_W,
                             Data => banc_Data,
                             Rst => RST,
                             Clk => CLK,
                             QA => banc_QA,
                             QB => banc_QB,
                             S0 => banc_S0,
                             S1 => banc_S1);
                             
    compo_cpt: compteur_8b port map (CK => CLK,
                            rst => RST,
                            load => '0',
                            sens => '1',
                            en => cpt_en,
                            din => "00000000",
                            dout => memi_ad);
                            
    compo_instru : mem_instru port map(ad=>memi_ad,
                            clk => CLK,
                            en  => cpt_en,
                            d_out => memi_dout);
    lidi_op <= memi_dout(31 downto 24);
    lidi_a  <= memi_dout(23 downto 16);
    lidi_b  <= memi_dout(15 downto 8 );
    lidi_c  <= memi_dout( 7 downto 0 );
    
    compo_donnees : mem_donnee port map(ad => memd_ad,
                            d_in => memd_din,
                            rw => memd_rw,
                            rst => RST,
                            clk => CLK,
                            d_out => memd_dout);

----------------------------- Code microncontroleur -----------------------------------------------

    deplace_pipeline : process(CLK) is
    begin
        if (CLK'event and CLK='1') then
        
            ------                                             --
            ----Affectation de Exmem apres la mem donnees    ----
            --                                             ------
            memre_op  <= exmem_op;          -- Op n'est jamais modifie
            memre_a   <= exmem_a;           -- A n'est pas modifie
            if (exmem_op = X"07") then       -- Si lecture, on recup la valeur
                memre_b <= memd_dout;
            else                            -- Sinon on passe B
                memre_b <= exmem_b;
            end if;
            
            
            ------                                             --
            ----Affectation de Exmem apres l'ALU             ----
            --                                             ------
            exmem_op  <= diex_op;           -- Op n'est jamais modifie
            exmem_a   <= diex_a;            -- A  n'est jamais utilise dans calcul
            if (diex_op(2) = diex_op(4)) then   -- L'op necessite l'alu
                exmem_b <= alu_s;            -- B  est le resultat de l'op
            else                                -- L'ALU n'est pas utilisee, on passe B
                exmem_b <= diex_b;
            end if;
            
            
            ------                                             --
            ----Affectation de DIEX apres le banc de registre----
            --                                             ------
            
            diex_op   <= lidi_op;           -- Op n'est pas modifie
                diex_a    <= lidi_a;            -- A n'est jamais lu comme valeur
                -- Pour tout sauf AFC et LOAD, B est une valeur numérique, donc QA
                if (lidi_op = X"06" or lidi_op = X"07") then
                    diex_b <= lidi_b;           -- Seules condi pour ne pas prendre la valeur
                else
                    diex_b <= banc_qa;
                end if;
                diex_c <= banc_qb;              -- Tout le temps considere comme valeur
            
            if (cpt_en='1') then -- Blocage
            	diex_op <= X"00";
				diex_a  <= X"00";
				diex_b  <= X"00";
				diex_c  <= X"00";
            end if;

            
            -- lidi s'actualise a la fin du clock tout seul, on l'arrete si bulle
        end if;
    end process ;
    
    -- Affectations des entrees de l'ALU
    alu_a       <= diex_b;                  -- A toujours en case B
    alu_b       <= diex_c;                  -- B toujours en case C
    alu_control <= diex_op(2 downto 0);     -- On fait toujours le calcul, on le prend si on veut
    
    -- Affectations des entrees du Banc de Registres
    banc_ad_a   <= lidi_b(3 downto 0);      -- Lecture A toujours a partir de B
    banc_ad_b   <= lidi_c(3 downto 0);      -- Lecture B toujours a partir de C
    banc_W      <= '1' when (memre_op /= "00001000" and memre_op /= "UUUUUUUU" and memre_op /= "00000000") else '0'; -- Tout sauf STORE font retour ecriture
    banc_ad_W   <= memre_a(3 downto 0);
    banc_data   <= memre_b;
    
    -- Affectations des entrees du compteur
    -- Cpt_en vaut 1 quand bulle necessaire
    cpt_en <= '1' when 	(	(lidi_op=X"17" or lidi_op=X"05" or lidi_op=X"08") and 
							(	(diex_op/=X"08" and diex_op/=X"00" and lidi_b=diex_a)  or
								(exmem_op/=X"08" and diex_op/=X"00" and lidi_b=exmem_a) or
								(memre_op/=X"08" and diex_op/=X"00" and lidi_b=memre_a)
							) -- Ces instru lisent (B) comme une adresse, on check les etapes du pipeline qui ecrivent a la meme adresse (A)
                		)or(
                			(lidi_op=X"01" or lidi_op=X"02" or lidi_op=X"03" or lidi_op=X"14" or lidi_op=X"15" or lidi_op=X"16") and
							(	(diex_op/=X"08" and diex_op/=X"00" and (lidi_b=diex_a or lidi_c=diex_a)) or
								(exmem_op/=X"08" and diex_op/=X"00" and (lidi_b=exmem_a or lidi_c=exmem_a)) or
								(memre_op/=X"08" and diex_op/=X"00" and (lidi_b=memre_a or lidi_c=memre_a))
							)
						)
               else '0';
        
    -- Affectation des entrées Memoire Donnees
    memd_ad     <= exmem_a when (exmem_op = X"08") else exmem_b; -- A quand on STORE, B sinon
    memd_din    <= exmem_b;                 -- Toujours B pour la data a ecrire
    memd_rw     <= '0' when (exmem_op = X"08") else '1';             -- 0 si ecriture vers memoire, 1 si lecture de memoire
    
    -- Affectations sorties
    sortieA <= banc_S0;
    sortieB <= banc_S1;
    pc_out <= memi_ad;
	
end compotement;
