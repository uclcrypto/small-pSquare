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
               dec : in STD_LOGIC;
               data_input : in small_pSquare_state;
               key : in small_pSquare_state;
               tweak : in small_pSquare_state;
               data_output : out small_pSquare_state;
               done : out STD_LOGIC);
    end component;
    
    signal clk, rst, dec, done : STD_LOGIC;
    signal data_input, key, tweak, data_output : small_pSquare_state;
    constant clk_period : time := 10 ns;

begin

    -- Unit Under Test
    UUT: small_pSquare Port Map (clk, rst, dec, data_input, key, tweak, data_output, done);

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
        dec                 <= '0';
    
        -- Test Vector 1
        data_input          <= ("1010010", "0110000", "0110100", "1100111", "0110111", "0001101", "0001110", "0100111", "0100100", "1010111", "1001000", "1100010", "1111011", "1101111", "1111011", "0011001");
        key                 <= ("0101101", "1100000", "0000101", "1101101", "0111011", "0101110", "0001100", "0011110", "0010101", "0101010", "1101011", "1010101", "0000111", "0010001", "0010000", "0100110");
        tweak               <= ("0110010", "0111001", "1001001", "1011010", "1011101", "0101111", "0001101", "0100000", "1110000", "1110111", "1000001", "1011111", "1011111", "1011100", "0010110", "1100001");

        wait for 5*clk_period;
        
        rst                 <= '0';
        
        wait until done = '1';
        
        wait for clk_period;
        
        if(data_output = ("1111101", "1110110", "1111010", "1110100", "0000110", "1010110", "0001011", "1000001", "1000101", "0010111", "1100111", "1011011", "1110000", "0001111", "1100010", "0011100")) then
            report "SUCCESS";
        else
            report "FAILURE";
        end if;
        
        wait for clk_period;
        
        rst                 <= '1';
        dec                 <= '1';
    
        -- Test Vector 1
        data_input          <= data_output;
        
        wait for 5*clk_period;
        
        rst                 <= '0';
        
        wait until done = '1';
        
        wait for clk_period;
        
        if(data_output = ("1010010", "0110000", "0110100", "1100111", "0110111", "0001101", "0001110", "0100111", "0100100", "1010111", "1001000", "1100010", "1111011", "1101111", "1111011", "0011001")) then
            report "SUCCESS";
        else
            report "FAILURE";
        end if;
        
        wait;
    end process;

end Behavioral;