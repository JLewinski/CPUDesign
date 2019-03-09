library ieee;
    use ieee.std_logic_1164.all;
    use ieee.NUMERIC_STD.all;

library std;
    use std.textio.all;

entity tb_ALU is
    --PORT(testOutput :out STD_LOGIC_VECTOR(15 downto 0));
end entity;

architecture rtl_sim of tb_ALU is

    constant CLK_PERIOD: time := 10 ns;
    constant RST_HOLD_DURATION: time := 20 ns;
    signal SEL: std_logic_vector(1 downto 0);
    signal CLK: std_logic;
    signal RST: std_logic;
    signal i_dataA: STD_LOGIC_VECTOR(15 downto 0);
    signal i_dataB: STD_LOGIC_VECTOR(15 downto 0);
    signal o_data: STD_LOGIC_VECTOR(15 downto 0);

begin
    --testOutput <= o_data;
    ALU_inst: entity work.ALU
        port map (
            SEL     => SEL,
            CLK     => CLK,
            RST     => RST,
            i_dataA => i_dataA,
            i_dataB => i_dataB,
            o_data  => o_data
        );

    stimuli_p: process is
    begin
        wait until falling_edge(RST);
        wait until falling_edge(CLK);

        for i in 0 to 3 loop
            SEL <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, 2));

            i_dataA <= STD_LOGIC_VECTOR(TO_UNSIGNED(0, 16));
            i_dataB <= STD_LOGIC_VECTOR(TO_UNSIGNED(0, 16));
            wait until falling_edge(CLK);

            i_dataA <= STD_LOGIC_VECTOR(TO_UNSIGNED(16#FFFF#, 16));
            i_dataB <= STD_LOGIC_VECTOR(TO_UNSIGNED(0, 16));
            wait until falling_edge(CLK);

            i_dataA <= STD_LOGIC_VECTOR(TO_UNSIGNED(0, 16));
            i_dataB <= STD_LOGIC_VECTOR(TO_UNSIGNED(16#FFFF#, 16));
            wait until falling_edge(CLK);

            i_dataA <= STD_LOGIC_VECTOR(TO_UNSIGNED(16#FF00#, 16));
            i_dataB <= STD_LOGIC_VECTOR(TO_UNSIGNED(16#FF00#, 16));
            wait until falling_edge(CLK);

            i_dataA <= STD_LOGIC_VECTOR(TO_UNSIGNED(16#00FF#, 16));
            i_dataB <= STD_LOGIC_VECTOR(TO_UNSIGNED(16#00FF#, 16));
            wait until falling_edge(CLK);

            i_dataA <= STD_LOGIC_VECTOR(TO_UNSIGNED(16#FF0F#, 16));
            i_dataB <= STD_LOGIC_VECTOR(TO_UNSIGNED(16#0A4F#, 16));
            wait until falling_edge(CLK);

        end loop;

        wait for CLK_PERIOD;


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

