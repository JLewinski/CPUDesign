library ieee;
    use IEEE.STD_LOGIC_1164.all;

entity Register16 is
    port(
        dataIn :in STD_LOGIC_VECTOR(15 downto 0);
        CLK, WE, RST :in STD_LOGIC;
        dataOut :out STD_LOGIC_VECTOR(15 downto 0)
    );
end entity;

architecture behavior of Register16 is
    signal initEnable : STD_LOGIC;
begin
    process(CLK) is
    begin
        if falling_edge(CLK) then
            if RST = '1' then
                initEnable <= '0';
                dataOut <= (others => '0');
            elsif WE = '1' and initEnable = '1' then
                dataOut <= dataIn;
            else
                initEnable <= '1';
            end if;
        end if;
    end process;
end architecture behavior;