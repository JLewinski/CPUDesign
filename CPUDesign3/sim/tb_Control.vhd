library ieee;
    use ieee.std_logic_1164.all;
    use ieee.NUMERIC_STD.all;

library std;
    use std.textio.all;

entity tb_Control is
end entity;

architecture rtl_sim of tb_Control is

    constant CLK_PERIOD: time := 10 ns;
    constant RST_HOLD_DURATION: time := 20 ns;
    signal instruction: std_logic_vector(3 downto 0);
    signal combined: std_logic_vector(8 downto 0);
    signal CLK: std_logic;
    signal RST: std_logic;
    signal jump: std_logic;
    signal branch: std_logic;
    signal mem2Reg: std_logic;
    signal memW: std_logic;
    signal ri: std_logic;
    signal regW: std_logic;
    signal selDest: std_logic;
    signal aluOut: std_logic_vector(1 downto 0);

begin

    Control_inst: entity work.Control
        port map (
            instruction => instruction,
            CLK         => CLK,
            RST         => RST,
            jump        => jump,
            branch      => branch,
            mem2Reg     => mem2Reg,
            memW        => memW,
            ri          => ri,
            regW        => regW,
            selDest     => selDest,
            aluOut      => aluOut
        );

    stimuli_p: process is
    begin
        wait until falling_edge(RST);
        wait until falling_edge(CLK);

        for i in 0 to 15 loop
            instruction <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, 4));
            wait until rising_edge(CLK);
            combined(8) <= jump;
            combined(7) <= branch;
            combined(6) <= mem2Reg;
            combined(5) <= memW;   
            combined(4) <= ri;  
            combined(3) <= regW;
            combined(2) <= selDest;
            combined(1 downto 0) <= aluOut ;

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

