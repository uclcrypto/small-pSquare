library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.small_pSquare_data_types.ALL;

entity small_pSquare is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           plaintext : in small_pSquare_state;
           key : in small_pSquare_state;
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
    
    signal art_output, round_tweakey_input, round_reg : small_pSquare_state;
    signal art_ou, sq1_in_r : small_pSquare_state_p1;
    signal round_input, round_output : small_pSquare_state_p2;
    signal art_o, sq1_in_rr : small_pSquare_state_p3;
    constant pi : STD_LOGIC_VECTOR(63 downto 0) := x"C90FDAA22168C234";
    signal rot_pi : STD_LOGIC_VECTOR(63 downto 0);
    signal round_constants1, round_constants2, sq1_in, sq1_out, sq2_out, sq3_out, mds1_out, mds2_out, mds3_out, mds4_out, mds1_out_reg, mds2_out_reg, mds3_out_reg, mds4_out_reg, sq4_out, sq5_out, sq6_out : small_pSquare_double;
    signal f1_out, f2_out, f3_out, f4_out : small_pSquare_double_p1;
    signal tweakey_active : STD_LOGIC;
    
begin

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
    round_tweakey_input <= key when tweakey_active = '1' else (others => (others => '0'));
    
    -- Round Input Mux
    RoundInput: for i in 0 to 15 generate
        round_input(i) <= ("00" & plaintext(i)) when (rst = '1') else round_output(i);
    end generate;
    
    -- State Machine
    FSM: process(clk)
        variable stepcounter : integer range 0 to 3;
        variable roundcounter : integer range 0 to 8;
        variable doneflag : integer range 0 to 1;
    begin
        if rising_edge(clk) then
            if (rst = '1') then
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
                        tweakey_active          <= '1';
                        if (roundcounter = 8) then
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