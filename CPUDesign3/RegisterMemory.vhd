﻿library ieee;
    use IEEE.STD_LOGIC_1164.all;
    use IEEE.NUMERIC_STD.all;

entity RegisterMemory is
    port ( 
        DataIn                          : in  STD_LOGIC_VECTOR (15 downto 0);
        SourceA, SourceB, DestAddr, inr : in  STD_LOGIC_VECTOR (3 downto 0);
        WriteEn, CLK, RST               : in  STD_LOGIC;
        DataOutA, DataOutB, outValue    : out STD_LOGIC_VECTOR (15 downto 0)
    );
end RegisterMemory;

architecture Behavioral of RegisterMemory is
    type Memory_Array is array ((2 ** 4) - 1 downto 0) of STD_LOGIC_VECTOR (15 downto 0);
    signal Memory : Memory_Array;
begin
    outValue <= Memory(to_integer(unsigned(inr)));
    -- Read process
    process (CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                DataOutA <= (others => '0');
                DataOutB <= (others => '0');
            else
                DataOutA <= Memory(to_integer(unsigned(SourceA)));
                DataOutB <= Memory(to_integer(unsigned(SourceB)));
            end if;
        end if;
    end process;

    -- Write process
    process (CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                for i in Memory'Range loop
                    Memory(i) <= (others => '0');
                end loop;
            elsif WriteEn = '1' then
                -- Store DataIn to Current Memory Address
                Memory(to_integer(unsigned(DestAddr))) <= DataIn;
            end if;
        end if;
    end process;

end Behavioral;