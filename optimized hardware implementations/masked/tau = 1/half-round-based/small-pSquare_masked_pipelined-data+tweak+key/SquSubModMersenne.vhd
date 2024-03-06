library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SquSubModMersenne is
    Generic ( bits : INTEGER := 7);
    Port ( a : in UNSIGNED (bits-1 downto 0);
           b : in UNSIGNED (bits-1 downto 0);
           c : out UNSIGNED (bits-1 downto 0));
end SquSubModMersenne;

architecture Behavioral of SquSubModMersenne is

    signal aab : UNSIGNED(2*bits-1 downto 0);
    signal aab_r : UNSIGNED(bits downto 0);
    constant p : UNSIGNED(bits-1 downto 0) := (OTHERS => '1');

begin

    aab <= a * a + (p - b);
    aab_r <= ('0' & aab(bits-1 downto 0)) + ('0' & aab(2*bits-1 downto bits));
    c <= aab_r(bits-1 downto 0) + ((bits-2 downto 0 => '0') & aab_r(bits));

end Behavioral;