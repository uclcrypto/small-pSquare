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
               tweak : in small_pSquare_state;
               ciphertext : out small_pSquare_state;
               done : out STD_LOGIC);
    end component;
    
    signal clk, rst, done : STD_LOGIC;
    signal plaintext, ciphertext : small_pSquare_state;
    constant key: small_pSquare_state := ("0101101", "1100000", "0000101", "1101101", "0111011", "0101110", "0001100", "0011110", "0010101", "0101010", "1101011", "1010101", "0000111", "0010001", "0010000", "0100110");
    constant tweak : small_pSquare_state := ("0110010", "0111001", "1001001", "1011010", "1011101", "0101111", "0001101", "0100000", "1110000", "1110111", "1000001", "1011111", "1011111", "1011100", "0010110", "1100001");
    constant clk_period : time := 10ns;

begin

    -- Unit Under Test
    UUT: small_pSquare Port Map (clk, rst, plaintext, key, tweak, ciphertext, done);

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
        
        if(ciphertext = ("1111101", "1110110", "1111010", "1110100", "0000110", "1010110", "0001011", "1000001", "1000101", "0010111", "1100111", "1011011", "1110000", "0001111", "1100010", "0011100")) then
            report "SUCCESS";
        else
            report "FAILURE";
        end if;
        
        wait for clk_period;
        
        if(ciphertext = ("1000110", "1001010", "0001111", "0001010", "1001011", "0010110", "0100110", "0000001", "1001011", "1110011", "1111001", "1101010", "0001011", "1111101", "0011110", "0011111")) then
            report "SUCCESS";
        else
            report "FAILURE";
        end if;
        
        wait;
    end process;

end Behavioral;