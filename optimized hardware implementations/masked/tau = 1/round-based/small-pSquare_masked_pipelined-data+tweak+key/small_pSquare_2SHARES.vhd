library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.small_pSquare_data_types.ALL;

entity small_pSquare_2SHARES is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           plaintext_s0 : in small_pSquare_state;
           plaintext_s1 : in small_pSquare_state;
           key_s0 : in small_pSquare_state;
           key_s1 : in small_pSquare_state;
           tweak : in small_pSquare_state;
           fresh_randomness : in small_pSquare_2SHARES_randomness;
           ciphertext_s0 : out small_pSquare_state;
           ciphertext_s1 : out small_pSquare_state;
           done : out STD_LOGIC);
end small_pSquare_2SHARES;

architecture Behavioral of small_pSquare_2SHARES is

    component SQ_2SHARE is
        Generic (bits : INTEGER := 7);
        Port ( clk : in STD_LOGIC;
               en : in STD_LOGIC;
               a0 : in UNSIGNED (bits-1 downto 0);
               a1 : in UNSIGNED (bits-1 downto 0);
               r0 : in UNSIGNED (bits-1 downto 0);
               r1 : in UNSIGNED (bits-1 downto 0);
               b0 : out UNSIGNED (bits-1 downto 0);
               b1 : out UNSIGNED (bits-1 downto 0));
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
    
    signal round_tweak1, round_tweak2, key_reg1_0, key_reg1_1, key_reg2_0, key_reg2_1, round_tweakey_input_1, art_output_0, art_output_1, round_reg_0, round_reg_1, round_reg2_0, round_reg2_1 : small_pSquare_state;
    signal art_ou_0, art_ou_1, round_tweakey, round_tweakey_input_0 : small_pSquare_state_p1;
    signal round_input_0, round_input_1, round_output_0, round_output_1 : small_pSquare_state_p2;
    signal art_o_0, art_o_1 : small_pSquare_state_p3;
    constant pi : STD_LOGIC_VECTOR(63 downto 0) := x"C90FDAA22168C234";
    signal rot_pi : STD_LOGIC_VECTOR(63 downto 0);
    signal round_constants1, round_constants2, round_constants2_reg , sq1_in, sq1_in_reg, sq1_out_0, sq2_out_0, sq3_out_0, mds1_out_0, mds2_out_0, mds3_out_0, mds4_out_0, sq4_out_0, sq5_out_0, sq6_out_0 : small_pSquare_double;
    signal sq1_out_1, sq2_out_1, sq3_out_1, mds1_out_1, mds2_out_1, mds3_out_1, mds4_out_1, sq4_out_1, sq5_out_1, sq6_out_1 : small_pSquare_double;
    signal mds1_out_reg_0, mds2_out_reg_0, mds3_out_reg_0, mds4_out_reg_0 : small_pSquare_double;
    signal mds1_out_reg_1, mds2_out_reg_1, mds3_out_reg_1, mds4_out_reg_1 : small_pSquare_double;
    signal sq1_in_r, f1_out_0, f2_out_0, f3_out_0, f4_out_0 : small_pSquare_double_p1;
    signal f1_out_1, f2_out_1, f3_out_1, f4_out_1 : small_pSquare_double_p1;
    signal sq1_in_rr : small_pSquare_double_p3;
    signal tweakey_active, reg_enable : STD_LOGIC;
    
begin

    -- Round-Tweak and Key Addition
    TWK: for i in 0 to 15 generate
        round_tweakey(i) <= ('0' & round_tweak1(i)) + ('0' & key_reg1_0(i));
    end generate;

    -- Round-Input and Round-Tweakey Addition
    ARK: for i in 0 to 15 generate
        art_o_0(i) <= ('0' & round_input_0(i)) + ("00" & round_tweakey_input_0(i));
        art_o_1(i) <= ('0' & round_input_1(i)) + ("000" & round_tweakey_input_1(i));
        art_ou_0(i) <= ('0' & art_o_0(i)(6 downto 0)) + ("00000" & art_o_0(i)(9 downto 7));
        art_ou_1(i) <= ('0' & art_o_1(i)(6 downto 0)) + ("00000" & art_o_1(i)(9 downto 7));
        art_output_0(i) <= art_ou_0(i)(6 downto 0) + ("000000" & art_ou_0(i)(7));
        art_output_1(i) <= art_ou_1(i)(6 downto 0) + ("000000" & art_ou_1(i)(7));
        -- First Round-Constant Addition
        RC1_1: if i = 3 generate
            sq1_in_rr(0) <= ('0' & round_input_0(i)) + ("00" & round_tweakey_input_0(i)) + ("000" & round_constants1(0));
            sq1_in_r(0) <= ('0' & sq1_in_rr(0)(6 downto 0)) + ("00000" & sq1_in_rr(0)(9 downto 7));
            sq1_in(0) <= sq1_in_r(0)(6 downto 0) + ("000000" & sq1_in_r(0)(7));
        end generate;
        RC1_2: if i = 11 generate
            sq1_in_rr(1) <= ('0' & round_input_0(i)) + ("00" & round_tweakey_input_0(i)) + ("000" & round_constants1(1));
            sq1_in_r(1) <= ('0' & sq1_in_rr(1)(6 downto 0)) + ("00000" & sq1_in_rr(1)(9 downto 7));
            sq1_in(1) <= sq1_in_r(1)(6 downto 0) + ("000000" & sq1_in_r(1)(7));
        end generate;
    end generate;

    -- Round-Constant Partitioning
    round_constants1 <= (UNSIGNED(rot_pi(6 downto 0)), UNSIGNED(rot_pi(38 downto 32)));
    round_constants2 <= (UNSIGNED(rot_pi(54 downto 48)), UNSIGNED(rot_pi(22 downto 16)));
    
    -- F-Functions
    F_Functions: for i in 0 to 1 generate
        FFC_1 : FF Generic Map (7) Port Map (clk, reg_enable, round_constants2(i), round_constants2_reg(i));
        FFC_2: FF Generic Map (7) Port Map (clk, reg_enable, sq1_in(i), sq1_in_reg(i));
        
        -- First Non-Linear Layer
        SQ1: SQ_2SHARE Generic Map (7) Port Map (clk, reg_enable, sq1_in(i), art_output_1(3+i*8), fresh_randomness(0+i*6), fresh_randomness(1+i*6), sq1_out_0(i), sq1_out_1(i));
        SQ2: SQ_2SHARE Generic Map (7) Port Map (clk, reg_enable, art_output_0(2+i*8), art_output_1(2+i*8), fresh_randomness(2+i*6), fresh_randomness(3+i*6), sq2_out_0(i), sq2_out_1(i));
        SQ3: SQ_2SHARE Generic Map (7) Port Map (clk, reg_enable, art_output_0(1+i*8), art_output_1(1+i*8), fresh_randomness(4+i*6), fresh_randomness(5+i*6), sq3_out_0(i), sq3_out_1(i));
        
        -- MDS Matrix Multiplication and Second Round-Constant Addition
        MM_0: MatrixMult_RC Generic Map (7) Port Map (sq1_in_reg(i), round_reg_0(2+i*8), round_reg_0(1+i*8), round_reg_0(0+i*8), sq1_out_0(i), sq2_out_0(i), sq3_out_0(i), round_constants2_reg(i), mds1_out_0(i), mds2_out_0(i), mds3_out_0(i), mds4_out_0(i));
        MM_1: MatrixMult Generic Map (7) Port Map (round_reg_1(3+i*8), round_reg_1(2+i*8), round_reg_1(1+i*8), round_reg_1(0+i*8), sq1_out_1(i), sq2_out_1(i), sq3_out_1(i), mds1_out_1(i), mds2_out_1(i), mds3_out_1(i), mds4_out_1(i));

        -- Second Non-Linear Layer
        SQ4: SQ_2SHARE Generic Map (7) Port Map (clk, reg_enable, mds1_out_0(i), mds1_out_1(i), fresh_randomness(12+i*6), fresh_randomness(13+i*6), sq4_out_0(i), sq4_out_1(i));
        SQ5: SQ_2SHARE Generic Map (7) Port Map (clk, reg_enable, mds2_out_0(i), mds2_out_1(i), fresh_randomness(14+i*6), fresh_randomness(15+i*6), sq5_out_0(i), sq5_out_1(i));
        SQ6: SQ_2SHARE Generic Map (7) Port Map (clk, reg_enable, mds3_out_0(i), mds3_out_1(i), fresh_randomness(16+i*6), fresh_randomness(17+i*6), sq6_out_0(i), sq6_out_1(i));
        FF1_0: FF Generic Map (7) Port Map (clk, reg_enable, mds1_out_0(i), mds1_out_reg_0(i));
        FF1_1: FF Generic Map (7) Port Map (clk, reg_enable, mds1_out_1(i), mds1_out_reg_1(i));
        FF2_0: FF Generic Map (7) Port Map (clk, reg_enable, mds2_out_0(i), mds2_out_reg_0(i));
        FF2_1: FF Generic Map (7) Port Map (clk, reg_enable, mds2_out_1(i), mds2_out_reg_1(i));
        FF3_0: FF Generic Map (7) Port Map (clk, reg_enable, mds3_out_0(i), mds3_out_reg_0(i));
        FF3_1: FF Generic Map (7) Port Map (clk, reg_enable, mds3_out_1(i), mds3_out_reg_1(i));
        FF4_0: FF Generic Map (7) Port Map (clk, reg_enable, mds4_out_0(i), mds4_out_reg_0(i));
        FF4_1: FF Generic Map (7) Port Map (clk, reg_enable, mds4_out_1(i), mds4_out_reg_1(i));
        f1_out_0(i) <= ('0' & mds2_out_reg_0(i)) + ('0' & sq4_out_0(i));
        f1_out_1(i) <= ('0' & mds2_out_reg_1(i)) + ('0' & sq4_out_1(i));
        f2_out_0(i) <= ('0' & mds3_out_reg_0(i)) + ('0' & sq5_out_0(i));
        f2_out_1(i) <= ('0' & mds3_out_reg_1(i)) + ('0' & sq5_out_1(i));
        f3_out_0(i) <= ('0' & mds4_out_reg_0(i)) + ('0' & sq6_out_0(i));
        f3_out_1(i) <= ('0' & mds4_out_reg_1(i)) + ('0' & sq6_out_1(i));
        f4_out_0(i) <= ('0' & mds1_out_reg_0(i));
        f4_out_1(i) <= ('0' & mds1_out_reg_1(i));
    end generate;

    -- F Function Result Additions and Position Swap
    F_Result_Addition: for i in 0 to 1 generate
        round_output_0(0+i*8) <= ("00" & round_reg2_0(4+i*8)) + ('0' & f4_out_0(i));
        round_output_1(0+i*8) <= ("00" & round_reg2_1(4+i*8)) + ('0' & f4_out_1(i));
        round_output_0(1+i*8) <= ("00" & round_reg2_0(5+i*8)) + ('0' & f3_out_0(i));
        round_output_1(1+i*8) <= ("00" & round_reg2_1(5+i*8)) + ('0' & f3_out_1(i));
        round_output_0(2+i*8) <= ("00" & round_reg2_0(6+i*8)) + ('0' & f2_out_0(i));
        round_output_1(2+i*8) <= ("00" & round_reg2_1(6+i*8)) + ('0' & f2_out_1(i));
        round_output_0(3+i*8) <= ("00" & round_reg2_0(7+i*8)) + ('0' & f1_out_0(i));
        round_output_1(3+i*8) <= ("00" & round_reg2_1(7+i*8)) + ('0' & f1_out_1(i));
    end generate;
    Swap: for i in 0 to 3 generate
        round_output_0(4+i) <= "00" & round_reg2_0(8+i);
        round_output_1(4+i) <= "00" & round_reg2_1(8+i);
        round_output_0(12+i) <= "00" & round_reg2_0(i);
        round_output_1(12+i) <= "00" & round_reg2_1(i);
    end generate;
    
    -- Round Tweakey Addition only active every N_r Rounds
    round_tweakey_input_0 <= round_tweakey when tweakey_active = '1' else (others => (others => '0'));
    round_tweakey_input_1 <= key_reg1_1 when tweakey_active = '1' else (others => (others => '0'));
    
    -- Round Input Mux
    RoundInput: for i in 0 to 15 generate
        round_input_0(i) <= ("00" & plaintext_s0(i)) when (rst = '1') else round_output_0(i);
        round_input_1(i) <= ("00" & plaintext_s1(i)) when (rst = '1') else round_output_1(i);
    end generate;
    
    -- State Machine
    FSM: process(clk)
        variable stepcounter : integer range 0 to 7;
        variable roundcounter : integer range 0 to 15;
        variable doneflag : integer range 0 to 1;
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                round_tweak1                    <= tweak;
                round_tweak2                    <= round_tweak1;
                key_reg1_0                      <= key_s0;
                key_reg1_1                      <= key_s1;
                key_reg2_0                      <= key_reg1_0;
                key_reg2_1                      <= key_reg1_1;
                round_reg_0                     <= art_output_0;
                round_reg_1                     <= art_output_1;
                round_reg2_0                    <= round_reg_0;
                round_reg2_1                    <= round_reg_1;
                rot_pi                          <= pi;
                stepcounter                     := 0;
                roundcounter                    := 0;
                doneflag                        := 0;
                done                            <= '0';
                tweakey_active                  <= '1';
                reg_enable                      <= '1';
            else
                if(doneflag = 0) then
                    round_reg_0                 <= art_output_0;
                    round_reg_1                 <= art_output_1;
                    round_reg2_0                <= round_reg_0;
                    round_reg2_1                <= round_reg_1;
                    reg_enable                  <= '1';
                    if (stepcounter < 6) then
                        stepcounter             := stepcounter + 1;
                        tweakey_active          <= '0';
                    elsif (stepcounter = 6) then
                        stepcounter             := stepcounter + 1;
                        key_reg1_0              <= key_reg2_0;
                        key_reg1_1              <= key_reg2_1;
                        key_reg2_0              <= key_reg1_0;
                        key_reg2_1              <= key_reg1_1;
                        round_tweak2            <= ((round_tweak1( 9)(5) & round_tweak1( 9)(0) & round_tweak1( 9)(3) & round_tweak1( 9)(1) & round_tweak1( 9)(6) & round_tweak1( 9)(4) & round_tweak1( 9)(2)), (round_tweak1( 5)(4) & round_tweak1( 5)(6) & round_tweak1( 5)(2) & round_tweak1( 5)(0) & round_tweak1( 5)(5) & round_tweak1( 5)(3) & round_tweak1( 5)(1)), (round_tweak1(13)(3) & round_tweak1(13)(5) & round_tweak1(13)(1) & round_tweak1(13)(6) & round_tweak1(13)(4) & round_tweak1(13)(2) & round_tweak1(13)(0)), (round_tweak1(15)(2) & round_tweak1(15)(4) & round_tweak1(15)(0) & round_tweak1(15)(5) & round_tweak1(15)(3) & round_tweak1(15)(1) & round_tweak1(15)(6)), (round_tweak1(12)(1) & round_tweak1(12)(3) & round_tweak1(12)(6) & round_tweak1(12)(4) & round_tweak1(12)(2) & round_tweak1(12)(0) & round_tweak1(12)(5)), (round_tweak1( 7)(0) & round_tweak1( 7)(2) & round_tweak1( 7)(5) & round_tweak1( 7)(3) & round_tweak1( 7)(1) & round_tweak1( 7)(6) & round_tweak1( 7)(4)), (round_tweak1(14)(6) & round_tweak1(14)(1) & round_tweak1(14)(4) & round_tweak1(14)(2) & round_tweak1(14)(0) & round_tweak1(14)(5) & round_tweak1(14)(3)), (round_tweak1( 2)(5) & round_tweak1( 2)(0) & round_tweak1( 2)(3) & round_tweak1( 2)(1) & round_tweak1( 2)(6) & round_tweak1( 2)(4) & round_tweak1( 2)(2)), (round_tweak1( 4)(4) & round_tweak1( 4)(6) & round_tweak1( 4)(2) & round_tweak1( 4)(0) & round_tweak1( 4)(5) & round_tweak1( 4)(3) & round_tweak1( 4)(1)), (round_tweak1( 6)(3) & round_tweak1( 6)(5) & round_tweak1( 6)(1) & round_tweak1( 6)(6) & round_tweak1( 6)(4) & round_tweak1( 6)(2) & round_tweak1( 6)(0)), (round_tweak1( 8)(2) & round_tweak1( 8)(4) & round_tweak1( 8)(0) & round_tweak1( 8)(5) & round_tweak1( 8)(3) & round_tweak1( 8)(1) & round_tweak1( 8)(6)), (round_tweak1( 3)(1) & round_tweak1( 3)(3) & round_tweak1( 3)(6) & round_tweak1( 3)(4) & round_tweak1( 3)(2) & round_tweak1( 3)(0) & round_tweak1( 3)(5)), (round_tweak1(10)(0) & round_tweak1(10)(2) & round_tweak1(10)(5) & round_tweak1(10)(3) & round_tweak1(10)(1) & round_tweak1(10)(6) & round_tweak1(10)(4)), (round_tweak1( 1)(6) & round_tweak1( 1)(1) & round_tweak1( 1)(4) & round_tweak1( 1)(2) & round_tweak1( 1)(0) & round_tweak1( 1)(5) & round_tweak1( 1)(3)), (round_tweak1(11)(5) & round_tweak1(11)(0) & round_tweak1(11)(3) & round_tweak1(11)(1) & round_tweak1(11)(6) & round_tweak1(11)(4) & round_tweak1(11)(2)), (round_tweak1( 0)(4) & round_tweak1( 0)(6) & round_tweak1( 0)(2) & round_tweak1( 0)(0) & round_tweak1( 0)(5) & round_tweak1( 0)(3) & round_tweak1( 0)(1)));
                        round_tweak1            <= ((round_tweak2( 9)(5) & round_tweak2( 9)(0) & round_tweak2( 9)(3) & round_tweak2( 9)(1) & round_tweak2( 9)(6) & round_tweak2( 9)(4) & round_tweak2( 9)(2)), (round_tweak2( 5)(4) & round_tweak2( 5)(6) & round_tweak2( 5)(2) & round_tweak2( 5)(0) & round_tweak2( 5)(5) & round_tweak2( 5)(3) & round_tweak2( 5)(1)), (round_tweak2(13)(3) & round_tweak2(13)(5) & round_tweak2(13)(1) & round_tweak2(13)(6) & round_tweak2(13)(4) & round_tweak2(13)(2) & round_tweak2(13)(0)), (round_tweak2(15)(2) & round_tweak2(15)(4) & round_tweak2(15)(0) & round_tweak2(15)(5) & round_tweak2(15)(3) & round_tweak2(15)(1) & round_tweak2(15)(6)), (round_tweak2(12)(1) & round_tweak2(12)(3) & round_tweak2(12)(6) & round_tweak2(12)(4) & round_tweak2(12)(2) & round_tweak2(12)(0) & round_tweak2(12)(5)), (round_tweak2( 7)(0) & round_tweak2( 7)(2) & round_tweak2( 7)(5) & round_tweak2( 7)(3) & round_tweak2( 7)(1) & round_tweak2( 7)(6) & round_tweak2( 7)(4)), (round_tweak2(14)(6) & round_tweak2(14)(1) & round_tweak2(14)(4) & round_tweak2(14)(2) & round_tweak2(14)(0) & round_tweak2(14)(5) & round_tweak2(14)(3)), (round_tweak2( 2)(5) & round_tweak2( 2)(0) & round_tweak2( 2)(3) & round_tweak2( 2)(1) & round_tweak2( 2)(6) & round_tweak2( 2)(4) & round_tweak2( 2)(2)), (round_tweak2( 4)(4) & round_tweak2( 4)(6) & round_tweak2( 4)(2) & round_tweak2( 4)(0) & round_tweak2( 4)(5) & round_tweak2( 4)(3) & round_tweak2( 4)(1)), (round_tweak2( 6)(3) & round_tweak2( 6)(5) & round_tweak2( 6)(1) & round_tweak2( 6)(6) & round_tweak2( 6)(4) & round_tweak2( 6)(2) & round_tweak2( 6)(0)), (round_tweak2( 8)(2) & round_tweak2( 8)(4) & round_tweak2( 8)(0) & round_tweak2( 8)(5) & round_tweak2( 8)(3) & round_tweak2( 8)(1) & round_tweak2( 8)(6)), (round_tweak2( 3)(1) & round_tweak2( 3)(3) & round_tweak2( 3)(6) & round_tweak2( 3)(4) & round_tweak2( 3)(2) & round_tweak2( 3)(0) & round_tweak2( 3)(5)), (round_tweak2(10)(0) & round_tweak2(10)(2) & round_tweak2(10)(5) & round_tweak2(10)(3) & round_tweak2(10)(1) & round_tweak2(10)(6) & round_tweak2(10)(4)), (round_tweak2( 1)(6) & round_tweak2( 1)(1) & round_tweak2( 1)(4) & round_tweak2( 1)(2) & round_tweak2( 1)(0) & round_tweak2( 1)(5) & round_tweak2( 1)(3)), (round_tweak2(11)(5) & round_tweak2(11)(0) & round_tweak2(11)(3) & round_tweak2(11)(1) & round_tweak2(11)(6) & round_tweak2(11)(4) & round_tweak2(11)(2)), (round_tweak2( 0)(4) & round_tweak2( 0)(6) & round_tweak2( 0)(2) & round_tweak2( 0)(0) & round_tweak2( 0)(5) & round_tweak2( 0)(3) & round_tweak2( 0)(1)));
                        tweakey_active          <= '1';
                    else
                        key_reg1_0              <= key_reg2_0;
                        key_reg1_1              <= key_reg2_1;
                        key_reg2_0              <= key_reg1_0;
                        key_reg2_1              <= key_reg1_1;
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
                    if ((stepcounter mod 2) = 1) then
                        rot_pi                  <= rot_pi(62 downto 0) & rot_pi(63);
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    ciphertext_s0 <= art_output_0;
    ciphertext_s1 <= art_output_1;
    
end Behavioral;