library ieee;
    use ieee.std_logic_1164.all;

entity Control is
    port(
        instruction :in std_logic_vector (3 downto 0);
        RST :in std_logic;
        jump, branch, mem2Reg, memW, ri, regW, selDest, halt :out std_logic;
        aluOut : out std_logic_vector(1 downto 0)
    );
end entity;

architecture behavior of Control is
    --JUMP(8) | Branch(7) | Mem2Reg(6) | MemW(5) | R/I(4) | RegW(3) | SelectDest(2) | ALU (1:0)
    signal ctrlOutput :std_logic_vector (9 downto 0);
begin

    halt <= ctrlOutput(9);
    jump <= ctrlOutput(8);
    branch <= ctrlOutput(7);
    mem2Reg <= ctrlOutput(6);
    memW <= ctrlOutput(5);
    ri <= ctrlOutput(4);
    regW <= ctrlOutput(3);
    selDest  <= ctrlOutput(2);
    aluOut <= ctrlOutput(1 downto 0);

    process(RST, instruction) is
    begin
        if RST = '1' then
            ctrlOutput <= (others => '0');
        else
            case instruction is
                when "0000" => ctrlOutput <= "1000001100";
                when "0001" => ctrlOutput <= "1000001101";
                when "0010" => ctrlOutput <= "1000001110";
                when "0011" => ctrlOutput <= "1000001111";
                when "0100" => ctrlOutput <= "1001011000";
                when "0101" => ctrlOutput <= "1000110000";
                when "0110" => ctrlOutput <= "1000011000";
                when "1000" => ctrlOutput <= "1010010001";
                when "1001" => ctrlOutput <= "1100000000";
                when "1111" => ctrlOutput <= "0000000000";
                when others => ctrlOutput <= "0000000000";
            end case;
        end if;
    end process;

end architecture;