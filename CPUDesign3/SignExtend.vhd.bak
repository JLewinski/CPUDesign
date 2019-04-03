library IEEE;
    use IEEE.STD_LOGIC_1164.all;
    use IEEE.NUMERIC_STD.all;

--Might be able to use SXT function instead
entity SignExtend is
    generic(
        inputWidth : integer := 8;
        outputWidth : integer := 16
    );
    port(
        dataIn :in STD_LOGIC_VECTOR(inputWidth - 1 downto 0);
        CLK, RST :in STD_LOGIC;
        dataOut :out STD_LOGIC_VECTOR(outputWidth - 1 downto 0)
    );
end entity;

architecture behavior of SignExtend is
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                dataOut <= (others => '0');
            else
                dataOut(outputWidth - 1 downto inputWidth) <= (others => dataIn(inputWidth - 1));
                dataOut(inputWidth - 1 downto 0) <= dataIn;
            end if;
        end if;
    end process;
end architecture behavior;