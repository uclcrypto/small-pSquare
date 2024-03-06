library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.small_pSquare_data_types.ALL;

entity TB_small_pSquare_2SHARES is
end TB_small_pSquare_2SHARES;

architecture Behavioral of TB_small_pSquare_2SHARES is

    component small_pSquare_2SHARES is
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
    end component;
    
    component AddModMersenne is
        Generic ( bits : INTEGER := 7);
        Port ( a : in UNSIGNED (bits-1 downto 0);
               b : in UNSIGNED (bits-1 downto 0);
               c : out UNSIGNED (bits-1 downto 0));
    end component;
    
    signal clk, rst, done : STD_LOGIC;
    signal plaintext, key, tweak, ciphertext : small_pSquare_state;
    signal plaintext_s0, plaintext_s1, key_s0, key_s1, ciphertext_s0, ciphertext_s1 : small_pSquare_state;
    signal fresh_randomness : small_pSquare_2SHARES_randomness;
    constant clk_period : time := 10ns;

begin

    -- Unit Under Test
    UUT: small_pSquare_2SHARES Port Map (clk, rst, plaintext_s0, plaintext_s1, key_s0, key_s1, tweak, fresh_randomness, ciphertext_s0, ciphertext_s1, done);
    
    -- Masking and Unmasking
    MaskUnmask: for i in 0 to 15 generate
        ADDp : AddModMersenne Generic Map (7) Port Map (plaintext_s0(i), plaintext_s1(i), plaintext(i));
        ADDk : AddModMersenne Generic Map (7) Port Map (key_s0(i), key_s1(i), key(i));
        ADDc : AddModMersenne Generic Map (7) Port Map (ciphertext_s0(i), ciphertext_s1(i), ciphertext(i));
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
        plaintext_s1        <= ("0111001", "1000001", "1100110", "1001110", "1111001", "1000111", "1101110", "0011000", "0011101", "0111110", "1011001", "0011011", "1111010", "0000010", "1101011", "1101010");
        key_s0              <= ("0111011", "0000111", "1001000", "0111111", "0011110", "1100110", "0110011", "1000100", "1111101", "0100000", "0101111", "0000010", "0111011", "0000101", "1111001", "0101001");
        key_s1              <= ("1110001", "1011001", "0111100", "0101110", "0011101", "1000111", "1011000", "1011001", "0010111", "0001010", "0111100", "1010011", "1001011", "0001100", "0010110", "1111100");
        tweak               <= ("0110010", "0111001", "1001001", "1011010", "1011101", "0101111", "0001101", "0100000", "1110000", "1110111", "1000001", "1011111", "1011111", "1011100", "0010110", "1100001");
        fresh_randomness    <= ("0000001", "1011011", "0000001", "1011100", "1111101", "0010000");

        wait for 5*clk_period;
        
        rst                 <= '0';
        
        wait until done = '1';
        
        wait for clk_period;
        
        if(ciphertext = ("1111101", "1110110", "1111010", "1110100", "0000110", "1010110", "0001011", "1000001", "1000101", "0010111", "1100111", "1011011", "1110000", "0001111", "1100010", "0011100")) then
            report "SUCCESS";
        else
            report "FAILURE";
        end if;
        
        wait for clk_period;
        
        rst                 <= '1';
    
        -- Test Vector 2
        plaintext_s0        <= ("0011100", "0011100", "0011111", "1000000", "0100111", "0100100", "0101011", "1011001", "0001111", "1110110", "0010011", "0001011", "0000010", "0001010", "0001010", "1011101");
        plaintext_s1        <= ("0110010", "0000100", "1101000", "1110001", "1000000", "0010101", "1101111", "1010010", "1100111", "0111100", "1111001", "0110011", "0110000", "1010011", "1111101", "1010011");
        key_s0              <= ("1110100", "1110101", "1111100", "0110111", "1011101", "0111010", "1011010", "1011010", "0100000", "0100100", "0011011", "0000000", "0000111", "0010110", "1110111", "1100011");
        key_s1              <= ("1111011", "0110010", "1001101", "1010101", "1011110", "1110000", "0011010", "1011101", "1100011", "1010000", "1001110", "1110100", "0101011", "1010111", "0101001", "0100101");
        tweak               <= ("1101110", "0000111", "0010010", "1110011", "0010100", "1100100", "1111000", "0000110", "0100100", "1101111", "0111011", "0011101", "1110001", "0100001", "1110001", "1001100");
        fresh_randomness    <= ("1110100", "0001111", "1010100", "0011111", "1010001", "1101000");
        
        wait for 5*clk_period;
        
        rst                 <= '0';
        
        wait until done = '1';
        
        wait for clk_period;
        
        if(ciphertext = ("0001111", "1011001", "0101010", "1100101", "0111011", "0111011", "1101011", "0000010", "0100100", "0011100", "1111000", "0101100", "1111001", "1101011", "1011101", "0101011")) then
            report "SUCCESS";
        else
            report "FAILURE";
        end if;
        
        wait;
    end process;

end Behavioral;