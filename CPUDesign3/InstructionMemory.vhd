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
    type Memory_Array is array ((2 ** 16) - 1 downto 0) of STD_LOGIC_VECTOR (7 downto 0);
    signal Memory : Memory_Array;
    signal addr : integer;
begin
    addr <= to_integer(unsigned(Address));
    -- Read process
    process (Reset, addr)
    begin
        if Reset = '1' then
            -- Clear DataOut on Reset
            DataOut <= (others => '0');
            -- Clear Memory on Reset
            for i in Memory'Range loop
                Memory(i) <= (others => '0');
            end loop;
            
            --Put default values in memory
            Memory(00) <= X"60";    --adc s8 s0 0
            Memory(01) <= X"80"; 
            Memory(02) <= X"60";    --adc s1 s0 7
            Memory(03) <= X"17"; 
            Memory(04) <= X"60";    --adc s2 s0 3
            Memory(05) <= X"23";
            Memory(06) <= X"01";    --add s3 s1 s2 (loop)
            Memory(07) <= X"23";
            Memory(08) <= X"11";    --sub s4 s1 s2
            Memory(09) <= X"24";
            Memory(10) <= X"21";    --and s5 s1 s4
            Memory(11) <= X"45";
            Memory(12) <= X"31";    --or s6 s1 s4
            Memory(13) <= X"46";
            Memory(14) <= X"58";    --str s3 s8(0)
            Memory(15) <= X"30";
            Memory(16) <= X"58";    --str s5 s8(2)
            Memory(17) <= X"52";
            Memory(18) <= X"58";    --str s4 s8(1)
            Memory(19) <= X"41";
            Memory(20) <= X"58";    --str s6 s8(3)
            Memory(21) <= X"63";
            Memory(22) <= X"68";    --adc s8 s8 4
            Memory(23) <= X"84";
            Memory(24) <= X"31";    --or s7 s1 s0
            Memory(25) <= X"07";
            Memory(26) <= X"87";    --brz s7 loadprocedure
            Memory(27) <= X"02";
            Memory(28) <= X"61";    --adc s1 s1 -1
            Memory(29) <= X"1F";
            Memory(30) <= X"90";    --jmp loop
            Memory(31) <= X"03";
            Memory(32) <= X"68";    --adc s2 s8 0 (loadprocedure)
            Memory(33) <= X"20";
            Memory(34) <= X"60";    --adc s8 s0 0
            Memory(35) <= X"80";
            Memory(36) <= X"48";    --ld s3 s8(0) (loadLoop)
            Memory(37) <= X"30";
            Memory(38) <= X"48";    --ld s4 s8(1)
            Memory(39) <= X"41";
            Memory(40) <= X"48";    --ld s5 s8(2)
            Memory(41) <= X"52";
            Memory(42) <= X"48";    --ld s6 s8(3)
            Memory(43) <= X"63";
            Memory(44) <= X"68";    --adc s8 s8 4
            Memory(45) <= X"84";
            Memory(46) <= X"12";    --sub s9 s2 s8
            Memory(47) <= X"89";
            Memory(48) <= X"89";    --brz s9 fin
            Memory(49) <= X"01";
            Memory(50) <= X"90";    --jmp loadLoop
            Memory(51) <= X"12";
            Memory(52) <= X"FF";    --HALT (fin)
            Memory(53) <= X"FF";

            
        elsif addr < (2 ** 16) - 2 and addr >= 0 then
            DataOut <= Memory(to_integer(unsigned(Address))) & Memory(to_integer(unsigned(Address)) + 1);
        else
            DataOut <= (others => '0');
        end if;
    end process;

end Behavioral;