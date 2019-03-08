library ieee;
    use ieee.std_logic_1164.all;

entity Control is
    port(
        instruction :in std_logic_vector (3 downto 0);
        CLK, RST :in std_logic;
        jump, branch, mem2Reg, memW, ri, regW, selDest :out std_logic;
        aluOut : out std_logic_vector(1 downto 0)
    );
end entity;

architecture behavior of Control is
    --JUMP(8) | Branch(7) | Mem2Reg(6) | MemW(5) | R/I(4) | RegW(3) | SelectDest(2) | ALU (1:0)
    signal ctrlOutput :std_logic_vector (8 downto 0);
begin

    jump <= ctrlOutput(8);
    branch <= ctrlOutput(7);
    mem2Reg <= ctrlOutput(6);
    memW <= ctrlOutput(5);
    ri <= ctrlOutput(4);
    regW <= ctrlOutput(3);
    selDest  <= ctrlOutput(2);
    aluOut <= ctrlOutput(1 downto 0);

    process(CLK) is
    begin
        if (rising_edge(CLK)) then
            if RST = '1' then
                ctrlOutput <= (others => '0');
            else
                with(instruction) select
                ctrlOutput <=   "000001100" when "0000",
                                "000001101" when "0001",
                                "000001110" when "0010",
                                "000001111" when "0011",
                                "001011000" when "0100",
                                "00X110X00" when "0101",
                                "000011100" when "0110",
                                --"XXXXXXXXX" when "0111",
                                "01X010X01" when "1000",
                                "10X0X0XXX" when "1001",
                                --"XXXXXXXXX" when "1010",
                                --"XXXXXXXXX" when "1011",
                                --"XXXXXXXXX" when "1100",
                                --"XXXXXXXXX" when "1101",
                                --"XXXXXXXXX" when "1110",
                                "000000000" when others;
            end if;
        end if;
    end process;

end architecture;