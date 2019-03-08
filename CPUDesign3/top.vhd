library IEEE;
    use IEEE.STD_LOGIC_1164.all;
    use IEEE.NUMERIC_STD.all;
    use IEEE.std_logic_arith.sxt;

entity top is
    port(
        output :out STD_LOGIC
    );
end entity;

architecture behavior of top is
    component Register16 is
        port(
            dataIn :in STD_LOGIC_VECTOR(15 downto 0);
            CLK, WE :in STD_LOGIC;
            dataOut :out STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;
    
    component ALU is
        port(
            i_setting :in std_logic_vector(1 downto 0);
            i_dataA, i_DataB :in signed(15 downto 0);
            o_data :out signed(15 downto 0)
        );
    end component;
    
    component Control is
        port(
            instruction :in std_logic_vector (3 downto 0);
            clk :in std_logic;
            jump, branch, mem2Reg, memW, ri, regW, selDest :out std_logic;
            aluOut : out std_logic_vector(1 downto 0)
        );
    end component;
    
    component Memory is
        generic (
            DATA_WIDTH        : integer := 16;
            ADDRESS_WIDTH    : integer := 16
        );
        port ( 
            CLK     : in  STD_LOGIC;
            Reset     : in  STD_LOGIC;
            DataIn     : in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
            Address    : in  STD_LOGIC_VECTOR (ADDRESS_WIDTH - 1 downto 0);
            WriteEn    : in  STD_LOGIC;
            Enable     : in  STD_LOGIC;
            DataOut     : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0)
        );
    end component;
    
    component RegisterMemory is
        generic (
            DATA_WIDTH        : integer := 16;
            ADDRESS_WIDTH    : integer := 4
        );
        port ( 
            DataIn                          : in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
            SourceA, SourceB, DestAddr      : in  STD_LOGIC_VECTOR (ADDRESS_WIDTH - 1 downto 0);
            WriteEn, CLK                    : in  STD_LOGIC;
            DataOutA, DataOutB              : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0)
        );
    end component;
    
    component Mux_2_To_1 is
        generic (
            d_WIDTH : integer := 1
        );
        port(
            i_Select, CLK :in std_logic;
            i_Data1, i_Data2 :in std_logic_vector(d_WIDTH downto 0);
            o_Data :out std_logic_vector(d_WIDTH downto 0)
        );
    end component;
    
    component SignExtend is
        generic(
            inputWidth : integer := 8;
            outputWidth : integer := 16
        );
        port(
            dataIn :in STD_LOGIC_VECTOR(inputWidth - 1 downto 0);
            CLK :in STD_LOGIC;
            dataOut :out STD_LOGIC_VECTOR(outputWidth - 1 downto 0)
        );
    end component;
    
    signal fstCLK, sysCLK : STD_LOGIC;
    
    --PC
    signal pcIn, pcOut, pcPlus4, pcALUOut, calcPC : STD_LOGIC_VECTOR(15 downto 0);
    
    --Instruction
    signal instruction : STD_LOGIC_VECTOR(15 downto 0);
    
    --REGISTERS
    signal regA, regB, regD : STD_LOGIC_VECTOR(15 downto 0);
    signal destAddr : STD_LOGIC_VECTOR(3 downto 0);
    signal constValue : STD_LOGIC;
    
    
    --CONTROL
    signal jump, branch, mem2Reg, memW, ri, regW, selDest : std_logic;
    signal aluSetting : std_logic_vector(1 downto 0);
    
    --ALU
    signal aluIn2, aluResult : STD_LOGIC_VECTOR(15 downto 0);
    
    --DATA
    signal memOut : STD_LOGIC_VECTOR(15 downto 0);
    
    constant clk_period : time := 1 ns;
begin
    fst_clk_process :process
    begin
        fstCLK <= not fstCLK after clk_period;
    end process;
    
    sl_clk_process :process
    begin
        sysCLK <= not sysCLK after clk_period * 10;
    end process;
    
    PC: Register16 port map(dataIn => pcIn, CLK => sysCLK, WE => '1', dataOut => pcOut);
    InstructionMemory: Memory port map(CLK => fstCLK, Reset => '0', DataIn => "0000000000000000", Address => pcOut, WriteEn => '0', Enable => '1', DataOut => instruction);
    CTRL: Control port map(instruction => instruction(15 downto 12), clk => fstCLK, jump, branch, mem2Reg, memW, ri, regW, selDest, aluSetting);
    DestRegMux: Mux_2_To_1 generic map(d_Width => 16) port map(i_Select => selDest, CLK => fstCLK, i_Data1 => instruction(7 downto 4), i_Data2 => instruction(3 downto 0), o_Data => destAddr);
    Registers: RegisterMemory port map(DataIn => regD, SourceA => instruction(11 downto 8), SourceB => instruction(7 downto 4), DestAddr => destAddr, WriteEn => regW, CLK => fstCLK, DataOutA => regA, DataOutB => regB);
    ConstMux: Mux_2_To_1 generic map(d_Width => 4) port map(i_Select => branch, CLK => fstCLK, i_Data1 => instruction(3 downto 0), i_Data2 => "0000", o_Data => constValue);
    ALUMux: Mux_2_To_1 generic map(d_Width => 16) port map(i_Select => ri, CLK => fstCLK, i_Data1 => regB, i_Data2 => SXT(constValue, 16), o_Data => aluIn2);
    FullALU: ALU port map(i_setting => aluSetting, i_dataA => regA, i_dataB => aluIn2, o_data => aluResult);
    DataMemory: Memory port map(CLK => fstCLK, Reset => '0', DataIn => regB, Address => aluResult, WriteEn => memW, Enable => '1', DataOut => memOut);
    DataMux : Mux_2_To_1 generic map(d_WIDTH => 16) port map(i_Select => mem2Reg, fstCLK, i_Data1 => aluResult, i_Data2 => memOut, o_Data => regD);
    AddressAdder : ALU port map(i_setting => "00", i_dataA => SXT(instruction(7 downto 0), 14) + "00", i_dataB => pcPlus4, o_data => pcALUOut);
    PCAdder : ALU port map(i_setting => "00", i_dataA => pcOut, i_dataB => "100", o_data => pcPlus4);
    PCCalcMux: Mux_2_To_1 generic map(d_WIDTH => 16) port map(i_Select => branch, fstCLK, i_Data1 => pcPlus4, i_Data2 => pcALUOut, o_Data => calcPC);
    PCMux : Mux_2_To_1 generic map(d_WIDTH => 16) port map(i_Select => jump, CLK => fstCLK, i_Data1 => calcPC, i_Data2 => pcPlus4(15 downto 14) + instruction(11 downto 0) + "00", o_Data => pcIn);
    
end architecture;