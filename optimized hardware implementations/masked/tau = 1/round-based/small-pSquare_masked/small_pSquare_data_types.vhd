library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package small_pSquare_data_types is
    type small_pSquare_state is array (0 to 15) of UNSIGNED (6 downto 0);
    type small_pSquare_state_p1 is array (0 to 15) of UNSIGNED (7 downto 0);
    type small_pSquare_state_p2 is array (0 to 15) of UNSIGNED (8 downto 0);
    type small_pSquare_state_p3 is array (0 to 15) of UNSIGNED (9 downto 0);
    type small_pSquare_double is array (0 to 1) of UNSIGNED (6 downto 0);
    type small_pSquare_double_p1 is array (0 to 1) of UNSIGNED (7 downto 0);
    type small_pSquare_double_p3 is array (0 to 1) of UNSIGNED (9 downto 0);
    type small_pSquare_2SHARES_randomness is array (0 to 11) of UNSIGNED (6 downto 0);
    type small_pSquare_3SHARES_randomness is array (0 to 29) of UNSIGNED (6 downto 0);
    type small_pSquare_4SHARES_randomness is array (0 to 71) of UNSIGNED (6 downto 0);
end package;