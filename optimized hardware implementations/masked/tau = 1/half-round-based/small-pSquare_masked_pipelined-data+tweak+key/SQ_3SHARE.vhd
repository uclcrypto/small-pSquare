library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SQ_3SHARE is
    Generic (bits : INTEGER := 7);
    Port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           a0 : in UNSIGNED (bits-1 downto 0);
           a1 : in UNSIGNED (bits-1 downto 0);
           a2 : in UNSIGNED (bits-1 downto 0);
           r0 : in UNSIGNED (bits-1 downto 0);
           r1 : in UNSIGNED (bits-1 downto 0);
           r2 : in UNSIGNED (bits-1 downto 0);
           r3 : in UNSIGNED (bits-1 downto 0);
           r4 : in UNSIGNED (bits-1 downto 0);
           b0 : out UNSIGNED (bits-1 downto 0);
           b1 : out UNSIGNED (bits-1 downto 0);
           b2 : out UNSIGNED (bits-1 downto 0));
end SQ_3SHARE;

architecture Behavioral of SQ_3SHARE is

    component AddModMersenne is
        Generic ( bits : INTEGER := 7);
        Port ( a : in UNSIGNED (bits-1 downto 0);
               b : in UNSIGNED (bits-1 downto 0);
               c : out UNSIGNED (bits-1 downto 0));
    end component;
    
    component SubModMersenne is
        Generic ( bits : INTEGER := 7);
        Port ( a : in UNSIGNED (bits-1 downto 0);
               b : in UNSIGNED (bits-1 downto 0);
               c : out UNSIGNED (bits-1 downto 0));
    end component;
    
    component MulAddModMersenne is
        Generic ( bits : INTEGER := 7);
        Port ( a : in UNSIGNED (bits-1 downto 0);
               b : in UNSIGNED (bits-1 downto 0);
               c : in UNSIGNED (bits-1 downto 0);
               d : out UNSIGNED (bits-1 downto 0));
    end component;
    
    component MulSubModMersenne is
        Generic ( bits : INTEGER := 7);
        Port ( a : in UNSIGNED (bits-1 downto 0);
               b : in UNSIGNED (bits-1 downto 0);
               c : in UNSIGNED (bits-1 downto 0);
               d : out UNSIGNED (bits-1 downto 0));
    end component;
    
    component FF is
        Generic ( bits : INTEGER := 7);
        Port ( clk : in STD_LOGIC;
               en : in STD_LOGIC;
               input : in UNSIGNED ((bits-1) downto 0);
               output : out UNSIGNED ((bits-1) downto 0));
    end component;
    
    signal r3_r, r4_r, r5_r, r3_rr, r4_rr, r5_rr, a02, a12, a22, a12r0, a22r1, a02r2, a0r0, a1r1, a2r2, a0r0a0r3, a1r1a1r4, a2r2a2r5, a0_r, a1_r, a2_r, a12r0_r, a22r1_r, a02r2_r, a0r0a0r3_r, a1r1a1r4_r, a2r2a2r5_r : UNSIGNED (bits-1 downto 0);
    
begin

    FF1 : FF Generic Map (bits) Port Map (clk, en, r3, r3_r);
    FF2 : FF Generic Map (bits) Port Map (clk, en, r4, r4_r);
    Add1 : AddModMersenne Generic Map (bits) Port Map (r3_r, r4_r, r5_r);
    FF3 : FF Generic Map (bits) Port Map (clk, en, r3_r, r3_rr);
    FF4 : FF Generic Map (bits) Port Map (clk, en, r4_r, r4_rr);
    FF5 : FF Generic Map (bits) Port Map (clk, en, r5_r, r5_rr);
    
    a02 <= a0(bits-2 downto 0) & a0(bits-1);
    a12 <= a1(bits-2 downto 0) & a1(bits-1);
    a22 <= a2(bits-2 downto 0) & a2(bits-1);
    Add2 : AddModMersenne Generic Map (bits) Port Map (a12, r0, a12r0);
    Add3 : AddModMersenne Generic Map (bits) Port Map (a22, r1, a22r1);
    Add4 : AddModMersenne Generic Map (bits) Port Map (a02, r2, a02r2);
    Sub1 : SubModMersenne Generic Map (bits) Port Map (a0, r0, a0r0);
    Sub2 : SubModMersenne Generic Map (bits) Port Map (a1, r1, a1r1);
    Sub3 : SubModMersenne Generic Map (bits) Port Map (a2, r2, a2r2);
    MulAdd1 : MulAddModMersenne Generic Map (bits) Port Map (a0r0, a0, r3_rr, a0r0a0r3);
    MulAdd2 : MulAddModMersenne Generic Map (bits) Port Map (a1r1, a1, r4_rr, a1r1a1r4);
    MulSub1 : MulSubModMersenne Generic Map (bits) Port Map (a2r2, a2, r5_rr, a2r2a2r5);

    FF6 : FF Generic Map (bits) Port Map (clk, en, a0, a0_r);
    FF7 : FF Generic Map (bits) Port Map (clk, en, a1, a1_r);
    FF8 : FF Generic Map (bits) Port Map (clk, en, a2, a2_r);
    FF9 : FF Generic Map (bits) Port Map (clk, en, a12r0, a12r0_r);
    FF10 : FF Generic Map (bits) Port Map (clk, en, a22r1, a22r1_r);
    FF11 : FF Generic Map (bits) Port Map (clk, en, a02r2, a02r2_r);
    FF12 : FF Generic Map (bits) Port Map (clk, en, a0r0a0r3, a0r0a0r3_r);
    FF13 : FF Generic Map (bits) Port Map (clk, en, a1r1a1r4, a1r1a1r4_r);
    FF14 : FF Generic Map (bits) Port Map (clk, en, a2r2a2r5, a2r2a2r5_r);
    
    MulAdd3 : MulAddModMersenne Generic Map (bits) Port Map (a12r0_r, a0_r, a0r0a0r3_r, b0);
    MulAdd4 : MulAddModMersenne Generic Map (bits) Port Map (a22r1_r, a1_r, a1r1a1r4_r, b1);
    MulAdd5 : MulAddModMersenne Generic Map (bits) Port Map (a02r2_r, a2_r, a2r2a2r5_r, b2);

end Behavioral;