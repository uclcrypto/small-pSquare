-- Reference implementation. Very inefficient!
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.small_pSquare_data_types.ALL;

entity small_pSquare is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           dec : in STD_LOGIC;
           data_input : in small_pSquare_state;
           key : in small_pSquare_state;
           tweak : in small_pSquare_state;
           data_output : out small_pSquare_state;
           done : out STD_LOGIC);
end small_pSquare;

architecture Behavioral of small_pSquare is
    
    component AddModMersenne is
        Generic ( bits : INTEGER := 7);
        Port ( a : in UNSIGNED (bits-1 downto 0);
               b : in UNSIGNED (bits-1 downto 0);
               c : out UNSIGNED (bits-1 downto 0));
    end component;
    
    component SubModMersenne is
        Generic ( bits : INTEGER := 7);
        Port ( a : in UNSIGNED (bits-1 downto 0);
               b : in UNSIGNED (bits-1 downto 0);
               c : out UNSIGNED (bits-1 downto 0));
    end component;
    
    component SquModMersenne is
        Generic ( bits : INTEGER := 7);
        Port ( a : in UNSIGNED (bits-1 downto 0);
               b : out UNSIGNED (bits-1 downto 0));
    end component;
    
    signal round_input, round_tweak, round_tweakey, round_tweakey_input, art_output_enc, art_output_dec, art_output, round_output_enc_dec, round_output : small_pSquare_state;
    constant pi : STD_LOGIC_VECTOR(63 downto 0) := x"C90FDAA22168C234";
    signal rot_pi : STD_LOGIC_VECTOR(63 downto 0);
    signal round_constants1, round_constants2, sq1_in, sq1_out, sq2_out, sq3_out, mds2_in, mds3_in, mds4_in, add1_12, add1_34, add2_124, add2_234, add1_12_2, add1_34_2, mds2_out, mds4_out, add2_124_4, add2_234_4, mds1_out, mds3_out, f4_out, sq4_out, sq5_out, sq6_out, f1_out, f2_out, f3_out : small_pSquare_double;
    signal round_tweaks : tweak_schedule;
    
begin
    
    -- Compute all Round Tweaks
    round_tweaks(0) <= tweak;
    RTweaks: for i in 1 to 16 generate
        round_tweaks(i) <= ((round_tweaks(i-1)( 9)(5) & round_tweaks(i-1)( 9)(0) & round_tweaks(i-1)( 9)(3) & round_tweaks(i-1)( 9)(1) & round_tweaks(i-1)( 9)(6) & round_tweaks(i-1)( 9)(4) & round_tweaks(i-1)( 9)(2)), (round_tweaks(i-1)( 5)(4) & round_tweaks(i-1)( 5)(6) & round_tweaks(i-1)( 5)(2) & round_tweaks(i-1)( 5)(0) & round_tweaks(i-1)( 5)(5) & round_tweaks(i-1)( 5)(3) & round_tweaks(i-1)( 5)(1)), (round_tweaks(i-1)(13)(3) & round_tweaks(i-1)(13)(5) & round_tweaks(i-1)(13)(1) & round_tweaks(i-1)(13)(6) & round_tweaks(i-1)(13)(4) & round_tweaks(i-1)(13)(2) & round_tweaks(i-1)(13)(0)), (round_tweaks(i-1)(15)(2) & round_tweaks(i-1)(15)(4) & round_tweaks(i-1)(15)(0) & round_tweaks(i-1)(15)(5) & round_tweaks(i-1)(15)(3) & round_tweaks(i-1)(15)(1) & round_tweaks(i-1)(15)(6)), (round_tweaks(i-1)(12)(1) & round_tweaks(i-1)(12)(3) & round_tweaks(i-1)(12)(6) & round_tweaks(i-1)(12)(4) & round_tweaks(i-1)(12)(2) & round_tweaks(i-1)(12)(0) & round_tweaks(i-1)(12)(5)), (round_tweaks(i-1)( 7)(0) & round_tweaks(i-1)( 7)(2) & round_tweaks(i-1)( 7)(5) & round_tweaks(i-1)( 7)(3) & round_tweaks(i-1)( 7)(1) & round_tweaks(i-1)( 7)(6) & round_tweaks(i-1)( 7)(4)), (round_tweaks(i-1)(14)(6) & round_tweaks(i-1)(14)(1) & round_tweaks(i-1)(14)(4) & round_tweaks(i-1)(14)(2) & round_tweaks(i-1)(14)(0) & round_tweaks(i-1)(14)(5) & round_tweaks(i-1)(14)(3)), (round_tweaks(i-1)( 2)(5) & round_tweaks(i-1)( 2)(0) & round_tweaks(i-1)( 2)(3) & round_tweaks(i-1)( 2)(1) & round_tweaks(i-1)( 2)(6) & round_tweaks(i-1)( 2)(4) & round_tweaks(i-1)( 2)(2)), (round_tweaks(i-1)( 4)(4) & round_tweaks(i-1)( 4)(6) & round_tweaks(i-1)( 4)(2) & round_tweaks(i-1)( 4)(0) & round_tweaks(i-1)( 4)(5) & round_tweaks(i-1)( 4)(3) & round_tweaks(i-1)( 4)(1)), (round_tweaks(i-1)( 6)(3) & round_tweaks(i-1)( 6)(5) & round_tweaks(i-1)( 6)(1) & round_tweaks(i-1)( 6)(6) & round_tweaks(i-1)( 6)(4) & round_tweaks(i-1)( 6)(2) & round_tweaks(i-1)( 6)(0)), (round_tweaks(i-1)( 8)(2) & round_tweaks(i-1)( 8)(4) & round_tweaks(i-1)( 8)(0) & round_tweaks(i-1)( 8)(5) & round_tweaks(i-1)( 8)(3) & round_tweaks(i-1)( 8)(1) & round_tweaks(i-1)( 8)(6)), (round_tweaks(i-1)( 3)(1) & round_tweaks(i-1)( 3)(3) & round_tweaks(i-1)( 3)(6) & round_tweaks(i-1)( 3)(4) & round_tweaks(i-1)( 3)(2) & round_tweaks(i-1)( 3)(0) & round_tweaks(i-1)( 3)(5)), (round_tweaks(i-1)(10)(0) & round_tweaks(i-1)(10)(2) & round_tweaks(i-1)(10)(5) & round_tweaks(i-1)(10)(3) & round_tweaks(i-1)(10)(1) & round_tweaks(i-1)(10)(6) & round_tweaks(i-1)(10)(4)), (round_tweaks(i-1)( 1)(6) & round_tweaks(i-1)( 1)(1) & round_tweaks(i-1)( 1)(4) & round_tweaks(i-1)( 1)(2) & round_tweaks(i-1)( 1)(0) & round_tweaks(i-1)( 1)(5) & round_tweaks(i-1)( 1)(3)), (round_tweaks(i-1)(11)(5) & round_tweaks(i-1)(11)(0) & round_tweaks(i-1)(11)(3) & round_tweaks(i-1)(11)(1) & round_tweaks(i-1)(11)(6) & round_tweaks(i-1)(11)(4) & round_tweaks(i-1)(11)(2)), (round_tweaks(i-1)( 0)(4) & round_tweaks(i-1)( 0)(6) & round_tweaks(i-1)( 0)(2) & round_tweaks(i-1)( 0)(0) & round_tweaks(i-1)( 0)(5) & round_tweaks(i-1)( 0)(3) & round_tweaks(i-1)( 0)(1)));
    end generate;

    -- Round-Tweak and Key Addition
    TWK: for i in 0 to 15 generate
        ADDk: AddModMersenne Generic Map (7) Port Map (round_tweak(i), key(i), round_tweakey(i));
    end generate;

    -- Round-Input and Round-Tweakey Addition/Subtraction
    ARK: for i in 0 to 15 generate
        ADDtk: AddModMersenne Generic Map (7) Port Map (round_input(i), round_tweakey_input(i), art_output_enc(i));
        SUBtk: SubModMersenne Generic Map (7) Port Map (round_input(i), round_tweakey_input((i+12) mod 16), art_output_dec(i));
    end generate;
    -- Choose between Addition (Encryption) and Subtraction (Decryption) of the Round-Tweakey
    art_output <= art_output_enc when (dec = '0') else art_output_dec;
    
    -- Round-Constant Partitioning
    round_constants1 <= (UNSIGNED(rot_pi(6 downto 0)), UNSIGNED(rot_pi(38 downto 32)));
    round_constants2 <= (UNSIGNED(rot_pi(54 downto 48)), UNSIGNED(rot_pi(22 downto 16)));
    
    -- F-Functions
    F_Functions: for i in 0 to 1 generate        
        -- First Round-Constant Addition and Non-Linear Layer
        ADD1: AddModMersenne Generic Map (7) Port Map (art_output(3+i*8), round_constants1(i), sq1_in(i));
        SQ1: SquModMersenne Generic Map (7) Port Map (sq1_in(i), sq1_out(i));
        SQ2: SquModMersenne Generic Map (7) Port Map (art_output(2+i*8), sq2_out(i));
        SQ3: SquModMersenne Generic Map (7) Port Map (art_output(1+i*8), sq3_out(i));
        ADD2: AddModMersenne Generic Map (7) Port Map (art_output(2+i*8), sq1_out(i), mds2_in(i));
        ADD3: AddModMersenne Generic Map (7) Port Map (art_output(1+i*8), sq2_out(i), mds3_in(i));
        ADD4: AddModMersenne Generic Map (7) Port Map (art_output(0+i*8), sq3_out(i), mds4_in(i));
        
        -- MDS Matrix Multiplication
        ADD5: AddModMersenne Generic Map (7) Port Map (sq1_in(i), mds2_in(i), add1_12(i));
        ADD6: AddModMersenne Generic Map (7) Port Map (mds3_in(i), mds4_in(i), add1_34(i));
        ADD7: AddModMersenne Generic Map (7) Port Map (mds2_in(i), add1_34(i), add2_234(i));
        ADD8: AddModMersenne Generic Map (7) Port Map (mds4_in(i), add1_12(i), add2_124(i));
        add1_12_2(i) <= add1_12(i)(5 downto 0) & add1_12(i)(6);
        add1_34_2(i) <= add1_34(i)(5 downto 0) & add1_34(i)(6);
        ADD9: AddModMersenne Generic Map (7) Port Map (add1_34_2(i), add2_124(i), mds4_out(i));
        ADD10: AddModMersenne Generic Map (7) Port Map (add1_12_2(i), add2_234(i), mds2_out(i));
        add2_124_4(i) <= add2_124(i)(4 downto 0) & add2_124(i)(6 downto 5);
        add2_234_4(i) <= add2_234(i)(4 downto 0) & add2_234(i)(6 downto 5);
        ADD11: AddModMersenne Generic Map (7) Port Map (add2_124_4(i), mds2_out(i), mds1_out(i));
        ADD12: AddModMersenne Generic Map (7) Port Map (add2_234_4(i), mds4_out(i), mds3_out(i));
        
        -- Second Round-Constant Addition and Non-Linear Layer
        ADD13: AddModMersenne Generic Map (7) Port Map (mds1_out(i), round_constants2(i), f4_out(i));
        SQ4: SquModMersenne Generic Map (7) Port Map (f4_out(i), sq4_out(i));
        SQ5: SquModMersenne Generic Map (7) Port Map (mds2_out(i), sq5_out(i));
        SQ6: SquModMersenne Generic Map (7) Port Map (mds3_out(i), sq6_out(i));
        ADD14: AddModMersenne Generic Map (7) Port Map (mds2_out(i), sq4_out(i), f1_out(i));
        ADD15: AddModMersenne Generic Map (7) Port Map (mds3_out(i), sq5_out(i), f2_out(i));
        ADD16: AddModMersenne Generic Map (7) Port Map (mds4_out(i), sq6_out(i), f3_out(i));
    end generate;

    -- F Function Result Additions/Subtractions and Position Swap
    F_Result_Addition: for i in 0 to 1 generate
        ADDr1: AddModMersenne Generic Map (7) Port Map (art_output(4+i*8), f4_out(i), round_output_enc_dec(0+i*4));
        ADDr2: AddModMersenne Generic Map (7) Port Map (art_output(5+i*8), f3_out(i), round_output_enc_dec(1+i*4));
        ADDr3: AddModMersenne Generic Map (7) Port Map (art_output(6+i*8), f2_out(i), round_output_enc_dec(2+i*4));
        ADDr4: AddModMersenne Generic Map (7) Port Map (art_output(7+i*8), f1_out(i), round_output_enc_dec(3+i*4));
        SUBr1: SubModMersenne Generic Map (7) Port Map (art_output(4+i*8), f4_out(i), round_output_enc_dec(8+i*4));
        SUBr2: SubModMersenne Generic Map (7) Port Map (art_output(5+i*8), f3_out(i), round_output_enc_dec(9+i*4));
        SUBr3: SubModMersenne Generic Map (7) Port Map (art_output(6+i*8), f2_out(i), round_output_enc_dec(10+i*4));
        SUBr4: SubModMersenne Generic Map (7) Port Map (art_output(7+i*8), f1_out(i), round_output_enc_dec(11+i*4));
        round_output(0+i*8) <= round_output_enc_dec(0+i*4) when (dec = '0') else round_output_enc_dec(8+i*4);
        round_output(1+i*8) <= round_output_enc_dec(1+i*4) when (dec = '0') else round_output_enc_dec(9+i*4);
        round_output(2+i*8) <= round_output_enc_dec(2+i*4) when (dec = '0') else round_output_enc_dec(10+i*4);
        round_output(3+i*8) <= round_output_enc_dec(3+i*4) when (dec = '0') else round_output_enc_dec(11+i*4);
    end generate;
    Swap: for i in 0 to 3 generate
        round_output(4+i) <= art_output(8+i);
        round_output(12+i) <= art_output(i);
    end generate;
             
    -- State Machine
    FSM: process(clk)
        variable stepcounter : integer range 0 to 3;
        variable roundcounter : integer range 0 to 15;
        variable doneflag : integer range 0 to 1;
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                if (dec = '0') then
                    round_tweak                 <= round_tweaks(0);
                    round_input                 <= data_input;
                    rot_pi                      <= pi;
                else
                    round_tweak                 <= round_tweaks(16);
                    round_input                 <= (data_input(12), data_input(13), data_input(14), data_input(15), data_input(0), data_input(1), data_input(2), data_input(3), data_input(4), data_input(5), data_input(6), data_input(7), data_input(8), data_input(9), data_input(10), data_input(11));
                    rot_pi                      <= pi(0) & pi(63 downto 1);
                end if;
                round_tweakey_input             <= round_tweakey;
                stepcounter                     := 0;
                roundcounter                    := 0;
                doneflag                        := 0;
                done                            <= '0';
            else
                if(doneflag = 0) then
                    round_input                 <= round_output;
                    if (dec = '0') then
                        rot_pi                  <= rot_pi(62 downto 0) & rot_pi(63);
                    else
                        rot_pi                  <= rot_pi(32 downto 0) & rot_pi(63 downto 33);
                    end if;
                    if (stepcounter < 2) then
                        stepcounter             := stepcounter + 1;
                        round_tweakey_input     <= (others => (others => '0'));
                    elsif (stepcounter = 2) then
                        stepcounter             := stepcounter + 1;
                        if (dec = '0') then
                            round_tweak         <= round_tweaks(1 + roundcounter);
                        else
                            round_tweak         <= round_tweaks(15 - roundcounter);
                        end if;
                    else
                        round_tweakey_input     <= round_tweakey;
                        if (roundcounter < 15) then
                            stepcounter         := 0;
                            roundcounter        := roundcounter + 1;
                        else
                            doneflag            := 1;
                            done                <= '1';
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    data_output <= (art_output(0), art_output(1), art_output(2), art_output(3), art_output(4), art_output(5), art_output(6), art_output(7), art_output(8), art_output(9), art_output(10), art_output(11), art_output(12), art_output(13), art_output(14), art_output(15)) when (dec = '0') else (art_output(4), art_output(5), art_output(6), art_output(7), art_output(8), art_output(9), art_output(10), art_output(11), art_output(12), art_output(13), art_output(14), art_output(15), art_output(0), art_output(1), art_output(2), art_output(3));
    
end Behavioral;