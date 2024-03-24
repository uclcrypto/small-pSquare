-- Reference implementation. Very inefficient!
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SquModMersenne is
    Generic ( bits : INTEGER := 7);
    Port ( a : in UNSIGNED (bits-1 downto 0);
           b : out UNSIGNED (bits-1 downto 0));
end SquModMersenne;

architecture Behavioral of SquModMersenne is

    signal aa : UNSIGNED(2*bits-1 downto 0);
    signal aa_r : UNSIGNED(bits downto 0);

begin

    aa <= a * a;
    aa_r <= ('0' & aa(bits-1 downto 0)) + ('0' & aa(2*bits-1 downto bits));
    b <= aa_r(bits-1 downto 0) + ((bits-2 downto 0 => '0') & aa_r(bits));

end Behavioral;