library ieee;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

--add clock to be fast clock in top

entity RegisterMemory is
    generic (
        DATA_WIDTH        : integer := 8;
        ADDRESS_WIDTH    : integer := 8
    );
    port ( 
        DataIn                          : in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        SourceA, SourceB, DestAddr      : in  STD_LOGIC_VECTOR (ADDRESS_WIDTH - 1 downto 0);
        WriteEn                         : in  STD_LOGIC;
        DataOutA, DataOutB              : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0)
    );
end RegisterMemory;

architecture Behavioral of RegisterMemory is
    type Memory_Array is array ((2 ** ADDRESS_WIDTH) - 1 downto 0) of STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    signal Memory : Memory_Array;
begin

    -- Read process
    process (SourceA)
    begin
        DataOutA <= Memory(to_integer(unsigned(SourceA)));
    end process;

    process (SourceB)
    begin
        DataOutB <= Memory(to_integer(unsigned(SourceB)));
    end process;

    -- Write process
    process (DataIn)
    begin
        if WriteEn = '1' then
            -- Store DataIn to Current Memory Address
            Memory(to_integer(unsigned(DestAddr))) <= DataIn;
        end if;
    end process;

end Behavioral;