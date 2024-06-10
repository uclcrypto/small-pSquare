library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.small_pSquare_data_types.ALL;

entity TB_small_pSquare_4SHARES is
end TB_small_pSquare_4SHARES;

architecture Behavioral of TB_small_pSquare_4SHARES is

    component small_pSquare_4SHARES is
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
    end component;
    
    component AddModMersenne is
        Generic ( bits : INTEGER := 7);
        Port ( a : in UNSIGNED (bits-1 downto 0);
               b : in UNSIGNED (bits-1 downto 0);
               c : out UNSIGNED (bits-1 downto 0));
    end component;
    
    signal clk, rst, done : STD_LOGIC;
    signal plaintext, key, tweak, ciphertext : small_pSquare_state;
    signal plaintext_t1, plaintext_t2, key_t1, key_t2, ciphertext_t1, ciphertext_t2 : small_pSquare_state;
    signal plaintext_s0, plaintext_s1, plaintext_s2, plaintext_s3, key_s0, key_s1, key_s2, key_s3, ciphertext_s0, ciphertext_s1, ciphertext_s2, ciphertext_s3 : small_pSquare_state;
    signal fresh_randomness : small_pSquare_4SHARES_randomness;
    constant clk_period : time := 10 ns;

begin

    -- Unit Under Test
    UUT: small_pSquare_4SHARES Port Map (clk, rst, plaintext_s0, plaintext_s1, plaintext_s2, plaintext_s3, key_s0, key_s1, key_s2, key_s3, tweak, fresh_randomness, ciphertext_s0, ciphertext_s1, ciphertext_s2, ciphertext_s3, done);
    
    -- Masking and Unmasking
    MaskUnmask: for i in 0 to 15 generate
        ADDp1 : AddModMersenne Generic Map (7) Port Map (plaintext_s0(i), plaintext_s1(i), plaintext_t1(i));
        ADDp2 : AddModMersenne Generic Map (7) Port Map (plaintext_t1(i), plaintext_s2(i), plaintext_t2(i));
        ADDp3 : AddModMersenne Generic Map (7) Port Map (plaintext_t2(i), plaintext_s3(i), plaintext(i));
        ADDk1 : AddModMersenne Generic Map (7) Port Map (key_s0(i), key_s1(i), key_t1(i));
        ADDk2 : AddModMersenne Generic Map (7) Port Map (key_t1(i), key_s2(i), key_t2(i));
        ADDk3 : AddModMersenne Generic Map (7) Port Map (key_t2(i), key_s3(i), key(i));
        ADDc1 : AddModMersenne Generic Map (7) Port Map (ciphertext_s0(i), ciphertext_s1(i), ciphertext_t1(i));
        ADDc2 : AddModMersenne Generic Map (7) Port Map (ciphertext_t1(i), ciphertext_s2(i), ciphertext_t2(i));
        ADDc3 : AddModMersenne Generic Map (7) Port Map (ciphertext_t2(i), ciphertext_s3(i), ciphertext(i));
    end generate;

    -- Clock Process
    clk_proc: process
    begin
        clk <= '1';
        wait for clk_period/2;
        clk <= '0';
        wait for clk_period/2;
    end process;
    
    -- Stimulation Process
    stim_proc: process
    begin
        rst                 <= '1';
        
        -- Test Vector 1
        plaintext_s0        <= ("0011001", "1101110", "1001101", "0011001", "0111101", "1000101", "0011111", "0001111", "0000111", "0011001", "1101110", "1000111", "0000001", "1101101", "0010000", "0101110");
        plaintext_s1        <= ("1110110", "1111110", "1101111", "1010001", "1110101", "1010001", "1111100", "1001100", "0110000", "0111110", "1001111", "0001111", "0011011", "0000101", "1001110", "0010110");
        plaintext_s2        <= ("1011011", "0111110", "0110011", "0100011", "1001010", "0110011", "0110111", "1101100", "1100101", "0100111", "1111110", "1110000", "1010101", "0101011", "1110101", "0000110");
        plaintext_s3        <= ("1100110", "0000100", "1000011", "1011001", "0111001", "1000010", "0111010", "1011110", "0000111", "1011000", "0001011", "0011011", "0001010", "1010001", "0100111", "1001110");
        key_s0              <= ("0111011", "0000111", "1001000", "0111111", "0011110", "1100110", "0110011", "1000100", "1111101", "0100000", "0101111", "0000010", "0111011", "0000101", "1111001", "0101001");
        key_s1              <= ("0101111", "1100110", "0000100", "1111010", "0110100", "0000110", "1110011", "1010101", "1100001", "0010110", "1000101", "1010111", "0110000", "0101011", "0100000", "1111101");
        key_s2              <= ("1011110", "1010101", "0010000", "0100101", "0110001", "0110010", "0011100", "1001001", "1100001", "0100011", "1110010", "1100000", "0111010", "1001110", "1010010", "1011000");
        key_s3              <= ("1100011", "0011101", "0101000", "0001110", "0110111", "0001111", "1001000", "0111010", "1010011", "1010000", "0000100", "0011011", "1100000", "0010010", "0100011", "0100110");
        tweak               <= ("0110010", "0111001", "1001001", "1011010", "1011101", "0101111", "0001101", "0100000", "1110000", "1110111", "1000001", "1011111", "1011111", "1011100", "0010110", "1100001");
        fresh_randomness    <= ("1100101", "1100110", "0001011", "0000000", "1110101", "0100001", "1010010", "1110101", "1101101", "1100000", "0010000", "0011010", "0001110", "1000100", "0011110", "0010010", "1011001", "0001101", "1110001", "1011010", "1000011", "0100110", "0011111", "1010100", "0100111", "0111111", "0000100", "0000001", "1100111", "1001110", "0001110", "0101000", "1001100", "1101001", "0111000", "0100010", "0010000", "1000100", "0111110", "1001111", "1010110", "1101000", "0000001", "1111011", "1100010", "1011011", "1001000", "1010010", "0100100", "1001110", "1000101", "1110011", "0110000", "0010000", "1100100", "0001011", "0110000", "1010100", "0010001", "0111000", "0011011", "0010000", "1001111", "1010111", "0100000", "1111000", "1001101", "1110110", "1011101", "1100011", "1100011", "1100001");
        
        wait for 5*clk_period;
        
        -- Test Vector 2
        plaintext_s0        <= ("0011100", "0011100", "0011111", "1000000", "0100111", "0100100", "0101011", "1011001", "0001111", "1110110", "0010011", "0001011", "0000010", "0001010", "0001010", "1011101");
        plaintext_s1        <= ("0111000", "0000110", "0110101", "0011111", "1001110", "0011110", "1001111", "0010100", "0011011", "1100100", "1111110", "1100100", "1001001", "0111010", "0011011", "0100000");
        plaintext_s2        <= ("1010010", "0001110", "0011111", "1100010", "0111011", "1101000", "1001000", "0100001", "1001010", "0010101", "0000010", "0011111", "0010101", "1111001", "0010011", "1111000");
        plaintext_s3        <= ("0100111", "1101111", "0010100", "1101111", "0110110", "0001110", "1010111", "0011101", "0000010", "1000010", "1111000", "0101111", "1010001", "0011111", "1001111", "0111010");
        key_s0              <= ("1110100", "1110101", "1111100", "0110111", "1011101", "0111010", "1011010", "1011010", "0100000", "0100100", "0011011", "0000000", "0000111", "0010110", "1110111", "1100011");
        key_s1              <= ("1001110", "0101000", "1010001", "0011001", "0111110", "1011101", "1100001", "1100101", "1010101", "1110111", "1010000", "1001001", "1011101", "1011000", "0000100", "1111101");
        key_s2              <= ("1101010", "1110111", "1001100", "0010110", "0000001", "0111100", "0100101", "1011101", "0001000", "1110100", "0111111", "0111100", "1111000", "0001110", "1110011", "1010111");
        key_s3              <= ("1111110", "1001010", "1101001", "0000111", "0011110", "1011001", "0101010", "0000000", "0010111", "0011001", "1000000", "1001111", "0101001", "0010100", "0100000", "1101100");
        tweak               <= ("1101110", "0000111", "0010010", "1110011", "0010100", "1100100", "1111000", "0000110", "0100100", "1101111", "0111011", "0011101", "1110001", "0100001", "1110001", "1001100");
        fresh_randomness    <= ("0010100", "1001010", "0011111", "0111101", "1110010", "0001110", "1011110", "0011111", "1110101", "0000110", "1101000", "0001000", "0111100", "0110111", "0111100", "0101000", "1101011", "0010000", "1010111", "1100110", "1101100", "1011111", "0101000", "1101111", "1111101", "0111111", "1101101", "0001111", "0101011", "1010010", "1110011", "0011010", "0011011", "1101010", "1101001", "0100011", "1011100", "1001101", "0011101", "1010101", "0100011", "0100111", "1010111", "1111101", "1111100", "1101100", "0111111", "0100011", "0011010", "0111111", "1010011", "1110100", "0011011", "0011011", "0010111", "0111101", "1111010", "0111100", "1010110", "1011001", "0001011", "0111001", "0101100", "0011101", "0101010", "0010010", "0111000", "0001000", "0010011", "1010011", "0011100", "0100010");
    
        wait for clk_period;
        
        rst                 <= '0';
        
        wait until done = '1';
        
        if(ciphertext = ("1111101", "1110110", "1111010", "1110100", "0000110", "1010110", "0001011", "1000001", "1000101", "0010111", "1100111", "1011011", "1110000", "0001111", "1100010", "0011100")) then
            report "SUCCESS";
        else
            report "FAILURE";
        end if;
        
        wait for clk_period;
        
        if(ciphertext = ("0110001", "0001100", "1011111", "0011111", "0010010", "1000111", "0001011", "0011111", "0110100", "0010000", "1011101", "1101110", "0001001", "0111101", "0101101", "1111001")) then
            report "SUCCESS";
        else
            report "FAILURE";
        end if;
        
        wait;
    end process;

end Behavioral;