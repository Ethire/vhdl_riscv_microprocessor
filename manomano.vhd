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

--═════════════════════════════════════════════════════════════════════════════════════════════════
--════════════════════════════════════ Component declaration ══════════════════════════════════════
--═════════════════════════════════════════════════════════════════════════════════════════════════

--───────────────────────────────────────────────────────────────────────────────────────────── UAL
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
	
--─────────────────────────────────────────────────────────────────────────────────── Register file
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

--─────────────────────────────────────────────────────────────────────────────────── 8 bit counter
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

--─────────────────────────────────────────────────────────────────────────────────────── Data file
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
    
--──────────────────────────────────────────────────────────────────────────────── Instruction File
    component mem_instru is
        Port ( ad 	: in 	STD_LOGIC_VECTOR (7 downto 0);
               clk 	: in	STD_LOGIC;
               en	: in	STD_LOGIC;
               d_out : out 	STD_LOGIC_VECTOR (31 downto 0));
    end component;
    signal memi_ad 	:  std_logic_vector( 7 downto 0);
    signal memi_dout : std_logic_vector(31 downto 0);

--────────────────────────────────────────────────────────────────────────────── Pipeline registers
	signal lidi_op, lidi_a, lidi_b, lidi_c     : std_logic_vector(7 downto 0);
	signal diex_op, diex_a, diex_b, diex_c     : std_logic_vector(7 downto 0);
	signal exmem_op, exmem_a, exmem_b          : std_logic_vector(7 downto 0);
	signal memre_op, memre_a, memre_b          : std_logic_vector(7 downto 0);
	
begin

--═════════════════════════════════════════════════════════════════════════════════════════════════
--════════════════════════════════════ Port mapping ═══════════════════════════════════════════════
--═════════════════════════════════════════════════════════════════════════════════════════════════

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
    -- To make the hazard management easier we push the output into our first pipeline register
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


--═════════════════════════════════════════════════════════════════════════════════════════════════
--════════════════════════════════════ Microcontroler code ════════════════════════════════════════
--═════════════════════════════════════════════════════════════════════════════════════════════════

    deplace_pipeline : process(CLK, RST) is
    begin
    	if RST='0' then
    	
    		diex_op <= (others => '0');
    		diex_a <= (others => '0');
    		diex_b <= (others => '0');
    		diex_c <= (others => '0');
    		
    		exmem_op <= (others => '0');
    		exmem_a <= (others => '0');
    		exmem_b <= (others => '0');
    		
    		memre_op <= (others => '0');
    		memre_a <= (others => '0');
    		memre_b <= (others => '0');
    		
        elsif (CLK'event and CLK='1') then
        
--──────────────────────────────────────────────────────────────────────────────────────────── Lidi
			-- No need to manage Lidi, component mem_instru manages it, and on rising clock
			
--──────────────────────────────────────────────────────────────────────────────────────────── Diex
			diex_op   <= lidi_op;           -- Op never modified
			diex_a    <= lidi_a;            -- A never seen as value
			-- For all but AFC and LOAD, B is a numerical value, so put QA instead of lidi_b
			if (lidi_op = X"06" or lidi_op = X"07") then
				diex_b <= lidi_b;
			else
				diex_b <= banc_qa;
			end if;
			-- For all opcodes, we either want the value or don't care about this register
			diex_c <= banc_qb;
            
            -- Hazard detections overwrite
            if (cpt_en='1') then 	-- Cpt_en is negative logic
            	diex_op <= X"00";
				diex_a  <= X"00";
				diex_b  <= X"00";
				diex_c  <= X"00";
            end if;
			
			
--──────────────────────────────────────────────────────────────────────────────────────────── Exmem
			exmem_op  <= diex_op;           	-- Op n'est jamais modifie
            exmem_a   <= diex_a;            	-- A  n'est jamais utilise dans calcul
            if (diex_op(2) = diex_op(4)) then   -- L'op necessite l'alu
                exmem_b <= alu_s;            	-- B  est le resultat de l'op
            else                                -- L'ALU n'est pas utilisee, on passe B
                exmem_b <= diex_b;
            end if;
            
--──────────────────────────────────────────────────────────────────────────────────────────── Memre
			memre_op  <= exmem_op;          	-- Op n'est jamais modifie
            memre_a   <= exmem_a;           	-- A n'est pas modifie
            if (exmem_op = X"07") then       	-- Si lecture, on recup la valeur
                memre_b <= memd_dout;
            else                            	-- Sinon on passe B
                memre_b <= exmem_b;
            end if;
        end if;
    end process ;
    
    -- UAL input assignment
    alu_a       <= diex_b;                  -- inputA always tied to subregister B
    alu_b       <= diex_c;                  -- inputB always tied to subregister  C
    alu_control <= diex_op(2 downto 0);     -- Always does the computations, uses the result if needed
    
    -- Register file input assignment
    banc_ad_a   <= lidi_b(3 downto 0);      -- input A always tied to subregister B
    banc_ad_b   <= lidi_c(3 downto 0);      -- input B always tied to subregister C
    banc_W      <= '1' when (memre_op /= "00001000" and memre_op /= "00000000") else '0'; -- All but store and nop write in register file
    banc_ad_W   <= memre_a(3 downto 0);
    banc_data   <= memre_b;
    
    -- Counter input assignment
    -- Cpt_en is negative logic, so '1' locks the counter and intruction file.
    cpt_en <= '1' when 	(	(lidi_op=X"17" or lidi_op=X"05" or lidi_op=X"08") and 
							(	(diex_op/=X"08" and diex_op/=X"00" and lidi_b=diex_a)  or
								(exmem_op/=X"08" and diex_op/=X"00" and lidi_b=exmem_a) or
								(memre_op/=X"08" and diex_op/=X"00" and lidi_b=memre_a)
							)
							-- These instructions use B as an adress, so we check the next pipelines step that write to same adress
                		)or(
                			(lidi_op=X"01" or lidi_op=X"02" or lidi_op=X"03" or lidi_op=X"14" or lidi_op=X"15" or lidi_op=X"16") and
							(	(diex_op/=X"08" and diex_op/=X"00" and (lidi_b=diex_a or lidi_c=diex_a)) or
								(exmem_op/=X"08" and diex_op/=X"00" and (lidi_b=exmem_a or lidi_c=exmem_a)) or
								(memre_op/=X"08" and diex_op/=X"00" and (lidi_b=memre_a or lidi_c=memre_a))
							)
							-- These instructions use both A and B as an adress, so we check the next pipelines step that write to same adress
						)
               else '0';
        
    -- Data file input assignment
    memd_ad     <= exmem_a when (exmem_op = X"08") else exmem_b; 	-- A when we STORE, B for everyone else
    memd_din    <= exmem_b;                 						-- Always use B for data writing
    memd_rw     <= '0' when (exmem_op = X"08") else '1';             -- 0 if writing TO memory, 1 if reading FROM memory
    
    -- Output pins assignment
    sortieA <= banc_S0; 		-- Fetches lines 1 and 2 of register file
    sortieB <= banc_S1;
    pc_out <= memi_ad;			-- Used to debug in simulation.
	
end compotement;
