﻿library ieee;
    use ieee.std_logic_1164.all;

entity Mux_2_To_1 is
    generic (
        d_WIDTH : integer := 1
    );
    port(
        i_Select, CLK, RST :in std_logic;
        i_Data1, i_Data2 :in std_logic_vector(d_WIDTH downto 0);
        o_Data :out std_logic_vector(d_WIDTH downto 0)
    );
end entity;

architecture behavior of Mux_2_To_1 is
begin
    process(CLK) is
    begin
        if RST = '0' then
            o_Data <= (others => '0');
        elsif rising_edge(CLK) then
            o_Data <= i_Data1 when i_Select = '0' else i_Data2;
        end if;
    end process;
end architecture behavior;