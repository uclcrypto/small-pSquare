library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SQ_4SHARE is
    Generic (bits : INTEGER := 7);
    Port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           a0 : in UNSIGNED (bits-1 downto 0);
           a1 : in UNSIGNED (bits-1 downto 0);
           a2 : in UNSIGNED (bits-1 downto 0);
           a3 : in UNSIGNED (bits-1 downto 0);
           r0 : in UNSIGNED (bits-1 downto 0);
           r1 : in UNSIGNED (bits-1 downto 0);
           r2 : in UNSIGNED (bits-1 downto 0);
           r3 : in UNSIGNED (bits-1 downto 0);
           r4 : in UNSIGNED (bits-1 downto 0);
           r5 : in UNSIGNED (bits-1 downto 0);
           r6 : in UNSIGNED (bits-1 downto 0);
           r7 : in UNSIGNED (bits-1 downto 0);
           r8 : in UNSIGNED (bits-1 downto 0);
           r9 : in UNSIGNED (bits-1 downto 0);
           r10 : in UNSIGNED (bits-1 downto 0);
           r11 : in UNSIGNED (bits-1 downto 0);
           b0 : out UNSIGNED (bits-1 downto 0);
           b1 : out UNSIGNED (bits-1 downto 0);
           b2 : out UNSIGNED (bits-1 downto 0);
           b3 : out UNSIGNED (bits-1 downto 0));
end SQ_4SHARE;

architecture Behavioral of SQ_4SHARE is

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
    
    component MulAddAddModMersenne is
        Generic ( bits : INTEGER := 7);
        Port ( a : in UNSIGNED (bits-1 downto 0);
               b : in UNSIGNED (bits-1 downto 0);
               c : in UNSIGNED (bits-1 downto 0);
               d : in UNSIGNED (bits-1 downto 0);
               e : out UNSIGNED (bits-1 downto 0));
    end component;
    
    component MulSubAddModMersenne is
        Generic ( bits : INTEGER := 7);
        Port ( a : in UNSIGNED (bits-1 downto 0);
               b : in UNSIGNED (bits-1 downto 0);
               c : in UNSIGNED (bits-1 downto 0);
               d : in UNSIGNED (bits-1 downto 0);
               e : out UNSIGNED (bits-1 downto 0));
    end component;
    
    component MulSubSubModMersenne is
        Generic ( bits : INTEGER := 7);
        Port ( a : in UNSIGNED (bits-1 downto 0);
               b : in UNSIGNED (bits-1 downto 0);
               c : in UNSIGNED (bits-1 downto 0);
               d : in UNSIGNED (bits-1 downto 0);
               e : out UNSIGNED (bits-1 downto 0));
    end component;
    
    component MulAddModMersenne is
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
    
    signal a02, a12, a22, a32, a12r0, a22r1, a32r2, a02r3, a02r4, a12r5, a0r0, a1r1, a2r2, a3r3, a0r0a0r6r7, a1r1a1r7, a1r1a1r7r8, a2r2a2r8, a2r2a2r8r9, a3r3a3r9, a3r3a3r9r10, r4a2r10, r4a2r10r11, r5a3r11, r5a3r11r6, a0_r, a1_r, a2_r, a3_r, a12r0_r, a22r1_r, a32r2_r, a02r3_r, a02r4_r, a12r5_r, a0r0a0r6r7_r, a1r1a1r7r8_r, a2r2a2r8r9_r, a3r3a3r9r10_r, r4a2r10r11_r, r5a3r11r6_r, a32r2a02r4, a02r3a12r5 : UNSIGNED (bits-1 downto 0);

begin
    
    a02 <= a0(bits-2 downto 0) & a0(bits-1);
    a12 <= a1(bits-2 downto 0) & a1(bits-1);
    a22 <= a2(bits-2 downto 0) & a2(bits-1);
    a32 <= a3(bits-2 downto 0) & a3(bits-1);
    
    Add1 : AddModMersenne Generic Map (bits) Port Map (a12, r0, a12r0);
    Add2 : AddModMersenne Generic Map (bits) Port Map (a22, r1, a22r1);
    Add3 : AddModMersenne Generic Map (bits) Port Map (a32, r2, a32r2);
    Add4 : AddModMersenne Generic Map (bits) Port Map (a02, r3, a02r3);
    Sub1 : SubModMersenne Generic Map (bits) Port Map (a02, r4, a02r4);
    Sub2 : SubModMersenne Generic Map (bits) Port Map (a12, r5, a12r5);

    Sub3 : SubModMersenne Generic Map (bits) Port Map (a0, r0, a0r0);
    Sub4 : SubModMersenne Generic Map (bits) Port Map (a1, r1, a1r1);
    Sub5 : SubModMersenne Generic Map (bits) Port Map (a2, r2, a2r2);
    Sub6 : SubModMersenne Generic Map (bits) Port Map (a3, r3, a3r3);
    MulAddAdd1 : MulAddAddModMersenne Generic Map (bits) Port Map (a0r0, a0, r6, r7, a0r0a0r6r7);
    MulSubAdd1 : MulSubAddModMersenne Generic Map (bits) Port Map (a1r1, a1, r7, r8, a1r1a1r7r8);
    MulSubAdd2 : MulSubAddModMersenne Generic Map (bits) Port Map (a2r2, a2, r8, r9, a2r2a2r8r9);
    MulSubAdd3 : MulSubAddModMersenne Generic Map (bits) Port Map (a3r3, a3, r9, r10, a3r3a3r9r10);
    MulSubAdd4 : MulSubAddModMersenne Generic Map (bits) Port Map (r4, a2, r10, r11, r4a2r10r11);
    MulSubSub1 : MulSubSubModMersenne Generic Map (bits) Port Map (r5, a3, r11, r6, r5a3r11r6);

    FF1 : FF Generic Map (bits) Port Map (clk, en, a0, a0_r);
    FF2 : FF Generic Map (bits) Port Map (clk, en, a1, a1_r);
    FF3 : FF Generic Map (bits) Port Map (clk, en, a2, a2_r);
    FF4 : FF Generic Map (bits) Port Map (clk, en, a3, a3_r);
    FF5 : FF Generic Map (bits) Port Map (clk, en, a12r0, a12r0_r);
    FF6 : FF Generic Map (bits) Port Map (clk, en, a22r1, a22r1_r);
    FF7 : FF Generic Map (bits) Port Map (clk, en, a32r2, a32r2_r);
    FF8 : FF Generic Map (bits) Port Map (clk, en, a02r3, a02r3_r);
    FF9 : FF Generic Map (bits) Port Map (clk, en, a02r4, a02r4_r);
    FF10 : FF Generic Map (bits) Port Map (clk, en, a12r5, a12r5_r);
    FF11 : FF Generic Map (bits) Port Map (clk, en, a0r0a0r6r7, a0r0a0r6r7_r);
    FF12 : FF Generic Map (bits) Port Map (clk, en, a1r1a1r7r8, a1r1a1r7r8_r);
    FF13 : FF Generic Map (bits) Port Map (clk, en, a2r2a2r8r9, a2r2a2r8r9_r);
    FF14 : FF Generic Map (bits) Port Map (clk, en, a3r3a3r9r10, a3r3a3r9r10_r);
    FF15 : FF Generic Map (bits) Port Map (clk, en, r4a2r10r11, r4a2r10r11_r);
    FF16 : FF Generic Map (bits) Port Map (clk, en, r5a3r11r6, r5a3r11r6_r);

    Add5 : AddModMersenne Generic Map (bits) Port Map (a32r2_r, a02r4_r, a32r2a02r4);
    Add6 : AddModMersenne Generic Map (bits) Port Map (a02r3_r, a12r5_r, a02r3a12r5);
    MulAdd1 : MulAddModMersenne Generic Map (bits) Port Map (a12r0_r, a0_r, a1r1a1r7r8_r, b0);
    MulAddAdd2 : MulAddAddModMersenne Generic Map (bits) Port Map (a22r1_r, a1_r, a2r2a2r8r9_r, r4a2r10r11_r, b1);
    MulAddAdd3 : MulAddAddModMersenne Generic Map (bits) Port Map (a32r2a02r4, a2_r, a3r3a3r9r10_r, r5a3r11r6_r, b2);
    MulAdd2 : MulAddModMersenne Generic Map (bits) Port Map (a02r3a12r5, a3_r, a0r0a0r6r7_r, b3);

end Behavioral;