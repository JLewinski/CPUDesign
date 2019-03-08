library ieee;
    use ieee.std_logic_1164.all;
    use IEEE.NUMERIC_STD.all;

entity ALU is
    port(
        i_setting :in std_logic_vector(1 downto 0);
        CLK, RST :in std_logic;
        i_dataA, i_dataB :in STD_LOGIC_VECTOR(15 downto 0);
        o_data :out STD_LOGIC_VECTOR(15 downto 0)
    );
end entity ALU;

architecture behavior of ALU is
    signal dataA, dataB, dataOut : signed(15 downto 0);
begin
    dataA <= signed(i_dataA);
    dataB <= signed(i_dataB);
    o_data <= std_logic_vector(dataOut);
    
    process (CLK, RST)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                dataOut <= (others => '0');
            else
                with(i_setting) select
                dataOut <=  dataA + dataB when "00",
                           dataA - dataB when "01",
                           dataA and dataB when "10",
                           dataA or dataB when "11";
            end if;
        end if;
    end process;
end architecture behavior;