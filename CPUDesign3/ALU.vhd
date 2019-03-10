library ieee;
    use ieee.std_logic_1164.all;
    use IEEE.NUMERIC_STD.all;

entity ALU is
    port(
        SEL :in std_logic_vector(1 downto 0);
        CLK, RST :in std_logic;
        i_dataA, i_dataB :in STD_LOGIC_VECTOR(15 downto 0);
        o_data :out STD_LOGIC_VECTOR(15 downto 0)
    );
end entity ALU;

architecture behavior of ALU is
    signal dataA, dataB : unsigned(15 downto 0);
begin
    dataA <= unsigned(i_dataA);
    dataB <= unsigned(i_dataB);

    process (CLK, SEL)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                o_data <= (others => '0');
            else
                case SEL is
                    when "00" => o_data <= std_logic_vector(dataA + dataB);
                    when "01"=> o_data <= std_logic_vector(dataA - dataB);
                    when "10"=> o_data <= std_logic_vector(dataA and dataB);
                    when "11"=> o_data <= std_logic_vector(dataA or dataB);
                    when others => o_data <= (others => '0');
                end case;
            end if;
        end if;
    end process;
end architecture behavior;