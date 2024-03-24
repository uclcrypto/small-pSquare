-- Reference implementation. Very inefficient!
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SubModMersenne is
    Generic ( bits : INTEGER := 7);
    Port ( a : in UNSIGNED (bits-1 downto 0);
           b : in UNSIGNED (bits-1 downto 0);
           c : out UNSIGNED (bits-1 downto 0));
end SubModMersenne;

architecture Behavioral of SubModMersenne is

    signal ab : UNSIGNED(bits downto 0);
    signal ab_r : UNSIGNED(bits-1 downto 0);

begin

    ab <= ('0' & a) - ('0' & b);
    ab_r <= ab(bits-1 downto 0) - ((bits-2 downto 0 => '0') & ab(bits));
    c <= (bits-1 downto 0 => '0') when (ab_r = (bits-1 downto 0 => '1')) else ab_r;

end Behavioral;