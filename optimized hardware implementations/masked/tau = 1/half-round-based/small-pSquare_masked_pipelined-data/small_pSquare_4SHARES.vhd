library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.small_pSquare_data_types.ALL;

entity small_pSquare_4SHARES is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           plaintext_s0 : in small_pSquare_state;
           plaintext_s1 : in small_pSquare_state;
           plaintext_s2 : in small_pSquare_state;
           plaintext_s3 : in small_pSquare_state;
           key_s0 : in small_pSquare_state;
           key_s1 : in small_pSquare_state;
           key_s2 : in small_pSquare_state;
           key_s3 : in small_pSquare_state;
           tweak : in small_pSquare_state;
           fresh_randomness : in small_pSquare_4SHARES_randomness;
           ciphertext_s0 : out small_pSquare_state;
           ciphertext_s1 : out small_pSquare_state;
           ciphertext_s2 : out small_pSquare_state;
           ciphertext_s3 : out small_pSquare_state;
           done : out STD_LOGIC);
end small_pSquare_4SHARES;

architecture Behavioral of small_pSquare_4SHARES is

    component SQ_4SHARE is
        Generic (bits : INTEGER := 7);
        Port ( clk : in STD_LOGIC;
               en : in STD_LOGIC;
               a0 : in UNSIGNED (bits-1 downto 0);
               a1 : in UNSIGNED (bits-1 downto 0);
               a2 : in UNSIGNED (bits-1 downto 0);
               a3 : in UNSIGNED (bits-1 downto 0);
               r0 : in UNSIGNED (bits-1 downto 0);
               r1 : in UNSIGNED (bits-1 downto 0);
               r2 : in UNSIGNED (bits-1 downto 0);
               r3 : in UNSIGNED (bits-1 downto 0);
               r4 : in UNSIGNED (bits-1 downto 0);
               r5 : in UNSIGNED (bits-1 downto 0);
               r6 : in UNSIGNED (bits-1 downto 0);
               r7 : in UNSIGNED (bits-1 downto 0);
               r8 : in UNSIGNED (bits-1 downto 0);
               r9 : in UNSIGNED (bits-1 downto 0);
               r10 : in UNSIGNED (bits-1 downto 0);
               r11 : in UNSIGNED (bits-1 downto 0);
               b0 : out UNSIGNED (bits-1 downto 0);
               b1 : out UNSIGNED (bits-1 downto 0);
               b2 : out UNSIGNED (bits-1 downto 0);
               b3 : out UNSIGNED (bits-1 downto 0));
    end component;
    
    component AddModMersenne is
        Generic ( bits : INTEGER := 7);
        Port ( a : in UNSIGNED (bits-1 downto 0);
               b : in UNSIGNED (bits-1 downto 0);
               c : out UNSIGNED (bits-1 downto 0));
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
    
    signal round_tweak, round_tweakey_input_1, round_tweakey_input_2, round_tweakey_input_3, art_output_0, art_output_1, art_output_2, art_output_3, round_reg_0, round_reg_1, round_reg_2, round_reg_3, round_reg2_0, round_reg2_1, round_reg2_2, round_reg2_3 : small_pSquare_state;
    signal art_ou_0, art_ou_1, art_ou_2, art_ou_3, round_tweakey, round_tweakey_input_0 : small_pSquare_state_p1;
    signal round_input_0, round_input_1,round_input_2, round_input_3, round_output_0, round_output_1, round_output_2, round_output_3 : small_pSquare_state_p2;
    signal art_o_0, art_o_1, art_o_2, art_o_3 : small_pSquare_state_p3;
    constant pi : STD_LOGIC_VECTOR(63 downto 0) := x"C90FDAA22168C234";
    signal rot_pi : STD_LOGIC_VECTOR(63 downto 0);
    signal round_constants1, round_constants2, round_constants2_reg, sq1_in, sq1_in_reg : small_pSquare_double;
    signal rc2_choice, f1_in_0, f2_in_0, f3_in_0, f1_in_reg_0, f2_in_reg_0, f3_in_reg_0, f4_in_reg_0, sq1_out_0, sq2_out_0, sq3_out_0, mds1_out_0, mds2_out_0, mds3_out_0, mds4_out_0, sq4_out_0, sq5_out_0, sq6_out_0, mds1_out_reg_0, mds2_out_reg_0, mds3_out_reg_0, mds4_out_reg_0 : UNSIGNED(6 downto 0);
    signal f1_in_1, f2_in_1, f3_in_1, f1_in_reg_1, f2_in_reg_1, f3_in_reg_1, f4_in_reg_1, sq1_out_1, sq2_out_1, sq3_out_1, mds1_out_1, mds2_out_1, mds3_out_1, mds4_out_1, sq4_out_1, sq5_out_1, sq6_out_1, mds1_out_reg_1, mds2_out_reg_1, mds3_out_reg_1, mds4_out_reg_1 : UNSIGNED(6 downto 0);
    signal f1_in_2, f2_in_2, f3_in_2, f1_in_reg_2, f2_in_reg_2, f3_in_reg_2, f4_in_reg_2, sq1_out_2, sq2_out_2, sq3_out_2, mds1_out_2, mds2_out_2, mds3_out_2, mds4_out_2, sq4_out_2, sq5_out_2, sq6_out_2, mds1_out_reg_2, mds2_out_reg_2, mds3_out_reg_2, mds4_out_reg_2 : UNSIGNED(6 downto 0);
    signal f1_in_3, f2_in_3, f3_in_3, f1_in_reg_3, f2_in_reg_3, f3_in_reg_3, f4_in_reg_3, sq1_out_3, sq2_out_3, sq3_out_3, mds1_out_3, mds2_out_3, mds3_out_3, mds4_out_3, sq4_out_3, sq5_out_3, sq6_out_3, mds1_out_reg_3, mds2_out_reg_3, mds3_out_reg_3, mds4_out_reg_3 : UNSIGNED(6 downto 0);
    signal f1_out_0, f2_out_0, f3_out_0, f4_out_0 : UNSIGNED(7 downto 0);
    signal f1_out_1, f2_out_1, f3_out_1, f4_out_1 : UNSIGNED(7 downto 0);
    signal f1_out_2, f2_out_2, f3_out_2, f4_out_2 : UNSIGNED(7 downto 0);
    signal f1_out_3, f2_out_3, f3_out_3, f4_out_3 : UNSIGNED(7 downto 0);
    signal f4_r4_out_add_0, f3_r5_out_add_0, f2_r6_out_add_0, f1_r7_out_add_0, f4_r10_out_add_0, f3_r11_out_add_0, f2_r12_out_add_0, f1_r13_out_add_0 : UNSIGNED(8 downto 0);
    signal f4_r4_out_add_1, f3_r5_out_add_1, f2_r6_out_add_1, f1_r7_out_add_1, f4_r10_out_add_1, f3_r11_out_add_1, f2_r12_out_add_1, f1_r13_out_add_1 : UNSIGNED(8 downto 0);
    signal f4_r4_out_add_2, f3_r5_out_add_2, f2_r6_out_add_2, f1_r7_out_add_2, f4_r10_out_add_2, f3_r11_out_add_2, f2_r12_out_add_2, f1_r13_out_add_2 : UNSIGNED(8 downto 0);
    signal f4_r4_out_add_3, f3_r5_out_add_3, f2_r6_out_add_3, f1_r7_out_add_3, f4_r10_out_add_3, f3_r11_out_add_3, f2_r12_out_add_3, f1_r13_out_add_3 : UNSIGNED(8 downto 0);
    signal sq1_in_r : small_pSquare_double_p1;
    signal sq1_in_rr : small_pSquare_double_p3;
    signal tweakey_active, reg_enable, f_select, f_select_reg : STD_LOGIC;
    
begin

    -- Round-Tweak and Key Addition
    TWK: for i in 0 to 15 generate
        round_tweakey(i) <= ('0' & round_tweak(i)) + ('0' & key_s0(i));
    end generate;

    -- Round-Input and Round-Tweakey Addition
    ARK: for i in 0 to 15 generate
        art_o_0(i) <= ('0' & round_input_0(i)) + ("00" & round_tweakey_input_0(i));
        art_o_1(i) <= ('0' & round_input_1(i)) + ("000" & round_tweakey_input_1(i));
        art_o_2(i) <= ('0' & round_input_2(i)) + ("000" & round_tweakey_input_2(i));
        art_o_3(i) <= ('0' & round_input_3(i)) + ("000" & round_tweakey_input_3(i));
        art_ou_0(i) <= ('0' & art_o_0(i)(6 downto 0)) + ("00000" & art_o_0(i)(9 downto 7));
        art_ou_1(i) <= ('0' & art_o_1(i)(6 downto 0)) + ("00000" & art_o_1(i)(9 downto 7));
        art_ou_2(i) <= ('0' & art_o_2(i)(6 downto 0)) + ("00000" & art_o_2(i)(9 downto 7));
        art_ou_3(i) <= ('0' & art_o_3(i)(6 downto 0)) + ("00000" & art_o_3(i)(9 downto 7));
        art_output_0(i) <= art_ou_0(i)(6 downto 0) + ("000000" & art_ou_0(i)(7));
        art_output_1(i) <= art_ou_1(i)(6 downto 0) + ("000000" & art_ou_1(i)(7));
        art_output_2(i) <= art_ou_2(i)(6 downto 0) + ("000000" & art_ou_2(i)(7));
        art_output_3(i) <= art_ou_3(i)(6 downto 0) + ("000000" & art_ou_3(i)(7));
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
    f1_in_3 <= art_output_3(3) when (f_select = '0') else art_output_3(9);
    f2_in_0 <= art_output_0(2) when (f_select = '0') else art_output_0(8);
    f2_in_1 <= art_output_1(2) when (f_select = '0') else art_output_1(8);
    f2_in_2 <= art_output_2(2) when (f_select = '0') else art_output_2(8);
    f2_in_3 <= art_output_3(2) when (f_select = '0') else art_output_3(8);
    f3_in_0 <= art_output_0(1) when (f_select = '0') else art_output_0(7);
    f3_in_1 <= art_output_1(1) when (f_select = '0') else art_output_1(7);
    f3_in_2 <= art_output_2(1) when (f_select = '0') else art_output_2(7);
    f3_in_3 <= art_output_3(1) when (f_select = '0') else art_output_3(7);
    f1_in_reg_0 <= sq1_in_reg(0) when (f_select_reg = '0') else sq1_in_reg(1);
    f1_in_reg_1 <= round_reg_1(3) when (f_select_reg = '0') else round_reg_1(9);
    f1_in_reg_2 <= round_reg_2(3) when (f_select_reg = '0') else round_reg_2(9);
    f1_in_reg_3 <= round_reg_3(3) when (f_select_reg = '0') else round_reg_3(9);
    f2_in_reg_0 <= round_reg_0(2) when (f_select_reg = '0') else round_reg_0(8);
    f2_in_reg_1 <= round_reg_1(2) when (f_select_reg = '0') else round_reg_1(8);
    f2_in_reg_2 <= round_reg_2(2) when (f_select_reg = '0') else round_reg_2(8);
    f2_in_reg_3 <= round_reg_3(2) when (f_select_reg = '0') else round_reg_3(8);
    f3_in_reg_0 <= round_reg_0(1) when (f_select_reg = '0') else round_reg_0(7);
    f3_in_reg_1 <= round_reg_1(1) when (f_select_reg = '0') else round_reg_1(7);
    f3_in_reg_2 <= round_reg_2(1) when (f_select_reg = '0') else round_reg_2(7);
    f3_in_reg_3 <= round_reg_3(1) when (f_select_reg = '0') else round_reg_3(7);
    f4_in_reg_0 <= round_reg_0(0) when (f_select_reg = '0') else round_reg_0(6);
    f4_in_reg_1 <= round_reg_1(0) when (f_select_reg = '0') else round_reg_1(6);
    f4_in_reg_2 <= round_reg_2(0) when (f_select_reg = '0') else round_reg_2(6);
    f4_in_reg_3 <= round_reg_3(0) when (f_select_reg = '0') else round_reg_3(6);
    rc2_choice <= round_constants2_reg(0) when (f_select_reg = '0') else round_constants2_reg(1);
    
    -- First Non-Linear Layer
    SQ1: SQ_4SHARE Generic Map (7) Port Map (clk, reg_enable, f1_in_0, f1_in_1, f1_in_2, f1_in_3, fresh_randomness(0), fresh_randomness(1), fresh_randomness(2), fresh_randomness(3), fresh_randomness(4), fresh_randomness(5), fresh_randomness(6), fresh_randomness(7), fresh_randomness(8), fresh_randomness(9), fresh_randomness(10), fresh_randomness(11), sq1_out_0, sq1_out_1, sq1_out_2, sq1_out_3);
    SQ2: SQ_4SHARE Generic Map (7) Port Map (clk, reg_enable, f2_in_0, f2_in_1, f2_in_2, f2_in_3, fresh_randomness(12), fresh_randomness(13), fresh_randomness(14), fresh_randomness(15), fresh_randomness(16), fresh_randomness(17), fresh_randomness(18), fresh_randomness(19), fresh_randomness(20), fresh_randomness(21), fresh_randomness(22), fresh_randomness(23), sq2_out_0, sq2_out_1, sq2_out_2, sq2_out_3);
    SQ3: SQ_4SHARE Generic Map (7) Port Map (clk, reg_enable, f3_in_0, f3_in_1, f3_in_2, f3_in_3, fresh_randomness(24), fresh_randomness(25), fresh_randomness(26), fresh_randomness(27), fresh_randomness(28), fresh_randomness(29), fresh_randomness(30), fresh_randomness(31), fresh_randomness(32), fresh_randomness(33), fresh_randomness(34), fresh_randomness(35), sq3_out_0, sq3_out_1, sq3_out_2, sq3_out_3);
    
    -- MDS Matrix Multiplication and Second Round-Constant Addition
    MM_0: MatrixMult_RC Generic Map (7) Port Map (f1_in_reg_0, f2_in_reg_0, f3_in_reg_0, f4_in_reg_0, sq1_out_0, sq2_out_0, sq3_out_0, rc2_choice, mds1_out_0, mds2_out_0, mds3_out_0, mds4_out_0);
    MM_1: MatrixMult Generic Map (7) Port Map (f1_in_reg_1, f2_in_reg_1, f3_in_reg_1, f4_in_reg_1, sq1_out_1, sq2_out_1, sq3_out_1, mds1_out_1, mds2_out_1, mds3_out_1, mds4_out_1);
    MM_2: MatrixMult Generic Map (7) Port Map (f1_in_reg_2, f2_in_reg_2, f3_in_reg_2, f4_in_reg_2, sq1_out_2, sq2_out_2, sq3_out_2, mds1_out_2, mds2_out_2, mds3_out_2, mds4_out_2);
    MM_3: MatrixMult Generic Map (7) Port Map (f1_in_reg_3, f2_in_reg_3, f3_in_reg_3, f4_in_reg_3, sq1_out_3, sq2_out_3, sq3_out_3, mds1_out_3, mds2_out_3, mds3_out_3, mds4_out_3);
    
    -- Second Non-Linear Layer
    SQ4: SQ_4SHARE Generic Map (7) Port Map (clk, reg_enable, mds1_out_0, mds1_out_1, mds1_out_2, mds1_out_3, fresh_randomness(36), fresh_randomness(37), fresh_randomness(38), fresh_randomness(39), fresh_randomness(40), fresh_randomness(41), fresh_randomness(42), fresh_randomness(43), fresh_randomness(44), fresh_randomness(45), fresh_randomness(46), fresh_randomness(47), sq4_out_0, sq4_out_1, sq4_out_2, sq4_out_3);
    SQ5: SQ_4SHARE Generic Map (7) Port Map (clk, reg_enable, mds2_out_0, mds2_out_1, mds2_out_2, mds2_out_3, fresh_randomness(48), fresh_randomness(49), fresh_randomness(50), fresh_randomness(51), fresh_randomness(52), fresh_randomness(53), fresh_randomness(54), fresh_randomness(55), fresh_randomness(56), fresh_randomness(57), fresh_randomness(58), fresh_randomness(59), sq5_out_0, sq5_out_1, sq5_out_2, sq5_out_3);
    SQ6: SQ_4SHARE Generic Map (7) Port Map (clk, reg_enable, mds3_out_0, mds3_out_1, mds3_out_2, mds3_out_3, fresh_randomness(60), fresh_randomness(61), fresh_randomness(62), fresh_randomness(63), fresh_randomness(64), fresh_randomness(65), fresh_randomness(66), fresh_randomness(67), fresh_randomness(68), fresh_randomness(69), fresh_randomness(70), fresh_randomness(71), sq6_out_0, sq6_out_1, sq6_out_2, sq6_out_3);
    FF1_0: FF Generic Map (7) Port Map (clk, reg_enable, mds1_out_0, mds1_out_reg_0);
    FF1_1: FF Generic Map (7) Port Map (clk, reg_enable, mds1_out_1, mds1_out_reg_1);
    FF1_2: FF Generic Map (7) Port Map (clk, reg_enable, mds1_out_2, mds1_out_reg_2);
    FF1_3: FF Generic Map (7) Port Map (clk, reg_enable, mds1_out_3, mds1_out_reg_3);
    FF2_0: FF Generic Map (7) Port Map (clk, reg_enable, mds2_out_0, mds2_out_reg_0);
    FF2_1: FF Generic Map (7) Port Map (clk, reg_enable, mds2_out_1, mds2_out_reg_1);
    FF2_2: FF Generic Map (7) Port Map (clk, reg_enable, mds2_out_2, mds2_out_reg_2);
    FF2_3: FF Generic Map (7) Port Map (clk, reg_enable, mds2_out_3, mds2_out_reg_3);
    FF3_0: FF Generic Map (7) Port Map (clk, reg_enable, mds3_out_0, mds3_out_reg_0);
    FF3_1: FF Generic Map (7) Port Map (clk, reg_enable, mds3_out_1, mds3_out_reg_1);
    FF3_2: FF Generic Map (7) Port Map (clk, reg_enable, mds3_out_2, mds3_out_reg_2);
    FF3_3: FF Generic Map (7) Port Map (clk, reg_enable, mds3_out_3, mds3_out_reg_3);
    FF4_0: FF Generic Map (7) Port Map (clk, reg_enable, mds4_out_0, mds4_out_reg_0);
    FF4_1: FF Generic Map (7) Port Map (clk, reg_enable, mds4_out_1, mds4_out_reg_1);
    FF4_2: FF Generic Map (7) Port Map (clk, reg_enable, mds4_out_2, mds4_out_reg_2);
    FF4_3: FF Generic Map (7) Port Map (clk, reg_enable, mds4_out_3, mds4_out_reg_3);
    f1_out_0 <= ('0' & mds2_out_reg_0) + ('0' & sq4_out_0);
    f1_out_1 <= ('0' & mds2_out_reg_1) + ('0' & sq4_out_1);
    f1_out_2 <= ('0' & mds2_out_reg_2) + ('0' & sq4_out_2);
    f1_out_3 <= ('0' & mds2_out_reg_3) + ('0' & sq4_out_3);
    f2_out_0 <= ('0' & mds3_out_reg_0) + ('0' & sq5_out_0);
    f2_out_1 <= ('0' & mds3_out_reg_1) + ('0' & sq5_out_1);
    f2_out_2 <= ('0' & mds3_out_reg_2) + ('0' & sq5_out_2);
    f2_out_3 <= ('0' & mds3_out_reg_3) + ('0' & sq5_out_3);
    f3_out_0 <= ('0' & mds4_out_reg_0) + ('0' & sq6_out_0);
    f3_out_1 <= ('0' & mds4_out_reg_1) + ('0' & sq6_out_1);
    f3_out_2 <= ('0' & mds4_out_reg_2) + ('0' & sq6_out_2);
    f3_out_3 <= ('0' & mds4_out_reg_3) + ('0' & sq6_out_3);
    f4_out_0 <= ('0' & mds1_out_reg_0);
    f4_out_1 <= ('0' & mds1_out_reg_1);
    f4_out_2 <= ('0' & mds1_out_reg_2);
    f4_out_3 <= ('0' & mds1_out_reg_3);

    -- F Function Result Additions and Position Swap
    f4_r4_out_add_0 <= (("00" & round_reg2_0(4)) + ('0' & f4_out_0)) when (f_select = '1') else ("00" & round_reg2_0(4));
    f4_r4_out_add_1 <= (("00" & round_reg2_1(4)) + ('0' & f4_out_1)) when (f_select = '1') else ("00" & round_reg2_1(4));
    f4_r4_out_add_2 <= (("00" & round_reg2_2(4)) + ('0' & f4_out_2)) when (f_select = '1') else ("00" & round_reg2_2(4));
    f4_r4_out_add_3 <= (("00" & round_reg2_3(4)) + ('0' & f4_out_3)) when (f_select = '1') else ("00" & round_reg2_3(4));
    f3_r5_out_add_0 <= (("00" & round_reg2_0(5)) + ('0' & f3_out_0)) when (f_select = '1') else ("00" & round_reg2_0(5));
    f3_r5_out_add_1 <= (("00" & round_reg2_1(5)) + ('0' & f3_out_1)) when (f_select = '1') else ("00" & round_reg2_1(5));
    f3_r5_out_add_2 <= (("00" & round_reg2_2(5)) + ('0' & f3_out_2)) when (f_select = '1') else ("00" & round_reg2_2(5));
    f3_r5_out_add_3 <= (("00" & round_reg2_3(5)) + ('0' & f3_out_3)) when (f_select = '1') else ("00" & round_reg2_3(5));
    f2_r6_out_add_0 <= (("00" & round_reg2_0(6)) + ('0' & f2_out_0)) when (f_select = '1') else ("00" & round_reg2_0(6));
    f2_r6_out_add_1 <= (("00" & round_reg2_1(6)) + ('0' & f2_out_1)) when (f_select = '1') else ("00" & round_reg2_1(6));
    f2_r6_out_add_2 <= (("00" & round_reg2_2(6)) + ('0' & f2_out_2)) when (f_select = '1') else ("00" & round_reg2_2(6));
    f2_r6_out_add_3 <= (("00" & round_reg2_3(6)) + ('0' & f2_out_3)) when (f_select = '1') else ("00" & round_reg2_3(6));
    f1_r7_out_add_0 <= (("00" & round_reg2_0(7)) + ('0' & f1_out_0)) when (f_select = '1') else ("00" & round_reg2_0(7));
    f1_r7_out_add_1 <= (("00" & round_reg2_1(7)) + ('0' & f1_out_1)) when (f_select = '1') else ("00" & round_reg2_1(7));
    f1_r7_out_add_2 <= (("00" & round_reg2_2(7)) + ('0' & f1_out_2)) when (f_select = '1') else ("00" & round_reg2_2(7));
    f1_r7_out_add_3 <= (("00" & round_reg2_3(7)) + ('0' & f1_out_3)) when (f_select = '1') else ("00" & round_reg2_3(7));
    f4_r10_out_add_0 <= (("00" & round_reg2_0(10)) + ('0' & f4_out_0)) when (f_select = '0') else ("00" & round_reg2_0(10));
    f4_r10_out_add_1 <= (("00" & round_reg2_1(10)) + ('0' & f4_out_1)) when (f_select = '0') else ("00" & round_reg2_1(10));
    f4_r10_out_add_2 <= (("00" & round_reg2_2(10)) + ('0' & f4_out_2)) when (f_select = '0') else ("00" & round_reg2_2(10));
    f4_r10_out_add_3 <= (("00" & round_reg2_3(10)) + ('0' & f4_out_3)) when (f_select = '0') else ("00" & round_reg2_3(10));
    f3_r11_out_add_0 <= (("00" & round_reg2_0(11)) + ('0' & f3_out_0)) when (f_select = '0') else ("00" & round_reg2_0(11));
    f3_r11_out_add_1 <= (("00" & round_reg2_1(11)) + ('0' & f3_out_1)) when (f_select = '0') else ("00" & round_reg2_1(11));
    f3_r11_out_add_2 <= (("00" & round_reg2_2(11)) + ('0' & f3_out_2)) when (f_select = '0') else ("00" & round_reg2_2(11));
    f3_r11_out_add_3 <= (("00" & round_reg2_3(11)) + ('0' & f3_out_3)) when (f_select = '0') else ("00" & round_reg2_3(11));
    f2_r12_out_add_0 <= (("00" & round_reg2_0(12)) + ('0' & f2_out_0)) when (f_select = '0') else ("00" & round_reg2_0(12));
    f2_r12_out_add_1 <= (("00" & round_reg2_1(12)) + ('0' & f2_out_1)) when (f_select = '0') else ("00" & round_reg2_1(12));
    f2_r12_out_add_2 <= (("00" & round_reg2_2(12)) + ('0' & f2_out_2)) when (f_select = '0') else ("00" & round_reg2_2(12));
    f2_r12_out_add_3 <= (("00" & round_reg2_3(12)) + ('0' & f2_out_3)) when (f_select = '0') else ("00" & round_reg2_3(12));
    f1_r13_out_add_0 <= (("00" & round_reg2_0(13)) + ('0' & f1_out_0)) when (f_select = '0') else ("00" & round_reg2_0(13));
    f1_r13_out_add_1 <= (("00" & round_reg2_1(13)) + ('0' & f1_out_1)) when (f_select = '0') else ("00" & round_reg2_1(13));
    f1_r13_out_add_2 <= (("00" & round_reg2_2(13)) + ('0' & f1_out_2)) when (f_select = '0') else ("00" & round_reg2_2(13));
    f1_r13_out_add_3 <= (("00" & round_reg2_3(13)) + ('0' & f1_out_3)) when (f_select = '0') else ("00" & round_reg2_3(13));
    round_output_0(0) <= ("00" & round_reg2_0(2));
    round_output_1(0) <= ("00" & round_reg2_1(2));
    round_output_2(0) <= ("00" & round_reg2_2(2));
    round_output_3(0) <= ("00" & round_reg2_3(2));
    round_output_0(1) <= ("00" & round_reg2_0(3));
    round_output_1(1) <= ("00" & round_reg2_1(3));
    round_output_2(1) <= ("00" & round_reg2_2(3));
    round_output_3(1) <= ("00" & round_reg2_3(3));
    round_output_0(2) <= f4_r4_out_add_0;
    round_output_1(2) <= f4_r4_out_add_1;
    round_output_2(2) <= f4_r4_out_add_2;
    round_output_3(2) <= f4_r4_out_add_3;
    round_output_0(3) <= f3_r5_out_add_0;
    round_output_1(3) <= f3_r5_out_add_1;
    round_output_2(3) <= f3_r5_out_add_2;
    round_output_3(3) <= f3_r5_out_add_3;
    round_output_0(4) <= f2_r6_out_add_0;
    round_output_1(4) <= f2_r6_out_add_1;
    round_output_2(4) <= f2_r6_out_add_2;
    round_output_3(4) <= f2_r6_out_add_3;
    round_output_0(5) <= f1_r7_out_add_0;
    round_output_1(5) <= f1_r7_out_add_1;
    round_output_2(5) <= f1_r7_out_add_2;
    round_output_3(5) <= f1_r7_out_add_3;
    round_output_0(6) <= ("00" & round_reg2_0(8));
    round_output_1(6) <= ("00" & round_reg2_1(8));
    round_output_2(6) <= ("00" & round_reg2_2(8));
    round_output_3(6) <= ("00" & round_reg2_3(8));
    round_output_0(7) <= ("00" & round_reg2_0(9));
    round_output_1(7) <= ("00" & round_reg2_1(9));
    round_output_2(7) <= ("00" & round_reg2_2(9));
    round_output_3(7) <= ("00" & round_reg2_3(9));
    round_output_0(8) <= f4_r10_out_add_0;
    round_output_1(8) <= f4_r10_out_add_1;
    round_output_2(8) <= f4_r10_out_add_2;
    round_output_3(8) <= f4_r10_out_add_3;
    round_output_0(9) <= f3_r11_out_add_0;
    round_output_1(9) <= f3_r11_out_add_1;
    round_output_2(9) <= f3_r11_out_add_2;
    round_output_3(9) <= f3_r11_out_add_3;
    round_output_0(10) <= f2_r12_out_add_0;
    round_output_1(10) <= f2_r12_out_add_1;
    round_output_2(10) <= f2_r12_out_add_2;
    round_output_3(10) <= f2_r12_out_add_3;
    round_output_0(11) <= f1_r13_out_add_0;
    round_output_1(11) <= f1_r13_out_add_1;
    round_output_2(11) <= f1_r13_out_add_2;
    round_output_3(11) <= f1_r13_out_add_3;
    round_output_0(12) <= ("00" & round_reg2_0(14));
    round_output_1(12) <= ("00" & round_reg2_1(14));
    round_output_2(12) <= ("00" & round_reg2_2(14));
    round_output_3(12) <= ("00" & round_reg2_3(14));
    round_output_0(13) <= ("00" & round_reg2_0(15));
    round_output_1(13) <= ("00" & round_reg2_1(15));
    round_output_2(13) <= ("00" & round_reg2_2(15));
    round_output_3(13) <= ("00" & round_reg2_3(15));
    round_output_0(14) <= ("00" & round_reg2_0(0));
    round_output_1(14) <= ("00" & round_reg2_1(0));
    round_output_2(14) <= ("00" & round_reg2_2(0));
    round_output_3(14) <= ("00" & round_reg2_3(0));
    round_output_0(15) <= ("00" & round_reg2_0(1));
    round_output_1(15) <= ("00" & round_reg2_1(1));
    round_output_2(15) <= ("00" & round_reg2_2(1));
    round_output_3(15) <= ("00" & round_reg2_3(1));
    
    -- Round Tweakey Addition only active every N_r Rounds
    round_tweakey_input_0 <= round_tweakey when tweakey_active = '1' else (others => (others => '0'));
    round_tweakey_input_1 <= key_s1 when tweakey_active = '1' else (others => (others => '0'));
    round_tweakey_input_2 <= key_s2 when tweakey_active = '1' else (others => (others => '0'));
    round_tweakey_input_3 <= key_s3 when tweakey_active = '1' else (others => (others => '0'));
    
    -- Round Input Mux
    RoundInput: for i in 0 to 15 generate
        round_input_0(i) <= ("00" & plaintext_s0(i)) when (rst = '1') else round_output_0(i);
        round_input_1(i) <= ("00" & plaintext_s1(i)) when (rst = '1') else round_output_1(i);
        round_input_2(i) <= ("00" & plaintext_s2(i)) when (rst = '1') else round_output_2(i);
        round_input_3(i) <= ("00" & plaintext_s3(i)) when (rst = '1') else round_output_3(i);
    end generate;
    
    -- State Machine
    FSM: process(clk)
        variable stepcounter : integer range 0 to 15;
        variable roundcounter : integer range 0 to 15;
        variable doneflag : integer range 0 to 1;
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                round_tweak                     <= tweak;
                round_reg_0                     <= art_output_0;
                round_reg_1                     <= art_output_1;
                round_reg_2                     <= art_output_2;
                round_reg_3                     <= art_output_3;
                round_reg2_0                    <= round_reg_0;
                round_reg2_1                    <= round_reg_1;
                round_reg2_2                    <= round_reg_2;
                round_reg2_3                    <= round_reg_3;
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
                    round_reg_3                 <= art_output_3;
                    round_reg2_0                <= round_reg_0;
                    round_reg2_1                <= round_reg_1;
                    round_reg2_2                <= round_reg_2;
                    round_reg2_3                <= round_reg_3;
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
                        round_tweak             <= ((round_tweak( 9)(5) & round_tweak( 9)(0) & round_tweak( 9)(3) & round_tweak( 9)(1) & round_tweak( 9)(6) & round_tweak( 9)(4) & round_tweak( 9)(2)), (round_tweak( 5)(4) & round_tweak( 5)(6) & round_tweak( 5)(2) & round_tweak( 5)(0) & round_tweak( 5)(5) & round_tweak( 5)(3) & round_tweak( 5)(1)), (round_tweak(13)(3) & round_tweak(13)(5) & round_tweak(13)(1) & round_tweak(13)(6) & round_tweak(13)(4) & round_tweak(13)(2) & round_tweak(13)(0)), (round_tweak(15)(2) & round_tweak(15)(4) & round_tweak(15)(0) & round_tweak(15)(5) & round_tweak(15)(3) & round_tweak(15)(1) & round_tweak(15)(6)), (round_tweak(12)(1) & round_tweak(12)(3) & round_tweak(12)(6) & round_tweak(12)(4) & round_tweak(12)(2) & round_tweak(12)(0) & round_tweak(12)(5)), (round_tweak( 7)(0) & round_tweak( 7)(2) & round_tweak( 7)(5) & round_tweak( 7)(3) & round_tweak( 7)(1) & round_tweak( 7)(6) & round_tweak( 7)(4)), (round_tweak(14)(6) & round_tweak(14)(1) & round_tweak(14)(4) & round_tweak(14)(2) & round_tweak(14)(0) & round_tweak(14)(5) & round_tweak(14)(3)), (round_tweak( 2)(5) & round_tweak( 2)(0) & round_tweak( 2)(3) & round_tweak( 2)(1) & round_tweak( 2)(6) & round_tweak( 2)(4) & round_tweak( 2)(2)), (round_tweak( 4)(4) & round_tweak( 4)(6) & round_tweak( 4)(2) & round_tweak( 4)(0) & round_tweak( 4)(5) & round_tweak( 4)(3) & round_tweak( 4)(1)), (round_tweak( 6)(3) & round_tweak( 6)(5) & round_tweak( 6)(1) & round_tweak( 6)(6) & round_tweak( 6)(4) & round_tweak( 6)(2) & round_tweak( 6)(0)), (round_tweak( 8)(2) & round_tweak( 8)(4) & round_tweak( 8)(0) & round_tweak( 8)(5) & round_tweak( 8)(3) & round_tweak( 8)(1) & round_tweak( 8)(6)), (round_tweak( 3)(1) & round_tweak( 3)(3) & round_tweak( 3)(6) & round_tweak( 3)(4) & round_tweak( 3)(2) & round_tweak( 3)(0) & round_tweak( 3)(5)), (round_tweak(10)(0) & round_tweak(10)(2) & round_tweak(10)(5) & round_tweak(10)(3) & round_tweak(10)(1) & round_tweak(10)(6) & round_tweak(10)(4)), (round_tweak( 1)(6) & round_tweak( 1)(1) & round_tweak( 1)(4) & round_tweak( 1)(2) & round_tweak( 1)(0) & round_tweak( 1)(5) & round_tweak( 1)(3)), (round_tweak(11)(5) & round_tweak(11)(0) & round_tweak(11)(3) & round_tweak(11)(1) & round_tweak(11)(6) & round_tweak(11)(4) & round_tweak(11)(2)), (round_tweak( 0)(4) & round_tweak( 0)(6) & round_tweak( 0)(2) & round_tweak( 0)(0) & round_tweak( 0)(5) & round_tweak( 0)(3) & round_tweak( 0)(1)));
                        tweakey_active          <= '1';
                    else
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
    ciphertext_s3 <= art_output_3;
    
end Behavioral;
