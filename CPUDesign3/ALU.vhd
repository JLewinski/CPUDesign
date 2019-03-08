library ieee;
    use ieee.std_logic_1164.all;
    use IEEE.NUMERIC_STD.all;

entity ALU is
    port(
        i_setting, CLK, RST :in std_logic_vector(1 downto 0);
        i_dataA, i_DataB :in signed(15 downto 0);
        o_data :out signed(15 downto 0)
    );
end entity ALU;

architecture behavior of ALU is
begin
    process (CLK, RST)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                o_data <= (others => '0');
            else
                with(i_setting) select
                o_data <=  i_dataA + i_DataB when "00",
                           i_dataA - i_DataB when "01",
                           i_dataA and i_DataB when "10",
                           i_dataA or i_DataB when "11";
            end if;
        end if;
    end process;
end architecture behavior;