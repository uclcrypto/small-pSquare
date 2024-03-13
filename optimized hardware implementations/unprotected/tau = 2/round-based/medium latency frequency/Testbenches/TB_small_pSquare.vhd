library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.small_pSquare_data_types.ALL;

entity TB_small_pSquare is
end TB_small_pSquare;

architecture Behavioral of TB_small_pSquare is

    component small_pSquare is
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               plaintext : in small_pSquare_state;
               key : in small_pSquare_state;
               tweak0 : in small_pSquare_state;
               tweak1 : in small_pSquare_state;
               ciphertext : out small_pSquare_state;
               done : out STD_LOGIC);
    end component;
    
    signal clk, rst, done : STD_LOGIC;
    signal plaintext, ciphertext : small_pSquare_state;
    constant key: small_pSquare_state := ("0101101", "1100000", "0000101", "1101101", "0111011", "0101110", "0001100", "0011110", "0010101", "0101010", "1101011", "1010101", "0000111", "0010001", "0010000", "0100110");
    constant tweak0 : small_pSquare_state := ("0110010", "0111001", "1001001", "1011010", "1011101", "0101111", "0001101", "0100000", "1110000", "1110111", "1000001", "1011111", "1011111", "1011100", "0010110", "1100001");
    constant tweak1 : small_pSquare_state := ("1011100", "1111101", "0100100", "1010011", "0100010", "1111001", "0110110", "0101101", "0001100", "1000110", "1001101", "1111110", "1011010", "0101010", "1001111", "0100110");
    constant clk_period : time := 10ns;

begin

    -- Unit Under Test
    UUT: small_pSquare Port Map (clk, rst, plaintext, key, tweak0, tweak1, ciphertext, done);

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
        plaintext           <= ("1010010", "0110000", "0110100", "1100111", "0110111", "0001101", "0001110", "0100111", "0100100", "1010111", "1001000", "1100010", "1111011", "1101111", "1111011", "0011001");
        
        wait for 5*clk_period;
    
        -- Test Vector 2
        plaintext           <= ("1001110", "0100000", "0001000", "0110010", "1100111", "0111001", "0011011", "0101100", "1110110", "0110011", "0001101", "0111110", "0110010", "1011101", "0001000", "0110001");
        
        wait for clk_period;
        
        rst                 <= '0';
        
        wait until done = '1';
        
        if(ciphertext = ("1001100", "1010100", "1101101", "1011011", "1011100", "0000001", "1111100", "1010110", "1011010", "0010000", "0100110", "0000010", "0011110", "1010001", "0100100", "1111001")) then
            report "SUCCESS";
        else
            report "FAILURE";
        end if;
        
        wait for clk_period;
        
        if(ciphertext = ("0001100", "0100011", "1011111", "0100100", "1001110", "1111101", "0100010", "0001110", "1010111", "1101011", "1011010", "0110101", "1000100", "1000100", "0000111", "0100100")) then
            report "SUCCESS";
        else
            report "FAILURE";
        end if;
        
        wait;
    end process;

end Behavioral;