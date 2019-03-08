library ieee;
    use ieee.std_logic_1164.all;
    use ieee.NUMERIC_STD.all;

library std;
    use std.textio.all;

entity tb_Register16 is
end entity;

architecture rtl_sim of tb_Register16 is

    constant CLK_PERIOD: time := 40 ns;
    constant RST_HOLD_DURATION: time := 200 ns;
    signal dataIn: STD_LOGIC_VECTOR(15 downto 0);
    signal CLK: STD_LOGIC;
    signal WE: STD_LOGIC;
    signal RST: STD_LOGIC;
    signal dataOut: STD_LOGIC_VECTOR(15 downto 0);

begin

    Register16_inst: entity work.Register16
        port map (
            dataIn  => dataIn,
            CLK     => CLK,
            WE      => WE,
            RST     => RST,
            dataOut => dataOut
        );

    stimuli_p: process is
    begin
        WE <= '0';
        dataIn <= (others => '0');
        
        wait for falling_edge(RST);
        wait for falling_edge(CLK);
        
        for i in 2 ** 16 - 1 downto 0 loop
            WE <= '0';
            dataIn <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, 16));
            wait for falling_edge(CLK);
            WE <= '1';
            wait for falling_edge(CLK);
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

