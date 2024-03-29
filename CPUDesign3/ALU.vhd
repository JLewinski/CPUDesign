library ieee;
    use ieee.std_logic_1164.all;
    use IEEE.NUMERIC_STD.all;

entity ALU is
    port(
        SEL :in std_logic_vector(1 downto 0);
        RST :in std_logic;
        i_dataA, i_dataB :in STD_LOGIC_VECTOR(15 downto 0);
        o_data :out STD_LOGIC_VECTOR(15 downto 0);
        zero :out STD_LOGIC
    );
end entity ALU;

architecture behavior of ALU is
begin

    process (SEL, RST, i_dataA, i_dataB)
    begin
        if RST = '1' then
            o_data <= (others => '0');
            --must be done with calculations before the falling edge of the clock
        else
            case SEL is
                when "00" => o_data <= std_logic_vector(unsigned(i_dataA) + unsigned(i_dataB));
                when "01"=> o_data <= std_logic_vector(unsigned(i_dataA) - unsigned(i_dataB));
                when "10"=> o_data <= std_logic_vector(unsigned(i_dataA) and unsigned(i_dataB));
                when "11"=> o_data <= std_logic_vector(unsigned(i_dataA) or unsigned(i_dataB));
                when others => o_data <= (others => '0');
            end case;
            if i_dataA = X"0000" then
                zero <= '1';
            else
                zero <= '0';
            end if;
        end if;
    end process;
end architecture behavior;