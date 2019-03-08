library ieee;
    use ieee.std_logic_1164.all;
    use ieee.NUMERIC_STD.all;

library std;
    use std.textio.all;

entity tb_RegisterMemory is
end entity;

architecture rtl_sim of tb_RegisterMemory is

    constant CLK_PERIOD: time := 40 ns;
    constant RST_HOLD_DURATION: time := 200 ns;
    signal DataIn: STD_LOGIC_VECTOR(15 downto 0);
    signal SourceA: STD_LOGIC_VECTOR(3 downto 0);
    signal SourceB: STD_LOGIC_VECTOR(3 downto 0);
    signal DestAddr: STD_LOGIC_VECTOR(3 downto 0);
    signal inr: STD_LOGIC_VECTOR(3 downto 0);
    signal WriteEn: STD_LOGIC;
    signal CLK: STD_LOGIC;
    signal RST: STD_LOGIC;
    signal DataOutA: STD_LOGIC_VECTOR(15 downto 0);
    signal DataOutB: STD_LOGIC_VECTOR(15 downto 0);
    signal outValue: STD_LOGIC_VECTOR(15 downto 0);

begin

    RegisterMemory_inst: entity work.RegisterMemory
        port map (
            DataIn   => DataIn,
            SourceA  => SourceA,
            SourceB  => SourceB,
            DestAddr => DestAddr,
            inr      => inr,
            WriteEn  => WriteEn,
            CLK      => CLK,
            RST      => RST,
            DataOutA => DataOutA,
            DataOutB => DataOutB,
            outValue => outValue
        );

    stimuli_p: process is
    begin
        WriteEn <= '0';
        DataIn <= (others => '0');
        DestAddr <= (others => '0');
        
        wait for falling_edge(RST);
        wait for falling_edge(CLK);
        
        WriteEn <= '1';
        for i in 0 to 16#FFFF# loop
            DataIn <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, 16));
            DestAddr <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, 16));
            wait until falling_edge(CLK);
        end loop;
        WriteEn <= '0';
        for i in 0 to 16#FFFF# loop
            inr <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, 16));
            SourceA <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, 16));
            SourceB <= STD_LOGIC_VECTOR(TO_UNSIGNED(16#FFFF# - i, 16));
            wait until falling_edge(CLK);
        end loop;
        
        wait;
    end process;

    clock_p: process is
    begin
        CLK <= '0';
        wait for CLK_PERIOD / 2;
        CLK <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    reset_p: process is
    begin
        RST <= '1';
        wait for RST_HOLD_DURATION;
        wait until rising_edge(CLK);
        RST <= '0';
        wait;
    end process;

end architecture;

