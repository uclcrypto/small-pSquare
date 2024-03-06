library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SQ_2SHARE is
    Generic (bits : INTEGER := 7);
    Port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           a0 : in UNSIGNED (bits-1 downto 0);
           a1 : in UNSIGNED (bits-1 downto 0);
           r0 : in UNSIGNED (bits-1 downto 0);
           r1 : in UNSIGNED (bits-1 downto 0);
           b0 : out UNSIGNED (bits-1 downto 0);
           b1 : out UNSIGNED (bits-1 downto 0));
end SQ_2SHARE;

architecture Behavioral of SQ_2SHARE is

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
    
    component SquSubModMersenne is
        Generic (bits : INTEGER := 7);
        Port ( a : in UNSIGNED (bits-1 downto 0);
               b : in UNSIGNED (bits-1 downto 0);
               c : out UNSIGNED (bits-1 downto 0));
    end component;
    
    component FF is
        Generic ( bits : INTEGER := 7);
        Port ( clk : in STD_LOGIC;
               en : in STD_LOGIC;
               input : in UNSIGNED ((bits-1) downto 0);
               output : out UNSIGNED ((bits-1) downto 0));
    end component;
    
    signal a12, a12r0, a0r0, a0r0a0r1, a1s, a1sr1, a0_r, a12r0_r, a0r0a0r1_r : UNSIGNED (bits-1 downto 0);
    
begin

    a12 <= a1(bits-2 downto 0) & a1(bits-1);
    Add1 : AddModMersenne Generic Map (bits) Port Map (a12, r0, a12r0);
    Sub1 : SubModMersenne Generic Map (bits) Port Map (a0, r0, a0r0);
    MulAdd1 : MulAddModMersenne Generic Map (bits) Port Map (a0r0, a0, r1, a0r0a0r1);
    SquSub1 : SquSubModMersenne Generic Map (bits) Port Map (a1, r1, a1sr1);
 
    FF1 : FF Generic Map (bits) Port Map (clk, en, a0, a0_r);
    FF2 : FF Generic Map (bits) Port Map (clk, en, a12r0, a12r0_r);
    FF3 : FF Generic Map (bits) Port Map (clk, en, a0r0a0r1, a0r0a0r1_r);
    FF4 : FF Generic Map (bits) Port Map (clk, en, a1sr1, b0);
    
    MulAdd2 : MulAddModMersenne Generic Map (bits) Port Map (a12r0_r, a0_r, a0r0a0r1_r, b1);

end Behavioral;