library ieee;
    use ieee.std_logic_1164.all;
    use ieee.NUMERIC_STD.all;

library std;
    use std.textio.all;

entity tb_top is
end entity;

architecture rtl_sim of tb_top is
    constant CLK_PERIOD: time := 40 ns;
    constant RST_HOLD_DURATION: time := 60 ns;
    signal CLK: STD_LOGIC;
    signal RST: STD_LOGIC;
    signal inr: STD_LOGIC_VECTOR(3 downto 0);
    signal outValue: STD_LOGIC_VECTOR(15 downto 0);
    signal enabled: boolean := true;
    signal computeProcess: boolean;
    signal s0, s1, s2, s3, s4, s5, s6, s7 : integer;
begin

    stimuli_p: process is
    begin
        wait;
    end process;

    top_inst: entity work.top
        port map (
            CLK          => CLK,
            RST          => RST,
            inr          => inr,
            outValue     => outValue
        );

    clock_p: process is
    begin
        CLK <= '0';
        wait for CLK_PERIOD / 2;
        CLK <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    gen_check: process
    begin

        if enabled then
            computeProcess <= true;
            s1 <= 7;
            s0 <= 0;
            inr <= X"0";
            RST <= '1';
            wait for RST_HOLD_DURATION;
            wait until rising_edge(CLK);
            RST <= '0';

            assert outValue = X"0000"
                report "S0 != 0"
                severity FAILURE;

            --check instructions
            --ADC s1 s0 s7

            wait for CLK_PERIOD;

            wait until falling_edge(CLK);

            inr <= X"1";
            wait until rising_edge(CLK);
            wait for 1 ns;
            assert outValue = X"0007"
                report "S1 != 7"
                severity FAILURE;

            wait until falling_edge(CLK);

            inr <= X"2";

            --ADC s2 s0 3
            s2 <= 3;
            wait until rising_edge(CLK);
            wait for 1 ns;
            assert outValue = X"0003"
                report "S2 != 3"
                severity FAILURE;


            enabled <= false;
        end if;
        -- if output = X"FFFF" then
        --     report "DONE";
        --     enabled <= '0';
        --     wait for CLK_PERIOD * 4;
        --     wait until falling_edge(CLK);
        -- else

            --s1 = 7
            --ADD s3 s1 s2
            s3 <= s1 + s2;
            wait until falling_edge(CLK);

            inr <= X"3";

            wait until rising_edge(CLK);
            wait for 1 ns;

            assert outValue = std_logic_vector(to_signed(s3, 16))
                report "S3 != s1 + s2"
                severity FAILURE;

            --SUB s4 s1 s2
            s4 <= s1 - s2;
            wait until falling_edge(CLK);

            inr <= X"4";

            wait until rising_edge(CLK);
            wait for 1 ns;

            assert outValue = std_logic_vector(to_signed(s4, 16))
                report "S4 != s1 - s2 = 4"
                severity FAILURE;

            --AND s5 s1 s4
            s5 <= to_integer(to_signed(s1, 16) and to_signed(s4, 16));
            wait until falling_edge(CLK);

            inr <= X"5";

            wait until rising_edge(CLK);
            wait for 1 ns;

            assert outValue = std_logic_vector(to_signed(s5, 16))
                report "S5 != s1 & s4"
                severity FAILURE;

            --OR s6 s1 s4
            s6 <= to_integer(to_signed(s1, 16) or to_signed(s4, 16));
            wait until falling_edge(CLK);

            inr <= X"6";

            wait until rising_edge(CLK);
            wait for 1 ns;

            assert outValue = std_logic_vector(to_signed(s6, 16))
                report "S5 != s1 | s4"
                severity FAILURE;

            
            wait for CLK_PERIOD * 4;

            if computeProcess then
                wait for CLK_PERIOD;

                computeProcess <= s1 > 0;
                --OR s7 s1 s0
                s7 <= to_integer(to_signed(s1, 16) or to_signed(s0, 16));
                wait until falling_edge(CLK);

                inr <= X"7";

                wait until rising_edge(CLK);
                wait for 1 ns;

                assert outValue = std_logic_vector(to_signed(s7, 16))
                    report "S7 != s1 | s0"
                    severity FAILURE;
                    
                    --BEZ s1 done
                    wait until falling_edge(CLK);
                    

                wait until rising_edge(CLK);

                if computeProcess then
                    --ADC s1 s1 -1
                    s1 <= s1 - 1;
                    wait until falling_edge(CLK);

                    inr <= X"1";

                    wait until rising_edge(CLK);
                    wait for 1 ns;

                    assert outValue = std_logic_vector(to_signed(s1, 16))
                        report "S1 != s1 - 1"
                        severity FAILURE;

                    --J loop
                    wait until falling_edge(CLK);
                    wait until rising_edge(CLK);
                else
                    s1 <= 7;
                    wait for CLK_PERIOD * 2;
                end if;
            else
                if s1 = 0 then
                    report "DONE";
                    wait;
                else
                    s1 <= s1 - 1;
                    wait for 1 ns;
                end if;
            end if;
        -- end if;

    end process;


end architecture;