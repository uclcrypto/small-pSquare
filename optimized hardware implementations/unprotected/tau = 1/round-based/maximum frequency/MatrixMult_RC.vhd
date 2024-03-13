library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MatrixMult_RC is
    Generic ( bits : INTEGER := 7);
    Port ( clk : in STD_LOGIC;
           f1_in : in UNSIGNED (bits-1 downto 0);
           f2_in : in UNSIGNED (bits-1 downto 0);
           f3_in : in UNSIGNED (bits-1 downto 0);
           f4_in : in UNSIGNED (bits-1 downto 0);
           sq1_out : in UNSIGNED (bits-1 downto 0);
           sq2_out : in UNSIGNED (bits-1 downto 0);
           sq3_out : in UNSIGNED (bits-1 downto 0);
           rc : in UNSIGNED (bits-1 downto 0);
           mds1_out : out UNSIGNED (bits-1 downto 0);
           mds2_out : out UNSIGNED (bits-1 downto 0);
           mds3_out : out UNSIGNED (bits-1 downto 0);
           mds4_out : out UNSIGNED (bits-1 downto 0));
end MatrixMult_RC;

architecture Behavioral of MatrixMult_RC is
    
    signal rc_reg  : UNSIGNED (bits-1 downto 0);
    signal mds2_in, mds3_in, mds4_in : UNSIGNED (bits downto 0);
    signal add1_12, add1_34 : UNSIGNED (bits+1 downto 0);
    signal add2_234, add2_124, add1_12_2, add1_34_2 : UNSIGNED (bits+2 downto 0);
    signal mds4_o, mds2_o, mds4_o_reg, mds2_o_reg : UNSIGNED (bits+3 downto 0);
    signal add2_124_4, add2_234_4, add2_124_4_reg, add2_234_4_reg : UNSIGNED (bits+4 downto 0);
    signal mds1_o, mds3_o : UNSIGNED (bits+5 downto 0);
    signal mds1_ou, mds2_ou, mds3_ou, mds4_ou : UNSIGNED (bits downto 0);

begin

    mds2_in <= ('0' & f2_in) + ('0' & sq1_out);
    mds3_in <= ('0' & f3_in) + ('0' & sq2_out);
    mds4_in <= ('0' & f4_in) + ('0' & sq3_out);
    
    add1_12 <= ("00" & f1_in) + ('0' & mds2_in);
    add1_34 <= ('0' & mds3_in) + ('0' & mds4_in);
    
    add2_234 <= ("00" & mds2_in) + ('0' & add1_34);
    add2_124 <= ("00" & mds4_in) + ('0' & add1_12);
    add1_12_2 <= add1_12 & '0';
    add1_34_2 <= add1_34 & '0';
    
    mds4_o <= ('0' & add1_34_2) + ('0' & add2_124);
    mds2_o <= ('0' & add1_12_2) + ('0' & add2_234);
    
    add2_124_4 <= add2_124 & "00";
    add2_234_4 <= add2_234 & "00";
    
    iREG: process (clk)
    begin
        if (rising_edge(clk)) then
            add2_124_4_reg  <= add2_124_4;
            add2_234_4_reg  <= add2_234_4;
            mds2_o_reg      <= mds2_o;
            mds4_o_reg      <= mds4_o;
            rc_reg          <= rc;
        end if;
    end process;
    
    mds1_o <= ('0' & add2_124_4_reg) + ("00" & mds2_o_reg) + ("000000" & rc_reg);
    mds3_o <= ('0' & add2_234_4_reg) + ("00" & mds4_o_reg);
    
    mds1_ou <= ('0' & mds1_o(bits-1 downto 0)) + ((bits-6 downto 0 => '0') & mds1_o(bits+5 downto bits));
    mds2_ou <= ('0' & mds2_o_reg(bits-1 downto 0)) + ((bits-4 downto 0 => '0') & mds2_o_reg(bits+3 downto bits));
    mds3_ou <= ('0' & mds3_o(bits-1 downto 0)) + ((bits-6 downto 0 => '0') & mds3_o(bits+5 downto bits));
    mds4_ou <= ('0' & mds4_o_reg(bits-1 downto 0)) + ((bits-4 downto 0 => '0') & mds4_o_reg(bits+3 downto bits));
    
    mds1_out <= mds1_ou(bits-1 downto 0) + ((bits-2 downto 0 => '0') & mds1_ou(bits));
    mds2_out <= mds2_ou(bits-1 downto 0) + ((bits-2 downto 0 => '0') & mds2_ou(bits));
    mds3_out <= mds3_ou(bits-1 downto 0) + ((bits-2 downto 0 => '0') & mds3_ou(bits));
    mds4_out <= mds4_ou(bits-1 downto 0) + ((bits-2 downto 0 => '0') & mds4_ou(bits));

end Behavioral;