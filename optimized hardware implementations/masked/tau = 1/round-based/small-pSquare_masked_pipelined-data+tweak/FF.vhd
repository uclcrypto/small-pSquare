library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FF is
    Generic ( bits : INTEGER := 7);
    Port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           input : in UNSIGNED ((bits-1) downto 0);
           output : out UNSIGNED ((bits-1) downto 0));
end FF;

architecture Behavioral of FF is

begin

    REG : process(clk)
    begin
        if (rising_edge(clk)) then
            if (en = '1') then
                output <= input;
            end if;
        end if;
    end process;

end Behavioral;