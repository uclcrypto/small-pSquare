library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.small_pSquare_data_types.ALL;

entity small_pSquare is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           plaintext : in small_pSquare_state;
           key : in small_pSquare_state;
           tweak0 : in small_pSquare_state;
           tweak1 : in small_pSquare_state;
           ciphertext : out small_pSquare_state;
           done : out STD_LOGIC);
end small_pSquare;

architecture Behavioral of small_pSquare is

    component SquModMersenne is
        Generic ( bits : INTEGER := 7);
        Port ( a : in UNSIGNED (bits-1 downto 0);
               b : out UNSIGNED (bits-1 downto 0));
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
    
    signal round_tweak0, round_tweak1, round_tweak, art_output, round_reg : small_pSquare_state;
    signal art_ou, round_tweakey, round_tweakey_input, sq1_in_r : small_pSquare_state_p1;
    signal round_input, round_output : small_pSquare_state_p2;
    signal art_o, sq1_in_rr : small_pSquare_state_p3;
    constant pi : STD_LOGIC_VECTOR(63 downto 0) := x"C90FDAA22168C234";
    signal rot_pi : STD_LOGIC_VECTOR(63 downto 0);
    signal round_constants1, round_constants2, sq1_in, sq1_out, sq2_out, sq3_out, mds1_out, mds2_out, mds3_out, mds4_out, mds1_out_reg, mds2_out_reg, mds3_out_reg, mds4_out_reg, sq4_out, sq5_out, sq6_out : small_pSquare_double;
    signal f1_out, f2_out, f3_out, f4_out : small_pSquare_double_p1;
    signal tweak_select, tweakey_active : STD_LOGIC;
    
begin

    -- Round-Tweak and Key Addition
    TWK: for i in 0 to 15 generate
        round_tweakey(i) <= ('0' & round_tweak(i)) + ('0' & key(i));
    end generate;

    -- Round-Input and Round-Tweakey Addition
    ARK: for i in 0 to 15 generate
        art_o(i) <= ('0' & round_input(i)) + ("00" & round_tweakey_input(i));
        art_ou(i) <= ('0' & art_o(i)(6 downto 0)) + ("00000" & art_o(i)(9 downto 7));
        art_output(i) <= art_ou(i)(6 downto 0) + ("000000" & art_ou(i)(7));
        -- First Round-Constant Addition
        RC1_1: if i = 3 generate
            sq1_in_rr(0) <= ('0' & round_input(i)) + ("00" & round_tweakey_input(i)) + ("000" & round_constants1(0));
            sq1_in_r(0) <= ('0' & sq1_in_rr(0)(6 downto 0)) + ("00000" & sq1_in_rr(0)(9 downto 7));
            sq1_in(0) <= sq1_in_r(0)(6 downto 0) + ("000000" & sq1_in_r(0)(7));
        end generate;
        RC1_2: if i = 11 generate
            sq1_in_rr(1) <= ('0' & round_input(i)) + ("00" & round_tweakey_input(i)) + ("000" & round_constants1(1));
            sq1_in_r(1) <= ('0' & sq1_in_rr(1)(6 downto 0)) + ("00000" & sq1_in_rr(1)(9 downto 7));
            sq1_in(1) <= sq1_in_r(1)(6 downto 0) + ("000000" & sq1_in_r(1)(7));
        end generate;
    end generate;

    -- Round-Constant Partitioning
    round_constants1 <= (UNSIGNED(rot_pi(6 downto 0)), UNSIGNED(rot_pi(38 downto 32)));
    round_constants2 <= (UNSIGNED(rot_pi(54 downto 48)), UNSIGNED(rot_pi(22 downto 16)));
    
    -- F-Functions
    F_Functions: for i in 0 to 1 generate        
        -- First Non-Linear Layer
        SQ1: SquModMersenne Generic Map (7) Port Map (sq1_in(i), sq1_out(i));
        SQ2: SquModMersenne Generic Map (7) Port Map (art_output(2+i*8), sq2_out(i));
        SQ3: SquModMersenne Generic Map (7) Port Map (art_output(1+i*8), sq3_out(i));
        
        -- MDS Matrix Multiplication and Second Round-Constant Addition        
        MM_0: MatrixMult_RC Generic Map (7) Port Map (sq1_in(i), art_output(2+i*8), art_output(1+i*8), art_output(0+i*8), sq1_out(i), sq2_out(i), sq3_out(i), round_constants2(i), mds1_out(i), mds2_out(i), mds3_out(i), mds4_out(i));

        -- Second Non-Linear Layer
        SQ4: SquModMersenne Generic Map (7) Port Map (mds1_out_reg(i), sq4_out(i));
        SQ5: SquModMersenne Generic Map (7) Port Map (mds2_out_reg(i), sq5_out(i));
        SQ6: SquModMersenne Generic Map (7) Port Map (mds3_out_reg(i), sq6_out(i));
        f1_out(i) <= ('0' & mds2_out_reg(i)) + ('0' & sq4_out(i));
        f2_out(i) <= ('0' & mds3_out_reg(i)) + ('0' & sq5_out(i));
        f3_out(i) <= ('0' & mds4_out_reg(i)) + ('0' & sq6_out(i));
        f4_out(i) <= ('0' & mds1_out_reg(i));
    end generate;

    -- F Function Result Additions and Position Swap
    F_Result_Addition: for i in 0 to 1 generate
        round_output(0+i*8) <= ("00" & round_reg(4+i*8)) + ('0' & f4_out(i));
        round_output(1+i*8) <= ("00" & round_reg(5+i*8)) + ('0' & f3_out(i));
        round_output(2+i*8) <= ("00" & round_reg(6+i*8)) + ('0' & f2_out(i));
        round_output(3+i*8) <= ("00" & round_reg(7+i*8)) + ('0' & f1_out(i));
    end generate;
    Swap: for i in 0 to 3 generate
        round_output(4+i) <= "00" & round_reg(8+i);
        round_output(12+i) <= "00" & round_reg(i);
    end generate;
    
    -- Round Tweakey Addition only active every N_r Rounds
    round_tweakey_input <= round_tweakey when tweakey_active = '1' else (others => (others => '0'));
    round_tweak <= round_tweak0 when tweak_select = '0' else round_tweak1;
    
    -- Round Input Mux
    RoundInput: for i in 0 to 15 generate
        round_input(i) <= ("00" & plaintext(i)) when (rst = '1') else round_output(i);
    end generate;
    
    -- State Machine
    FSM: process(clk)
        variable stepcounter : integer range 0 to 3;
        variable roundcounter : integer range 0 to 20;
        variable doneflag : integer range 0 to 1;
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                round_tweak0                    <= tweak0;
                round_tweak1                    <= tweak1;
                round_reg                       <= art_output;
                rot_pi                          <= pi;
                stepcounter                     := 0;
                roundcounter                    := 0;
                doneflag                        := 0;
                done                            <= '0';
                tweakey_active                  <= '1';
                mds1_out_reg                    <= mds1_out;
                mds2_out_reg                    <= mds2_out;
                mds3_out_reg                    <= mds3_out;
                mds4_out_reg                    <= mds4_out;
                tweak_select                    <= '0';
            else
                if(doneflag = 0) then
                    round_reg                   <= art_output;
                    mds1_out_reg                <= mds1_out;
                    mds2_out_reg                <= mds2_out;
                    mds3_out_reg                <= mds3_out;
                    mds4_out_reg                <= mds4_out;
                    rot_pi                      <= rot_pi(62 downto 0) & rot_pi(63);
                    if (stepcounter < 3) then
                        stepcounter             := stepcounter + 1;
                        tweakey_active          <= '0';
                    else
                        if((roundcounter mod 2) = 0) then
                            round_tweak0        <= ((round_tweak0( 9)(5) & round_tweak0( 9)(0) & round_tweak0( 9)(3) & round_tweak0( 9)(1) & round_tweak0( 9)(6) & round_tweak0( 9)(4) & round_tweak0( 9)(2)), (round_tweak0( 5)(4) & round_tweak0( 5)(6) & round_tweak0( 5)(2) & round_tweak0( 5)(0) & round_tweak0( 5)(5) & round_tweak0( 5)(3) & round_tweak0( 5)(1)), (round_tweak0(13)(3) & round_tweak0(13)(5) & round_tweak0(13)(1) & round_tweak0(13)(6) & round_tweak0(13)(4) & round_tweak0(13)(2) & round_tweak0(13)(0)), (round_tweak0(15)(2) & round_tweak0(15)(4) & round_tweak0(15)(0) & round_tweak0(15)(5) & round_tweak0(15)(3) & round_tweak0(15)(1) & round_tweak0(15)(6)), (round_tweak0(12)(1) & round_tweak0(12)(3) & round_tweak0(12)(6) & round_tweak0(12)(4) & round_tweak0(12)(2) & round_tweak0(12)(0) & round_tweak0(12)(5)), (round_tweak0( 7)(0) & round_tweak0( 7)(2) & round_tweak0( 7)(5) & round_tweak0( 7)(3) & round_tweak0( 7)(1) & round_tweak0( 7)(6) & round_tweak0( 7)(4)), (round_tweak0(14)(6) & round_tweak0(14)(1) & round_tweak0(14)(4) & round_tweak0(14)(2) & round_tweak0(14)(0) & round_tweak0(14)(5) & round_tweak0(14)(3)), (round_tweak0( 2)(5) & round_tweak0( 2)(0) & round_tweak0( 2)(3) & round_tweak0( 2)(1) & round_tweak0( 2)(6) & round_tweak0( 2)(4) & round_tweak0( 2)(2)), (round_tweak0( 4)(4) & round_tweak0( 4)(6) & round_tweak0( 4)(2) & round_tweak0( 4)(0) & round_tweak0( 4)(5) & round_tweak0( 4)(3) & round_tweak0( 4)(1)), (round_tweak0( 6)(3) & round_tweak0( 6)(5) & round_tweak0( 6)(1) & round_tweak0( 6)(6) & round_tweak0( 6)(4) & round_tweak0( 6)(2) & round_tweak0( 6)(0)), (round_tweak0( 8)(2) & round_tweak0( 8)(4) & round_tweak0( 8)(0) & round_tweak0( 8)(5) & round_tweak0( 8)(3) & round_tweak0( 8)(1) & round_tweak0( 8)(6)), (round_tweak0( 3)(1) & round_tweak0( 3)(3) & round_tweak0( 3)(6) & round_tweak0( 3)(4) & round_tweak0( 3)(2) & round_tweak0( 3)(0) & round_tweak0( 3)(5)), (round_tweak0(10)(0) & round_tweak0(10)(2) & round_tweak0(10)(5) & round_tweak0(10)(3) & round_tweak0(10)(1) & round_tweak0(10)(6) & round_tweak0(10)(4)), (round_tweak0( 1)(6) & round_tweak0( 1)(1) & round_tweak0( 1)(4) & round_tweak0( 1)(2) & round_tweak0( 1)(0) & round_tweak0( 1)(5) & round_tweak0( 1)(3)), (round_tweak0(11)(5) & round_tweak0(11)(0) & round_tweak0(11)(3) & round_tweak0(11)(1) & round_tweak0(11)(6) & round_tweak0(11)(4) & round_tweak0(11)(2)), (round_tweak0( 0)(4) & round_tweak0( 0)(6) & round_tweak0( 0)(2) & round_tweak0( 0)(0) & round_tweak0( 0)(5) & round_tweak0( 0)(3) & round_tweak0( 0)(1)));
                            tweak_select        <= '1';
                        else
                            round_tweak1        <= ((round_tweak1( 9)(5) & round_tweak1( 9)(0) & round_tweak1( 9)(3) & round_tweak1( 9)(1) & round_tweak1( 9)(6) & round_tweak1( 9)(4) & round_tweak1( 9)(2)), (round_tweak1( 5)(4) & round_tweak1( 5)(6) & round_tweak1( 5)(2) & round_tweak1( 5)(0) & round_tweak1( 5)(5) & round_tweak1( 5)(3) & round_tweak1( 5)(1)), (round_tweak1(13)(3) & round_tweak1(13)(5) & round_tweak1(13)(1) & round_tweak1(13)(6) & round_tweak1(13)(4) & round_tweak1(13)(2) & round_tweak1(13)(0)), (round_tweak1(15)(2) & round_tweak1(15)(4) & round_tweak1(15)(0) & round_tweak1(15)(5) & round_tweak1(15)(3) & round_tweak1(15)(1) & round_tweak1(15)(6)), (round_tweak1(12)(1) & round_tweak1(12)(3) & round_tweak1(12)(6) & round_tweak1(12)(4) & round_tweak1(12)(2) & round_tweak1(12)(0) & round_tweak1(12)(5)), (round_tweak1( 7)(0) & round_tweak1( 7)(2) & round_tweak1( 7)(5) & round_tweak1( 7)(3) & round_tweak1( 7)(1) & round_tweak1( 7)(6) & round_tweak1( 7)(4)), (round_tweak1(14)(6) & round_tweak1(14)(1) & round_tweak1(14)(4) & round_tweak1(14)(2) & round_tweak1(14)(0) & round_tweak1(14)(5) & round_tweak1(14)(3)), (round_tweak1( 2)(5) & round_tweak1( 2)(0) & round_tweak1( 2)(3) & round_tweak1( 2)(1) & round_tweak1( 2)(6) & round_tweak1( 2)(4) & round_tweak1( 2)(2)), (round_tweak1( 4)(4) & round_tweak1( 4)(6) & round_tweak1( 4)(2) & round_tweak1( 4)(0) & round_tweak1( 4)(5) & round_tweak1( 4)(3) & round_tweak1( 4)(1)), (round_tweak1( 6)(3) & round_tweak1( 6)(5) & round_tweak1( 6)(1) & round_tweak1( 6)(6) & round_tweak1( 6)(4) & round_tweak1( 6)(2) & round_tweak1( 6)(0)), (round_tweak1( 8)(2) & round_tweak1( 8)(4) & round_tweak1( 8)(0) & round_tweak1( 8)(5) & round_tweak1( 8)(3) & round_tweak1( 8)(1) & round_tweak1( 8)(6)), (round_tweak1( 3)(1) & round_tweak1( 3)(3) & round_tweak1( 3)(6) & round_tweak1( 3)(4) & round_tweak1( 3)(2) & round_tweak1( 3)(0) & round_tweak1( 3)(5)), (round_tweak1(10)(0) & round_tweak1(10)(2) & round_tweak1(10)(5) & round_tweak1(10)(3) & round_tweak1(10)(1) & round_tweak1(10)(6) & round_tweak1(10)(4)), (round_tweak1( 1)(6) & round_tweak1( 1)(1) & round_tweak1( 1)(4) & round_tweak1( 1)(2) & round_tweak1( 1)(0) & round_tweak1( 1)(5) & round_tweak1( 1)(3)), (round_tweak1(11)(5) & round_tweak1(11)(0) & round_tweak1(11)(3) & round_tweak1(11)(1) & round_tweak1(11)(6) & round_tweak1(11)(4) & round_tweak1(11)(2)), (round_tweak1( 0)(4) & round_tweak1( 0)(6) & round_tweak1( 0)(2) & round_tweak1( 0)(0) & round_tweak1( 0)(5) & round_tweak1( 0)(3) & round_tweak1( 0)(1)));
                            tweak_select        <= '0';
                        end if;
                        tweakey_active          <= '1';
                        if (roundcounter = 20) then
                            doneflag            := 1;
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
    
    ciphertext <= art_output;
    
end Behavioral;