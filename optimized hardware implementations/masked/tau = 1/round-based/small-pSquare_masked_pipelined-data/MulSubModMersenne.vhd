library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MulSubModMersenne is
    Generic ( bits : INTEGER := 7);
    Port ( a : in UNSIGNED (bits-1 downto 0);
           b : in UNSIGNED (bits-1 downto 0);
           c : in UNSIGNED (bits-1 downto 0);
           d : out UNSIGNED (bits-1 downto 0));
end MulSubModMersenne;

architecture Behavioral of MulSubModMersenne is

    signal abc : UNSIGNED(2*bits-1 downto 0);
    signal abc_r : UNSIGNED(bits downto 0);
    constant p : UNSIGNED(bits-1 downto 0) := (OTHERS => '1');

begin

    abc <= a * b + (p - c);
    abc_r <= ('0' & abc(bits-1 downto 0)) + ('0' & abc(2*bits-1 downto bits));
    d <= abc_r(bits-1 downto 0) + ((bits-2 downto 0 => '0') & abc_r(bits));

end Behavioral;