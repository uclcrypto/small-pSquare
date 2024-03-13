library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.small_pSquare_data_types.ALL;

entity small_pSquare is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           plaintext : in small_pSquare_state;
           key : in small_pSquare_state;
           tweak : in small_pSquare_state;
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
    
    signal round_tweak, art_output, round_reg, round_reg2 : small_pSquare_state;
    signal art_ou, round_tweakey, round_tweakey_input : small_pSquare_state_p1;
    signal round_input, round_output : small_pSquare_state_p2;
    signal art_o : small_pSquare_state_p3;
    constant pi : STD_LOGIC_VECTOR(63 downto 0) := x"C90FDAA22168C234";
    signal rot_pi : STD_LOGIC_VECTOR(63 downto 0);
    signal round_constants1, round_constants2, round_constants2_reg, sq1_in, sq1_in_reg, sq1_out, sq2_out, sq3_out, mds1_out, mds2_out, mds3_out, mds4_out, mds1_out_reg, mds2_out_reg, mds3_out_reg, mds4_out_reg, sq4_out, sq5_out, sq6_out : small_pSquare_double;
    signal sq1_in_r, f1_out, f2_out, f3_out, f4_out : small_pSquare_double_p1;
    signal sq1_in_rr : small_pSquare_double_p3;
    
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
        SQ1: SquModMersenne Generic Map (7) Port Map (sq1_in_reg(i), sq1_out(i));
        SQ2: SquModMersenne Generic Map (7) Port Map (round_reg(2+i*8), sq2_out(i));
        SQ3: SquModMersenne Generic Map (7) Port Map (round_reg(1+i*8), sq3_out(i));
        
        -- MDS Matrix Multiplication and Second Round-Constant Addition        
        MM_0: MatrixMult_RC Generic Map (7) Port Map (sq1_in_reg(i), round_reg(2+i*8), round_reg(1+i*8), round_reg(0+i*8), sq1_out(i), sq2_out(i), sq3_out(i), round_constants2_reg(i), mds1_out(i), mds2_out(i), mds3_out(i), mds4_out(i));

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
        round_output(0+i*8) <= ("00" & round_reg2(4+i*8)) + ('0' & f4_out(i));
        round_output(1+i*8) <= ("00" & round_reg2(5+i*8)) + ('0' & f3_out(i));
        round_output(2+i*8) <= ("00" & round_reg2(6+i*8)) + ('0' & f2_out(i));
        round_output(3+i*8) <= ("00" & round_reg2(7+i*8)) + ('0' & f1_out(i));
    end generate;
    Swap: for i in 0 to 3 generate
        round_output(4+i) <= "00" & round_reg2(8+i);
        round_output(12+i) <= "00" & round_reg2(i);
    end generate;
    
    -- Round Input Mux
    RoundInput: for i in 0 to 15 generate
        round_input(i) <= ("00" & plaintext(i)) when (rst = '1') else round_output(i);
    end generate;
    
    -- State Machine
    FSM: process(clk)
        variable stepcounter : integer range 0 to 7;
        variable roundcounter : integer range 0 to 15;
        variable cyclecounter : integer range 0 to 1;
        variable doneflag : integer range 0 to 1;
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                round_tweak                     <= tweak;
                round_tweakey_input             <= round_tweakey;
                round_reg                       <= art_output;
                round_reg2                      <= round_reg;
                rot_pi                          <= pi;
                stepcounter                     := 0;
                roundcounter                    := 0;
                cyclecounter                    := 0;
                doneflag                        := 0;
                done                            <= '0';
                mds1_out_reg                    <= mds1_out;
                mds2_out_reg                    <= mds2_out;
                mds3_out_reg                    <= mds3_out;
                mds4_out_reg                    <= mds4_out;
                sq1_in_reg                      <= sq1_in;
                round_constants2_reg            <= round_constants2;
            else
                if(doneflag = 0) then
                    round_reg                   <= art_output;
                    round_reg2                  <= round_reg;
                    mds1_out_reg                <= mds1_out;
                    mds2_out_reg                <= mds2_out;
                    mds3_out_reg                <= mds3_out;
                    mds4_out_reg                <= mds4_out;
                    sq1_in_reg                  <= sq1_in;
                    round_constants2_reg        <= round_constants2;
                    if (stepcounter < 5) then
                        stepcounter             := stepcounter + 1;
                        round_tweakey_input     <= (others => (others => '0'));
                    elsif (stepcounter = 5) then
                        stepcounter             := stepcounter + 1;
                        round_tweak             <= ((round_tweak( 9)(5) & round_tweak( 9)(0) & round_tweak( 9)(3) & round_tweak( 9)(1) & round_tweak( 9)(6) & round_tweak( 9)(4) & round_tweak( 9)(2)), (round_tweak( 5)(4) & round_tweak( 5)(6) & round_tweak( 5)(2) & round_tweak( 5)(0) & round_tweak( 5)(5) & round_tweak( 5)(3) & round_tweak( 5)(1)), (round_tweak(13)(3) & round_tweak(13)(5) & round_tweak(13)(1) & round_tweak(13)(6) & round_tweak(13)(4) & round_tweak(13)(2) & round_tweak(13)(0)), (round_tweak(15)(2) & round_tweak(15)(4) & round_tweak(15)(0) & round_tweak(15)(5) & round_tweak(15)(3) & round_tweak(15)(1) & round_tweak(15)(6)), (round_tweak(12)(1) & round_tweak(12)(3) & round_tweak(12)(6) & round_tweak(12)(4) & round_tweak(12)(2) & round_tweak(12)(0) & round_tweak(12)(5)), (round_tweak( 7)(0) & round_tweak( 7)(2) & round_tweak( 7)(5) & round_tweak( 7)(3) & round_tweak( 7)(1) & round_tweak( 7)(6) & round_tweak( 7)(4)), (round_tweak(14)(6) & round_tweak(14)(1) & round_tweak(14)(4) & round_tweak(14)(2) & round_tweak(14)(0) & round_tweak(14)(5) & round_tweak(14)(3)), (round_tweak( 2)(5) & round_tweak( 2)(0) & round_tweak( 2)(3) & round_tweak( 2)(1) & round_tweak( 2)(6) & round_tweak( 2)(4) & round_tweak( 2)(2)), (round_tweak( 4)(4) & round_tweak( 4)(6) & round_tweak( 4)(2) & round_tweak( 4)(0) & round_tweak( 4)(5) & round_tweak( 4)(3) & round_tweak( 4)(1)), (round_tweak( 6)(3) & round_tweak( 6)(5) & round_tweak( 6)(1) & round_tweak( 6)(6) & round_tweak( 6)(4) & round_tweak( 6)(2) & round_tweak( 6)(0)), (round_tweak( 8)(2) & round_tweak( 8)(4) & round_tweak( 8)(0) & round_tweak( 8)(5) & round_tweak( 8)(3) & round_tweak( 8)(1) & round_tweak( 8)(6)), (round_tweak( 3)(1) & round_tweak( 3)(3) & round_tweak( 3)(6) & round_tweak( 3)(4) & round_tweak( 3)(2) & round_tweak( 3)(0) & round_tweak( 3)(5)), (round_tweak(10)(0) & round_tweak(10)(2) & round_tweak(10)(5) & round_tweak(10)(3) & round_tweak(10)(1) & round_tweak(10)(6) & round_tweak(10)(4)), (round_tweak( 1)(6) & round_tweak( 1)(1) & round_tweak( 1)(4) & round_tweak( 1)(2) & round_tweak( 1)(0) & round_tweak( 1)(5) & round_tweak( 1)(3)), (round_tweak(11)(5) & round_tweak(11)(0) & round_tweak(11)(3) & round_tweak(11)(1) & round_tweak(11)(6) & round_tweak(11)(4) & round_tweak(11)(2)), (round_tweak( 0)(4) & round_tweak( 0)(6) & round_tweak( 0)(2) & round_tweak( 0)(0) & round_tweak( 0)(5) & round_tweak( 0)(3) & round_tweak( 0)(1)));
                    elsif (stepcounter = 6) then
                        stepcounter             := stepcounter + 1;
                        round_tweakey_input     <= round_tweakey;
                    else
                        if (roundcounter = 15) then
                            doneflag            := 1;
                            done                <= '1';
                        else
                            stepcounter         := 0;
                            roundcounter        := roundcounter + 1;
                        end if;
                    end if;
                    if (cyclecounter = 0) then
                        cyclecounter            := 1;
                        rot_pi                  <= rot_pi(62 downto 0) & rot_pi(63);
                    else
                        cyclecounter            := 0;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    ciphertext <= art_output;
    
end Behavioral;