-- Reference implementation. Very inefficient!
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package small_pSquare_data_types is
    type small_pSquare_state is array (0 to 15) of UNSIGNED (6 downto 0);
    type small_pSquare_double is array (0 to 1) of UNSIGNED (6 downto 0);
    type tweak_schedule is array (0 to 16) of small_pSquare_state;
end package;