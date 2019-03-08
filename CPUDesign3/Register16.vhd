library ieee;
    use IEEE.STD_LOGIC_1164.all;

entity Register16 is
    PORT(
        dataIn :in STD_LOGIC_VECTOR(15 downto 0);
        CLK, WE, RST :in STD_LOGIC;
        dataOut :out STD_LOGIC_VECTOR(15 downto 0)
    );
end entity;

architecture behavior of Register16 is
begin
    process(CLK) is
    begin
        if RST = '1' then
            dataOut <= (others => '0');
        elsif rising_edge(CLK) then
            if WE = '1' then
                dataOut <= dataIn;
            end if;
        end if;
    end process;
end architecture behavior;