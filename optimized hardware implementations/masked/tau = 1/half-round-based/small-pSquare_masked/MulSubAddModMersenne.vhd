library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MulSubAddModMersenne is
    Generic ( bits : INTEGER := 7);
    Port ( a : in UNSIGNED (bits-1 downto 0);
           b : in UNSIGNED (bits-1 downto 0);
           c : in UNSIGNED (bits-1 downto 0);
           d : in UNSIGNED (bits-1 downto 0);
           e : out UNSIGNED (bits-1 downto 0));
end MulSubAddModMersenne;

architecture Behavioral of MulSubAddModMersenne is

    signal abcd : UNSIGNED(2*bits-1 downto 0);
    signal abcd_r : UNSIGNED(bits downto 0);
    constant p : UNSIGNED(bits-1 downto 0) := (OTHERS => '1');

begin

    abcd <= a * b + (p - c) + d;
    abcd_r <= ('0' & abcd(bits-1 downto 0)) + ('0' & abcd(2*bits-1 downto bits));
    e <= abcd_r(bits-1 downto 0) + ((bits-2 downto 0 => '0') & abcd_r(bits));

end Behavioral;