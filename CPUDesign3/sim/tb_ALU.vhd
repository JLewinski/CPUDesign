library ieee;
    use ieee.std_logic_1164.all;
    use ieee.NUMERIC_STD.all;

library std;
    use std.textio.all;

entity tb_ALU is
    --PORT(testOutput :out STD_LOGIC_VECTOR(15 downto 0));
end entity;

architecture rtl_sim of tb_ALU is

    constant CLK_PERIOD: time := 40 ns;
    constant RST_HOLD_DURATION: time := 200 ns;
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
        wait for falling_edge(RST);
        wait for falling_edge(CLK);
        
        for i in 0 to 3 loop
            SEL <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, 2));
            for j in 0 to 5 loop
                i_dataA <= STD_LOGIC_VECTOR(TO_UNSIGNED(j * 3, 16));
                for k in 0 to 5 loop
                    i_dataB <= STD_LOGIC_VECTOR(TO_UNSIGNED(k * 3 + 1, 16));
                    wait for falling_edge(CLK);
                end loop;
            end loop;
            for j in 16#FFFF# downto 16#FFF0# loop
                i_dataA <= STD_LOGIC_VECTOR(TO_UNSIGNED(j, 16));
                for k in 0 to 5 loop
                    i_dataB <= STD_LOGIC_VECTOR(TO_UNSIGNED(k * 3 + 1, 16));
                    wait for falling_edge(CLK);
                end loop;
            end loop;
            for j in 16#FFFF# downto 16#FFF0# loop
                i_dataA <= STD_LOGIC_VECTOR(TO_UNSIGNED(j, 16));
                for k in 16#FFFF# downto 16#FFF0# loop
                    i_dataB <= STD_LOGIC_VECTOR(TO_UNSIGNED(k - 4, 16));
                    wait for falling_edge(CLK);
                end loop;
            end loop;
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

