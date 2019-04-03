library ieee;
    use ieee.std_logic_1164.all;
    use ieee.NUMERIC_STD.all;

library std;
    use std.textio.all;

entity tb_top is
end entity;

architecture rtl_sim of tb_top is
    constant CLK_PERIOD: time := 40 ns;
    constant RST_HOLD_DURATION: time := 200 ns;
    signal CLK: STD_LOGIC;
    signal RST: STD_LOGIC;
    signal readDataBus: STD_LOGIC_VECTOR(15 downto 0);
    signal inr: STD_LOGIC_VECTOR(3 downto 0);
    signal addressBus: STD_LOGIC_VECTOR(9 downto 0);
    signal output: STD_LOGIC_VECTOR(15 downto 0);
    signal outValue: STD_LOGIC_VECTOR(15 downto 0);
    signal writeDataBus: STD_LOGIC_VECTOR(15 downto 0);
    signal writeAddress: STD_LOGIC_VECTOR(15 downto 0);
begin

    stimuli_p: process is
    begin
        wait;
    end process;

    top_inst: entity work.top
        port map (
            CLK          => CLK,
            RST          => RST,
            readDataBus  => readDataBus,
            inr          => inr,
            addressBus   => addressBus,
            output       => output,
            outValue     => outValue,
            writeDataBus => writeDataBus,
            writeAddress => writeAddress
        );

    clock_p: process is
    begin
        CLK <= '0';
        wait for CLK_PERIOD / 2;
        CLK <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    reset_p: process is
    begin
        inr <= X"0";
        RST <= '1';
        wait for RST_HOLD_DURATION;
        wait until rising_edge(CLK);
        RST <= '0';
        
        wait for CLK_PERIOD;
        
        --check instructions
        --ADC s1 s0 s7
        wait for CLK_PERIOD;

        wait until falling_edge(CLK);
        
        wait for 5 ns;
        inr <= X"1";
        wait for 5 ns;
        assert output = X"0007"
            report "S1 != 7"
            SEVERITY FAILURE;
        
        wait until falling_edge(CLK);
        
        inr <= X"2";
        
        wait for CLK_PERIOD / 4;
        assert output = X"0003"
            report "S2 != 3"
            SEVERITY FAILURE;
        
        inr <= X"3";
        wait until rising_edge(CLK);

        wait for CLK_PERIOD / 4;
        assert output = X"000A"
            report "S3 != 7 + 3 = 10"
            severity FAILURE;

        wait;
        
    end process;
    
    
end architecture;