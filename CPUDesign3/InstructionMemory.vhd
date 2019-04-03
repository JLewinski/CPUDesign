library IEEE;
    use IEEE.STD_LOGIC_1164.all;
    use IEEE.NUMERIC_STD.all;

entity InstructionMemory is
    port ( 
        Reset     : in  STD_LOGIC;
        Address    : in  STD_LOGIC_VECTOR (15 downto 0);
        DataOut     : out STD_LOGIC_VECTOR (15 downto 0)
    );
end InstructionMemory;

architecture Behavioral of InstructionMemory is
    type Memory_Array is array ((2 ** 16) - 1 downto 0) of STD_LOGIC_VECTOR (15 downto 0);
    signal Memory : Memory_Array;
begin

    -- Read process
    process (Reset, Address)
    begin
        if Reset = '1' then
            -- Clear DataOut on Reset
            DataOut <= (others => '0');
            -- Clear Memory on Reset
            for i in Memory'Range loop
                Memory(i) <= (others => '1');
            end loop;
            
            --Put default values in memory
            Memory(0) <= X"6017";
            Memory(4) <= X"6023";
            Memory(8) <= X"0123";
            Memory(12) <= X"1124";
            Memory(16) <= X"2145";
            Memory(20) <= X"3146";
            Memory(24) <= X"3107";
            Memory(28) <= X"8703";
            Memory(32) <= X"611F";
            Memory(36) <= X"9002";
            Memory(40) <= X"FFFF";
            
        else
            DataOut <= Memory(to_integer(unsigned(Address)));
        end if;
    end process;

end Behavioral;