library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.small_pSquare_data_types.ALL;

entity small_pSquare_3SHARES is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           plaintext_s0 : in small_pSquare_state;
           plaintext_s1 : in small_pSquare_state;
           plaintext_s2 : in small_pSquare_state;
           key_s0 : in small_pSquare_state;
           key_s1 : in small_pSquare_state;
           key_s2 : in small_pSquare_state;
           tweak : in small_pSquare_state;
           fresh_randomness : in small_pSquare_3SHARES_randomness;
           ciphertext_s0 : out small_pSquare_state;
           ciphertext_s1 : out small_pSquare_state;
           ciphertext_s2 : out small_pSquare_state;
           done : out STD_LOGIC);
end small_pSquare_3SHARES;

architecture Behavioral of small_pSquare_3SHARES is

    component SQ_3SHARE is
        Generic (bits : INTEGER := 7);
        Port ( clk : in STD_LOGIC;
               en : in STD_LOGIC;
               a0 : in UNSIGNED (bits-1 downto 0);
               a1 : in UNSIGNED (bits-1 downto 0);
               a2 : in UNSIGNED (bits-1 downto 0);
               r0 : in UNSIGNED (bits-1 downto 0);
               r1 : in UNSIGNED (bits-1 downto 0);
               r2 : in UNSIGNED (bits-1 downto 0);
               r3 : in UNSIGNED (bits-1 downto 0);
               r4 : in UNSIGNED (bits-1 downto 0);
               b0 : out UNSIGNED (bits-1 downto 0);
               b1 : out UNSIGNED (bits-1 downto 0);
               b2 : out UNSIGNED (bits-1 downto 0));
    end component;
    
    component FF is
        Generic ( bits : INTEGER := 7);
        Port ( clk : in STD_LOGIC;
               en : in STD_LOGIC;
               input : in UNSIGNED ((bits-1) downto 0);
               output : out UNSIGNED ((bits-1) downto 0));
    end component;
    
    component MatrixMult_RC is
        Generic ( bits : INTEGER := 7);
        Port ( f1_in : in UNSIGNED (bits-1 downto 0);
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
    end component;
    
    component MatrixMult is
        Generic ( bits : INTEGER := 7);
        Port ( f1_in : in UNSIGNED (bits-1 downto 0);
               f2_in : in UNSIGNED (bits-1 downto 0);
               f3_in : in UNSIGNED (bits-1 downto 0);
               f4_in : in UNSIGNED (bits-1 downto 0);
               sq1_out : in UNSIGNED (bits-1 downto 0);
               sq2_out : in UNSIGNED (bits-1 downto 0);
               sq3_out : in UNSIGNED (bits-1 downto 0);
               mds1_out : out UNSIGNED (bits-1 downto 0);
               mds2_out : out UNSIGNED (bits-1 downto 0);
               mds3_out : out UNSIGNED (bits-1 downto 0);
               mds4_out : out UNSIGNED (bits-1 downto 0));
    end component;
    
    signal round_tweak1, round_tweak2, round_tweakey_input_1, round_tweakey_input_2, art_output_0, art_output_1, art_output_2, round_reg_0, round_reg_1, round_reg_2, round_reg2_0, round_reg2_1, round_reg2_2 : small_pSquare_state;
    signal art_ou_0, art_ou_1, art_ou_2, round_tweakey, round_tweakey_input_0 : small_pSquare_state_p1;
    signal round_input_0, round_input_1,round_input_2, round_output_0, round_output_1, round_output_2 : small_pSquare_state_p2;
    signal art_o_0, art_o_1, art_o_2 : small_pSquare_state_p3;
    constant pi : STD_LOGIC_VECTOR(63 downto 0) := x"C90FDAA22168C234";
    signal rot_pi : STD_LOGIC_VECTOR(63 downto 0);
    signal round_constants1, round_constants2, round_constants2_reg, sq1_in, sq1_in_reg : small_pSquare_double;
    signal rc2_choice, f1_in_0, f2_in_0, f3_in_0, f1_in_reg_0, f2_in_reg_0, f3_in_reg_0, f4_in_reg_0, sq1_out_0, sq2_out_0, sq3_out_0, mds1_out_0, mds2_out_0, mds3_out_0, mds4_out_0, sq4_out_0, sq5_out_0, sq6_out_0, mds1_out_reg_0, mds2_out_reg_0, mds3_out_reg_0, mds4_out_reg_0 : UNSIGNED(6 downto 0);
    signal f1_in_1, f2_in_1, f3_in_1, f1_in_reg_1, f2_in_reg_1, f3_in_reg_1, f4_in_reg_1, sq1_out_1, sq2_out_1, sq3_out_1, mds1_out_1, mds2_out_1, mds3_out_1, mds4_out_1, sq4_out_1, sq5_out_1, sq6_out_1, mds1_out_reg_1, mds2_out_reg_1, mds3_out_reg_1, mds4_out_reg_1 : UNSIGNED(6 downto 0);
    signal f1_in_2, f2_in_2, f3_in_2, f1_in_reg_2, f2_in_reg_2, f3_in_reg_2, f4_in_reg_2, sq1_out_2, sq2_out_2, sq3_out_2, mds1_out_2, mds2_out_2, mds3_out_2, mds4_out_2, sq4_out_2, sq5_out_2, sq6_out_2, mds1_out_reg_2, mds2_out_reg_2, mds3_out_reg_2, mds4_out_reg_2 : UNSIGNED(6 downto 0);
    signal f1_out_0, f2_out_0, f3_out_0, f4_out_0 : UNSIGNED(7 downto 0);
    signal f1_out_1, f2_out_1, f3_out_1, f4_out_1 : UNSIGNED(7 downto 0);
    signal f1_out_2, f2_out_2, f3_out_2, f4_out_2 : UNSIGNED(7 downto 0);
    signal f4_r4_out_add_0, f3_r5_out_add_0, f2_r6_out_add_0, f1_r7_out_add_0, f4_r10_out_add_0, f3_r11_out_add_0, f2_r12_out_add_0, f1_r13_out_add_0 : UNSIGNED(8 downto 0);
    signal f4_r4_out_add_1, f3_r5_out_add_1, f2_r6_out_add_1, f1_r7_out_add_1, f4_r10_out_add_1, f3_r11_out_add_1, f2_r12_out_add_1, f1_r13_out_add_1 : UNSIGNED(8 downto 0);
    signal f4_r4_out_add_2, f3_r5_out_add_2, f2_r6_out_add_2, f1_r7_out_add_2, f4_r10_out_add_2, f3_r11_out_add_2, f2_r12_out_add_2, f1_r13_out_add_2 : UNSIGNED(8 downto 0);
    signal sq1_in_r : small_pSquare_double_p1;
    signal sq1_in_rr : small_pSquare_double_p3;
    signal tweakey_active, reg_enable, f_select, f_select_reg : STD_LOGIC;
    
begin

    -- Round-Tweak and Key Addition
    TWK: for i in 0 to 15 generate
        round_tweakey(i) <= ('0' & round_tweak1(i)) + ('0' & key_s0(i));
    end generate;

    -- Round-Input and Round-Tweakey Addition
    ARK: for i in 0 to 15 generate
        art_o_0(i) <= ('0' & round_input_0(i)) + ("00" & round_tweakey_input_0(i));
        art_o_1(i) <= ('0' & round_input_1(i)) + ("000" & round_tweakey_input_1(i));
        art_o_2(i) <= ('0' & round_input_2(i)) + ("000" & round_tweakey_input_2(i));
        art_ou_0(i) <= ('0' & art_o_0(i)(6 downto 0)) + ("00000" & art_o_0(i)(9 downto 7));
        art_ou_1(i) <= ('0' & art_o_1(i)(6 downto 0)) + ("00000" & art_o_1(i)(9 downto 7));
        art_ou_2(i) <= ('0' & art_o_2(i)(6 downto 0)) + ("00000" & art_o_2(i)(9 downto 7));
        art_output_0(i) <= art_ou_0(i)(6 downto 0) + ("000000" & art_ou_0(i)(7));
        art_output_1(i) <= art_ou_1(i)(6 downto 0) + ("000000" & art_ou_1(i)(7));
        art_output_2(i) <= art_ou_2(i)(6 downto 0) + ("000000" & art_ou_2(i)(7));
        -- First Round-Constant Addition
        RC1_1: if i = 3 generate
            sq1_in_rr(0) <= ('0' & round_input_0(i)) + ("00" & round_tweakey_input_0(i)) + ("000" & round_constants1(0));
            sq1_in_r(0) <= ('0' & sq1_in_rr(0)(6 downto 0)) + ("00000" & sq1_in_rr(0)(9 downto 7));
            sq1_in(0) <= sq1_in_r(0)(6 downto 0) + ("000000" & sq1_in_r(0)(7));
        end generate;
        RC1_2: if i = 9 generate
            sq1_in_rr(1) <= ('0' & round_input_0(i)) + ("00" & round_tweakey_input_0(i)) + ("000" & round_constants1(1));
            sq1_in_r(1) <= ('0' & sq1_in_rr(1)(6 downto 0)) + ("00000" & sq1_in_rr(1)(9 downto 7));
            sq1_in(1) <= sq1_in_r(1)(6 downto 0) + ("000000" & sq1_in_r(1)(7));
        end generate;
    end generate;

    -- Round-Constant Partitioning
    round_constants1 <= (UNSIGNED(rot_pi(6 downto 0)), UNSIGNED(rot_pi(38 downto 32)));
    round_constants2 <= (UNSIGNED(rot_pi(54 downto 48)), UNSIGNED(rot_pi(22 downto 16)));
    
    -- F-Function
    FFC_1: FF Generic Map (7) Port Map (clk, reg_enable, round_constants2(0), round_constants2_reg(0));
    FFC_2: FF Generic Map (7) Port Map (clk, reg_enable, round_constants2(1), round_constants2_reg(1));
    FFC_3: FF Generic Map (7) Port Map (clk, reg_enable, sq1_in(0), sq1_in_reg(0));
    FFC_4: FF Generic Map (7) Port Map (clk, reg_enable, sq1_in(1), sq1_in_reg(1));
    
    f1_in_0 <= sq1_in(0) when (f_select = '0') else sq1_in(1);
    f1_in_1 <= art_output_1(3) when (f_select = '0') else art_output_1(9);
    f1_in_2 <= art_output_2(3) when (f_select = '0') else art_output_2(9);
    f2_in_0 <= art_output_0(2) when (f_select = '0') else art_output_0(8);
    f2_in_1 <= art_output_1(2) when (f_select = '0') else art_output_1(8);
    f2_in_2 <= art_output_2(2) when (f_select = '0') else art_output_2(8);
    f3_in_0 <= art_output_0(1) when (f_select = '0') else art_output_0(7);
    f3_in_1 <= art_output_1(1) when (f_select = '0') else art_output_1(7);
    f3_in_2 <= art_output_2(1) when (f_select = '0') else art_output_2(7);
    f1_in_reg_0 <= sq1_in_reg(0) when (f_select_reg = '0') else sq1_in_reg(1);
    f1_in_reg_1 <= round_reg_1(3) when (f_select_reg = '0') else round_reg_1(9);
    f1_in_reg_2 <= round_reg_2(3) when (f_select_reg = '0') else round_reg_2(9);
    f2_in_reg_0 <= round_reg_0(2) when (f_select_reg = '0') else round_reg_0(8);
    f2_in_reg_1 <= round_reg_1(2) when (f_select_reg = '0') else round_reg_1(8);
    f2_in_reg_2 <= round_reg_2(2) when (f_select_reg = '0') else round_reg_2(8);
    f3_in_reg_0 <= round_reg_0(1) when (f_select_reg = '0') else round_reg_0(7);
    f3_in_reg_1 <= round_reg_1(1) when (f_select_reg = '0') else round_reg_1(7);
    f3_in_reg_2 <= round_reg_2(1) when (f_select_reg = '0') else round_reg_2(7);
    f4_in_reg_0 <= round_reg_0(0) when (f_select_reg = '0') else round_reg_0(6);
    f4_in_reg_1 <= round_reg_1(0) when (f_select_reg = '0') else round_reg_1(6);
    f4_in_reg_2 <= round_reg_2(0) when (f_select_reg = '0') else round_reg_2(6);
    rc2_choice <= round_constants2_reg(0) when (f_select_reg = '0') else round_constants2_reg(1);
    
    -- First Non-Linear Layer
    SQ1: SQ_3SHARE Generic Map (7) Port Map (clk, reg_enable, f1_in_0, f1_in_1, f1_in_2, fresh_randomness(0), fresh_randomness(1), fresh_randomness(2), fresh_randomness(3), fresh_randomness(4), sq1_out_0, sq1_out_1, sq1_out_2);
    SQ2: SQ_3SHARE Generic Map (7) Port Map (clk, reg_enable, f2_in_0, f2_in_1, f2_in_2, fresh_randomness(5), fresh_randomness(6), fresh_randomness(7), fresh_randomness(8), fresh_randomness(9), sq2_out_0, sq2_out_1, sq2_out_2);
    SQ3: SQ_3SHARE Generic Map (7) Port Map (clk, reg_enable, f3_in_0, f3_in_1, f3_in_2, fresh_randomness(10), fresh_randomness(11), fresh_randomness(12), fresh_randomness(13), fresh_randomness(14), sq3_out_0, sq3_out_1, sq3_out_2);
    
    -- MDS Matrix Multiplication and Second Round-Constant Addition
    MM_0: MatrixMult_RC Generic Map (7) Port Map (f1_in_reg_0, f2_in_reg_0, f3_in_reg_0, f4_in_reg_0, sq1_out_0, sq2_out_0, sq3_out_0, rc2_choice, mds1_out_0, mds2_out_0, mds3_out_0, mds4_out_0);
    MM_1: MatrixMult Generic Map (7) Port Map (f1_in_reg_1, f2_in_reg_1, f3_in_reg_1, f4_in_reg_1, sq1_out_1, sq2_out_1, sq3_out_1, mds1_out_1, mds2_out_1, mds3_out_1, mds4_out_1);
    MM_2: MatrixMult Generic Map (7) Port Map (f1_in_reg_2, f2_in_reg_2, f3_in_reg_2, f4_in_reg_2, sq1_out_2, sq2_out_2, sq3_out_2, mds1_out_2, mds2_out_2, mds3_out_2, mds4_out_2);

    -- Second Non-Linear Layer
    SQ4: SQ_3SHARE Generic Map (7) Port Map (clk, reg_enable, mds1_out_0, mds1_out_1, mds1_out_2, fresh_randomness(15), fresh_randomness(16), fresh_randomness(17), fresh_randomness(18), fresh_randomness(19), sq4_out_0, sq4_out_1, sq4_out_2);
    SQ5: SQ_3SHARE Generic Map (7) Port Map (clk, reg_enable, mds2_out_0, mds2_out_1, mds2_out_2, fresh_randomness(20), fresh_randomness(21), fresh_randomness(22), fresh_randomness(23), fresh_randomness(24), sq5_out_0, sq5_out_1, sq5_out_2);
    SQ6: SQ_3SHARE Generic Map (7) Port Map (clk, reg_enable, mds3_out_0, mds3_out_1, mds3_out_2, fresh_randomness(25), fresh_randomness(26), fresh_randomness(27), fresh_randomness(28), fresh_randomness(29), sq6_out_0, sq6_out_1, sq6_out_2);
    FF1_0: FF Generic Map (7) Port Map (clk, reg_enable, mds1_out_0, mds1_out_reg_0);
    FF1_1: FF Generic Map (7) Port Map (clk, reg_enable, mds1_out_1, mds1_out_reg_1);
    FF1_2: FF Generic Map (7) Port Map (clk, reg_enable, mds1_out_2, mds1_out_reg_2);
    FF2_0: FF Generic Map (7) Port Map (clk, reg_enable, mds2_out_0, mds2_out_reg_0);
    FF2_1: FF Generic Map (7) Port Map (clk, reg_enable, mds2_out_1, mds2_out_reg_1);
    FF2_2: FF Generic Map (7) Port Map (clk, reg_enable, mds2_out_2, mds2_out_reg_2);
    FF3_0: FF Generic Map (7) Port Map (clk, reg_enable, mds3_out_0, mds3_out_reg_0);
    FF3_1: FF Generic Map (7) Port Map (clk, reg_enable, mds3_out_1, mds3_out_reg_1);
    FF3_2: FF Generic Map (7) Port Map (clk, reg_enable, mds3_out_2, mds3_out_reg_2);
    FF4_0: FF Generic Map (7) Port Map (clk, reg_enable, mds4_out_0, mds4_out_reg_0);
    FF4_1: FF Generic Map (7) Port Map (clk, reg_enable, mds4_out_1, mds4_out_reg_1);
    FF4_2: FF Generic Map (7) Port Map (clk, reg_enable, mds4_out_2, mds4_out_reg_2);
    f1_out_0 <= ('0' & mds2_out_reg_0) + ('0' & sq4_out_0);
    f1_out_1 <= ('0' & mds2_out_reg_1) + ('0' & sq4_out_1);
    f1_out_2 <= ('0' & mds2_out_reg_2) + ('0' & sq4_out_2);
    f2_out_0 <= ('0' & mds3_out_reg_0) + ('0' & sq5_out_0);
    f2_out_1 <= ('0' & mds3_out_reg_1) + ('0' & sq5_out_1);
    f2_out_2 <= ('0' & mds3_out_reg_2) + ('0' & sq5_out_2);
    f3_out_0 <= ('0' & mds4_out_reg_0) + ('0' & sq6_out_0);
    f3_out_1 <= ('0' & mds4_out_reg_1) + ('0' & sq6_out_1);
    f3_out_2 <= ('0' & mds4_out_reg_2) + ('0' & sq6_out_2);
    f4_out_0 <= ('0' & mds1_out_reg_0);
    f4_out_1 <= ('0' & mds1_out_reg_1);
    f4_out_2 <= ('0' & mds1_out_reg_2);

    -- F Function Result Additions and Position Swap
    f4_r4_out_add_0 <= (("00" & round_reg2_0(4)) + ('0' & f4_out_0)) when (f_select = '1') else ("00" & round_reg2_0(4));
    f4_r4_out_add_1 <= (("00" & round_reg2_1(4)) + ('0' & f4_out_1)) when (f_select = '1') else ("00" & round_reg2_1(4));
    f4_r4_out_add_2 <= (("00" & round_reg2_2(4)) + ('0' & f4_out_2)) when (f_select = '1') else ("00" & round_reg2_2(4));
    f3_r5_out_add_0 <= (("00" & round_reg2_0(5)) + ('0' & f3_out_0)) when (f_select = '1') else ("00" & round_reg2_0(5));
    f3_r5_out_add_1 <= (("00" & round_reg2_1(5)) + ('0' & f3_out_1)) when (f_select = '1') else ("00" & round_reg2_1(5));
    f3_r5_out_add_2 <= (("00" & round_reg2_2(5)) + ('0' & f3_out_2)) when (f_select = '1') else ("00" & round_reg2_2(5));
    f2_r6_out_add_0 <= (("00" & round_reg2_0(6)) + ('0' & f2_out_0)) when (f_select = '1') else ("00" & round_reg2_0(6));
    f2_r6_out_add_1 <= (("00" & round_reg2_1(6)) + ('0' & f2_out_1)) when (f_select = '1') else ("00" & round_reg2_1(6));
    f2_r6_out_add_2 <= (("00" & round_reg2_2(6)) + ('0' & f2_out_2)) when (f_select = '1') else ("00" & round_reg2_2(6));
    f1_r7_out_add_0 <= (("00" & round_reg2_0(7)) + ('0' & f1_out_0)) when (f_select = '1') else ("00" & round_reg2_0(7));
    f1_r7_out_add_1 <= (("00" & round_reg2_1(7)) + ('0' & f1_out_1)) when (f_select = '1') else ("00" & round_reg2_1(7));
    f1_r7_out_add_2 <= (("00" & round_reg2_2(7)) + ('0' & f1_out_2)) when (f_select = '1') else ("00" & round_reg2_2(7));
    f4_r10_out_add_0 <= (("00" & round_reg2_0(10)) + ('0' & f4_out_0)) when (f_select = '0') else ("00" & round_reg2_0(10));
    f4_r10_out_add_1 <= (("00" & round_reg2_1(10)) + ('0' & f4_out_1)) when (f_select = '0') else ("00" & round_reg2_1(10));
    f4_r10_out_add_2 <= (("00" & round_reg2_2(10)) + ('0' & f4_out_2)) when (f_select = '0') else ("00" & round_reg2_2(10));
    f3_r11_out_add_0 <= (("00" & round_reg2_0(11)) + ('0' & f3_out_0)) when (f_select = '0') else ("00" & round_reg2_0(11));
    f3_r11_out_add_1 <= (("00" & round_reg2_1(11)) + ('0' & f3_out_1)) when (f_select = '0') else ("00" & round_reg2_1(11));
    f3_r11_out_add_2 <= (("00" & round_reg2_2(11)) + ('0' & f3_out_2)) when (f_select = '0') else ("00" & round_reg2_2(11));
    f2_r12_out_add_0 <= (("00" & round_reg2_0(12)) + ('0' & f2_out_0)) when (f_select = '0') else ("00" & round_reg2_0(12));
    f2_r12_out_add_1 <= (("00" & round_reg2_1(12)) + ('0' & f2_out_1)) when (f_select = '0') else ("00" & round_reg2_1(12));
    f2_r12_out_add_2 <= (("00" & round_reg2_2(12)) + ('0' & f2_out_2)) when (f_select = '0') else ("00" & round_reg2_2(12));
    f1_r13_out_add_0 <= (("00" & round_reg2_0(13)) + ('0' & f1_out_0)) when (f_select = '0') else ("00" & round_reg2_0(13));
    f1_r13_out_add_1 <= (("00" & round_reg2_1(13)) + ('0' & f1_out_1)) when (f_select = '0') else ("00" & round_reg2_1(13));
    f1_r13_out_add_2 <= (("00" & round_reg2_2(13)) + ('0' & f1_out_2)) when (f_select = '0') else ("00" & round_reg2_2(13));
    round_output_0(0) <= ("00" & round_reg2_0(2));
    round_output_1(0) <= ("00" & round_reg2_1(2));
    round_output_2(0) <= ("00" & round_reg2_2(2));
    round_output_0(1) <= ("00" & round_reg2_0(3));
    round_output_1(1) <= ("00" & round_reg2_1(3));
    round_output_2(1) <= ("00" & round_reg2_2(3));
    round_output_0(2) <= f4_r4_out_add_0;
    round_output_1(2) <= f4_r4_out_add_1;
    round_output_2(2) <= f4_r4_out_add_2;
    round_output_0(3) <= f3_r5_out_add_0;
    round_output_1(3) <= f3_r5_out_add_1;
    round_output_2(3) <= f3_r5_out_add_2;
    round_output_0(4) <= f2_r6_out_add_0;
    round_output_1(4) <= f2_r6_out_add_1;
    round_output_2(4) <= f2_r6_out_add_2;
    round_output_0(5) <= f1_r7_out_add_0;
    round_output_1(5) <= f1_r7_out_add_1;
    round_output_2(5) <= f1_r7_out_add_2;
    round_output_0(6) <= ("00" & round_reg2_0(8));
    round_output_1(6) <= ("00" & round_reg2_1(8));
    round_output_2(6) <= ("00" & round_reg2_2(8));
    round_output_0(7) <= ("00" & round_reg2_0(9));
    round_output_1(7) <= ("00" & round_reg2_1(9));
    round_output_2(7) <= ("00" & round_reg2_2(9));
    round_output_0(8) <= f4_r10_out_add_0;
    round_output_1(8) <= f4_r10_out_add_1;
    round_output_2(8) <= f4_r10_out_add_2;
    round_output_0(9) <= f3_r11_out_add_0;
    round_output_1(9) <= f3_r11_out_add_1;
    round_output_2(9) <= f3_r11_out_add_2;
    round_output_0(10) <= f2_r12_out_add_0;
    round_output_1(10) <= f2_r12_out_add_1;
    round_output_2(10) <= f2_r12_out_add_2;
    round_output_0(11) <= f1_r13_out_add_0;
    round_output_1(11) <= f1_r13_out_add_1;
    round_output_2(11) <= f1_r13_out_add_2;
    round_output_0(12) <= ("00" & round_reg2_0(14));
    round_output_1(12) <= ("00" & round_reg2_1(14));
    round_output_2(12) <= ("00" & round_reg2_2(14));
    round_output_0(13) <= ("00" & round_reg2_0(15));
    round_output_1(13) <= ("00" & round_reg2_1(15));
    round_output_2(13) <= ("00" & round_reg2_2(15));
    round_output_0(14) <= ("00" & round_reg2_0(0));
    round_output_1(14) <= ("00" & round_reg2_1(0));
    round_output_2(14) <= ("00" & round_reg2_2(0));
    round_output_0(15) <= ("00" & round_reg2_0(1));
    round_output_1(15) <= ("00" & round_reg2_1(1));
    round_output_2(15) <= ("00" & round_reg2_2(1));
    
    -- Round Tweakey Addition only active every N_r Rounds
    round_tweakey_input_0 <= round_tweakey when tweakey_active = '1' else (others => (others => '0'));
    round_tweakey_input_1 <= key_s1 when tweakey_active = '1' else (others => (others => '0'));
    round_tweakey_input_2 <= key_s2 when tweakey_active = '1' else (others => (others => '0'));
    
    -- Round Input Mux
    RoundInput: for i in 0 to 15 generate
        round_input_0(i) <= ("00" & plaintext_s0(i)) when (rst = '1') else round_output_0(i);
        round_input_1(i) <= ("00" & plaintext_s1(i)) when (rst = '1') else round_output_1(i);
        round_input_2(i) <= ("00" & plaintext_s2(i)) when (rst = '1') else round_output_2(i);
    end generate;
    
    -- State Machine
    FSM: process(clk)
        variable stepcounter : integer range 0 to 15;
        variable roundcounter : integer range 0 to 15;
        variable doneflag : integer range 0 to 1;
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                round_tweak1                    <= tweak;
                round_tweak2                    <= round_tweak1;
                round_reg_0                     <= art_output_0;
                round_reg_1                     <= art_output_1;
                round_reg_2                     <= art_output_2;
                round_reg2_0                    <= round_reg_0;
                round_reg2_1                    <= round_reg_1;
                round_reg2_2                    <= round_reg_2;
                rot_pi                          <= pi;
                stepcounter                     := 0;
                roundcounter                    := 0;
                doneflag                        := 0;
                done                            <= '0';
                tweakey_active                  <= '1';
                reg_enable                      <= '1';
                f_select                        <= '0';
                f_select_reg                    <= '0';
            else
                if(doneflag = 0) then
                    round_reg_0                 <= art_output_0;
                    round_reg_1                 <= art_output_1;
                    round_reg_2                 <= art_output_2;
                    round_reg2_0                <= round_reg_0;
                    round_reg2_1                <= round_reg_1;
                    round_reg2_2                <= round_reg_2;
                    reg_enable                  <= '1';
                    if ((stepcounter mod 2) = 0) then
                        f_select                <= f_select XOR '1';
                        if (f_select = '1') then
                            rot_pi              <= rot_pi(62 downto 0) & rot_pi(63);
                        end if;
                    end if;
                    f_select_reg                <= f_select;
                    if (stepcounter < 14) then
                        stepcounter             := stepcounter + 1;
                        tweakey_active          <= '0';
                    elsif (stepcounter = 14) then
                        stepcounter             := stepcounter + 1;
                        round_tweak2            <= ((round_tweak1( 9)(5) & round_tweak1( 9)(0) & round_tweak1( 9)(3) & round_tweak1( 9)(1) & round_tweak1( 9)(6) & round_tweak1( 9)(4) & round_tweak1( 9)(2)), (round_tweak1( 5)(4) & round_tweak1( 5)(6) & round_tweak1( 5)(2) & round_tweak1( 5)(0) & round_tweak1( 5)(5) & round_tweak1( 5)(3) & round_tweak1( 5)(1)), (round_tweak1(13)(3) & round_tweak1(13)(5) & round_tweak1(13)(1) & round_tweak1(13)(6) & round_tweak1(13)(4) & round_tweak1(13)(2) & round_tweak1(13)(0)), (round_tweak1(15)(2) & round_tweak1(15)(4) & round_tweak1(15)(0) & round_tweak1(15)(5) & round_tweak1(15)(3) & round_tweak1(15)(1) & round_tweak1(15)(6)), (round_tweak1(12)(1) & round_tweak1(12)(3) & round_tweak1(12)(6) & round_tweak1(12)(4) & round_tweak1(12)(2) & round_tweak1(12)(0) & round_tweak1(12)(5)), (round_tweak1( 7)(0) & round_tweak1( 7)(2) & round_tweak1( 7)(5) & round_tweak1( 7)(3) & round_tweak1( 7)(1) & round_tweak1( 7)(6) & round_tweak1( 7)(4)), (round_tweak1(14)(6) & round_tweak1(14)(1) & round_tweak1(14)(4) & round_tweak1(14)(2) & round_tweak1(14)(0) & round_tweak1(14)(5) & round_tweak1(14)(3)), (round_tweak1( 2)(5) & round_tweak1( 2)(0) & round_tweak1( 2)(3) & round_tweak1( 2)(1) & round_tweak1( 2)(6) & round_tweak1( 2)(4) & round_tweak1( 2)(2)), (round_tweak1( 4)(4) & round_tweak1( 4)(6) & round_tweak1( 4)(2) & round_tweak1( 4)(0) & round_tweak1( 4)(5) & round_tweak1( 4)(3) & round_tweak1( 4)(1)), (round_tweak1( 6)(3) & round_tweak1( 6)(5) & round_tweak1( 6)(1) & round_tweak1( 6)(6) & round_tweak1( 6)(4) & round_tweak1( 6)(2) & round_tweak1( 6)(0)), (round_tweak1( 8)(2) & round_tweak1( 8)(4) & round_tweak1( 8)(0) & round_tweak1( 8)(5) & round_tweak1( 8)(3) & round_tweak1( 8)(1) & round_tweak1( 8)(6)), (round_tweak1( 3)(1) & round_tweak1( 3)(3) & round_tweak1( 3)(6) & round_tweak1( 3)(4) & round_tweak1( 3)(2) & round_tweak1( 3)(0) & round_tweak1( 3)(5)), (round_tweak1(10)(0) & round_tweak1(10)(2) & round_tweak1(10)(5) & round_tweak1(10)(3) & round_tweak1(10)(1) & round_tweak1(10)(6) & round_tweak1(10)(4)), (round_tweak1( 1)(6) & round_tweak1( 1)(1) & round_tweak1( 1)(4) & round_tweak1( 1)(2) & round_tweak1( 1)(0) & round_tweak1( 1)(5) & round_tweak1( 1)(3)), (round_tweak1(11)(5) & round_tweak1(11)(0) & round_tweak1(11)(3) & round_tweak1(11)(1) & round_tweak1(11)(6) & round_tweak1(11)(4) & round_tweak1(11)(2)), (round_tweak1( 0)(4) & round_tweak1( 0)(6) & round_tweak1( 0)(2) & round_tweak1( 0)(0) & round_tweak1( 0)(5) & round_tweak1( 0)(3) & round_tweak1( 0)(1)));
                        round_tweak1            <= ((round_tweak2( 9)(5) & round_tweak2( 9)(0) & round_tweak2( 9)(3) & round_tweak2( 9)(1) & round_tweak2( 9)(6) & round_tweak2( 9)(4) & round_tweak2( 9)(2)), (round_tweak2( 5)(4) & round_tweak2( 5)(6) & round_tweak2( 5)(2) & round_tweak2( 5)(0) & round_tweak2( 5)(5) & round_tweak2( 5)(3) & round_tweak2( 5)(1)), (round_tweak2(13)(3) & round_tweak2(13)(5) & round_tweak2(13)(1) & round_tweak2(13)(6) & round_tweak2(13)(4) & round_tweak2(13)(2) & round_tweak2(13)(0)), (round_tweak2(15)(2) & round_tweak2(15)(4) & round_tweak2(15)(0) & round_tweak2(15)(5) & round_tweak2(15)(3) & round_tweak2(15)(1) & round_tweak2(15)(6)), (round_tweak2(12)(1) & round_tweak2(12)(3) & round_tweak2(12)(6) & round_tweak2(12)(4) & round_tweak2(12)(2) & round_tweak2(12)(0) & round_tweak2(12)(5)), (round_tweak2( 7)(0) & round_tweak2( 7)(2) & round_tweak2( 7)(5) & round_tweak2( 7)(3) & round_tweak2( 7)(1) & round_tweak2( 7)(6) & round_tweak2( 7)(4)), (round_tweak2(14)(6) & round_tweak2(14)(1) & round_tweak2(14)(4) & round_tweak2(14)(2) & round_tweak2(14)(0) & round_tweak2(14)(5) & round_tweak2(14)(3)), (round_tweak2( 2)(5) & round_tweak2( 2)(0) & round_tweak2( 2)(3) & round_tweak2( 2)(1) & round_tweak2( 2)(6) & round_tweak2( 2)(4) & round_tweak2( 2)(2)), (round_tweak2( 4)(4) & round_tweak2( 4)(6) & round_tweak2( 4)(2) & round_tweak2( 4)(0) & round_tweak2( 4)(5) & round_tweak2( 4)(3) & round_tweak2( 4)(1)), (round_tweak2( 6)(3) & round_tweak2( 6)(5) & round_tweak2( 6)(1) & round_tweak2( 6)(6) & round_tweak2( 6)(4) & round_tweak2( 6)(2) & round_tweak2( 6)(0)), (round_tweak2( 8)(2) & round_tweak2( 8)(4) & round_tweak2( 8)(0) & round_tweak2( 8)(5) & round_tweak2( 8)(3) & round_tweak2( 8)(1) & round_tweak2( 8)(6)), (round_tweak2( 3)(1) & round_tweak2( 3)(3) & round_tweak2( 3)(6) & round_tweak2( 3)(4) & round_tweak2( 3)(2) & round_tweak2( 3)(0) & round_tweak2( 3)(5)), (round_tweak2(10)(0) & round_tweak2(10)(2) & round_tweak2(10)(5) & round_tweak2(10)(3) & round_tweak2(10)(1) & round_tweak2(10)(6) & round_tweak2(10)(4)), (round_tweak2( 1)(6) & round_tweak2( 1)(1) & round_tweak2( 1)(4) & round_tweak2( 1)(2) & round_tweak2( 1)(0) & round_tweak2( 1)(5) & round_tweak2( 1)(3)), (round_tweak2(11)(5) & round_tweak2(11)(0) & round_tweak2(11)(3) & round_tweak2(11)(1) & round_tweak2(11)(6) & round_tweak2(11)(4) & round_tweak2(11)(2)), (round_tweak2( 0)(4) & round_tweak2( 0)(6) & round_tweak2( 0)(2) & round_tweak2( 0)(0) & round_tweak2( 0)(5) & round_tweak2( 0)(3) & round_tweak2( 0)(1)));
                        tweakey_active          <= '1';
                    else
                        round_tweak1            <= round_tweak2;
                        round_tweak2            <= round_tweak1;
                        if (roundcounter = 15) then
                            doneflag            := 1;
                            reg_enable          <= '0';
                            done                <= '1';
                        else
                            stepcounter         := 0;
                            roundcounter        := roundcounter + 1;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    ciphertext_s0 <= art_output_0;
    ciphertext_s1 <= art_output_1;
    ciphertext_s2 <= art_output_2;
    
end Behavioral;