library IEEE;
    use IEEE.STD_LOGIC_1164.all;
    use IEEE.NUMERIC_STD.all;

entity Memory is
    port ( 
        CLK     : in  STD_LOGIC;
        Reset     : in  STD_LOGIC;
        DataIn     : in  STD_LOGIC_VECTOR (15 downto 0);
        Address    : in  STD_LOGIC_VECTOR (15 downto 0);
        WriteEn    : in  STD_LOGIC;
        Enable     : in  STD_LOGIC;
        DataOut     : out STD_LOGIC_VECTOR (15 downto 0)
    );
end Memory;

architecture Behavioral of Memory is
    type Memory_Array is array ((2 ** 16) - 1 downto 0) of STD_LOGIC_VECTOR (15 downto 0);
    signal Memory : Memory_Array;
    
begin

    -- Read process
    process (Reset, WriteEn, DataIn, Address)
    begin
        if Reset = '1' then
            -- Clear DataOut on Reset
            DataOut <= (others => '0');
        elsif Enable = '1' then
            if WriteEn = '1' then
                -- If WriteEn then pass through DataIn
                DataOut <= DataIn;
            else
                -- Otherwise Read Memory
                DataOut <= Memory(to_integer(unsigned(Address)));
            end if;
        end if;
    end process;

    -- Write process
    process (CLK)
    begin
        if Reset = '1' then
            -- Clear Memory on Reset
            for i in Memory'Range loop
                Memory(i) <= (others => '0');
            end loop;
        elsif CLK = '1' and Enable = '1' and WriteEn = '1' then
            -- Store DataIn to Current Memory Address
            Memory(to_integer(unsigned(Address))) <= DataIn;
        end if;
    end process;

end Behavioral;