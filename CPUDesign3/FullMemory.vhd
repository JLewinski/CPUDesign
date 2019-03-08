library IEEE;
    use IEEE.STD_LOGIC_1164.all;
    use IEEE.NUMERIC_STD.all;

entity FullMemory is
    port ( 
        CLK, WE, RST        : in  STD_LOGIC;
        DataIn              : in  STD_LOGIC_VECTOR (15 downto 0);
        InstAddr, DataAddr  : in  STD_LOGIC_VECTOR (15 downto 0);
        InstOut, DataOut     : out STD_LOGIC_VECTOR (15 downto 0)
    );
end entity;

architecture behavior of FullMemory is
    type Memory_Array is array (2 ** 16 - 1 downto 0) of STD_LOGIC_VECTOR (15 downto 0);
    signal Memory : Memory_Array;
begin
    process (CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                InstOut <= (others => '0');
                DataOut <= (others  => '0');
            else
                InstOut <= Memory(InstAddr);
                DataOut <= Memory(DataAddr);
            end if;
        end if;
    end process;
    
    process (CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                --change to set specific data for instructions and data
                for i in Memory'Range loop
                    Memory(i) <= (others => '0');
                end loop;
            else
                if WE then
                    Memory(to_integer(unsigned(DataAddr))) <= DataIn;
                end if;
            end if;
        end if;
    end process;
end architecture;