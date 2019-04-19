library IEEE;
    use IEEE.STD_LOGIC_1164.all;
    use IEEE.NUMERIC_STD.all;
    use IEEE.std_logic_arith.sxt;

entity top is
    port(
        CLK, RST :in STD_LOGIC;
        inr :in STD_LOGIC_VECTOR(3 downto 0);
        readDataBus :in STD_LOGIC_VECTOR(15 downto 0);
        addressBus :out STD_LOGIC_VECTOR(9 downto 0);
        outValue, output, writeDataBus, writeAddress :out STD_LOGIC_VECTOR(15 downto 0)
    );
end entity;

architecture behavior of top is
    component Register16 is
        port(
            dataIn :in STD_LOGIC_VECTOR(15 downto 0);
            CLK, WE, RST :in STD_LOGIC;
            dataOut :out STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;

    component ALU is
        port(
            RST :in std_logic;
            SEL :in std_logic_vector(1 downto 0);
            i_dataA, i_dataB :in STD_LOGIC_VECTOR(15 downto 0);
            o_data :out STD_LOGIC_VECTOR(15 downto 0);
            zero :out STD_LOGIC
        );
    end component;

    component Control is
        port(
            instruction :in std_logic_vector (3 downto 0);
            RST :in std_logic;
            jump, branch, mem2Reg, memW, ri, regW, selDest, halt :out std_logic;
            aluOut : out std_logic_vector(1 downto 0)
        );
    end component;

    component Memory is
        port ( 
            CLK     : in  STD_LOGIC;
            Reset     : in  STD_LOGIC;
            DataIn     : in  STD_LOGIC_VECTOR (15 downto 0);
            Address    : in  STD_LOGIC_VECTOR (15 downto 0);
            WriteEn    : in  STD_LOGIC;
            Enable     : in  STD_LOGIC;
            DataOut     : out STD_LOGIC_VECTOR (15 downto 0)
        );
    end component;

    component InstructionMemory is
        port ( 
            Reset     : in  STD_LOGIC;
            Address    : in  STD_LOGIC_VECTOR (15 downto 0);
            DataOut     : out STD_LOGIC_VECTOR (15 downto 0)
        );
    end component;

    component RegisterMemory is
        generic (
            DATA_WIDTH        : integer := 16;
            ADDRESS_WIDTH    : integer := 4
        );
        port ( 
            DataIn                          : in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
            SourceA, SourceB, DestAddr, inr : in  STD_LOGIC_VECTOR (ADDRESS_WIDTH - 1 downto 0);
            WriteEn, CLK, RST               : in  STD_LOGIC;
            DataOutA, DataOutB, outValue    : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0)
        );
    end component;

    component Mux_2_To_1 is
        generic (
            d_WIDTH : integer := 1
        );
        port(
            SEL, RST :in std_logic;
            i_Data1, i_Data2 :in std_logic_vector(d_WIDTH downto 0);
            o_Data :out std_logic_vector(d_WIDTH downto 0)
        );
    end component;

    --PC
    signal pcIn, pcOut, pcPlus2, pcALUOut, calcPC, pcExt : STD_LOGIC_VECTOR(15 downto 0);

    --Instruction
    signal instruction, instructionExt, constantValue : STD_LOGIC_VECTOR(15 downto 0);

    --REGISTERS
    signal regA, regB, regD : STD_LOGIC_VECTOR(15 downto 0);
    signal destAddr : STD_LOGIC_VECTOR(3 downto 0);


    --CONTROL
    signal jump, brCtrl, mem2Reg, memW, ri, regW, selDest, zero, branch, HALT : std_logic;
    signal aluSetting : std_logic_vector(1 downto 0);

    --ALU
    signal aluIn2, aluResult : STD_LOGIC_VECTOR(15 downto 0);

    --DATA
    signal memOut : STD_LOGIC_VECTOR(15 downto 0);

begin

    branch <= brCtrl and zero;
    constantValue <= SXT(instruction(3 downto 0), 16);

    output <= instruction;

    PC: Register16 port map(
        dataIn => pcIn,
        CLK => CLK,
        WE => HALT,
        RST => RST,
        dataOut => pcOut);

    InstructionMem: InstructionMemory port map(
        Reset => RST,
        Address => pcOut,
        DataOut => instruction);

    CTRL: Control port map(
        instruction => instruction(15 downto 12),
        RST => RST,
        jump => jump,
        branch => brCtrl,
        mem2Reg => mem2Reg,
        memW => memW,
        ri => ri,
        regW => regW,
        selDest => selDest,
        aluOut => aluSetting,
        halt => HALT);

    DestRegMux: Mux_2_To_1 generic map(d_WIDTH => 4) port map(
        SEL => selDest,
        RST => RST,
        i_Data1 => instruction(7 downto 4),
        i_Data2 => instruction(3 downto 0),
        o_Data => destAddr);

    Registers: RegisterMemory port map(
        DataIn => regD,
        SourceA => instruction(11 downto 8),
        SourceB => instruction(7 downto 4),
        DestAddr => destAddr,
        inr => inr,
        WriteEn => regW,
        CLK => CLK,
        RST => RST,
        DataOutA => regA,
        DataOutB => regB,
        outValue => outValue);

    ALUMux: Mux_2_To_1 generic map(d_WIDTH => 16) port map(
        SEL => ri,
        RST => RST,
        i_Data1 => regB,
        i_Data2 => constantValue,
        o_Data => aluIn2);

    FullALU: ALU port map(
        SEL => aluSetting,
        RST => RST,
        i_dataA => regA,
        i_dataB => aluIn2,
        o_data => aluResult,
        zero => zero);

    DataMemory: Memory port map(
       CLK => CLK,
       Reset => RST,
       DataIn => regB,
       Address => aluResult,
       WriteEn => memW,
       Enable => '1',
       DataOut => memOut);

    DataMux : Mux_2_To_1 generic map(d_WIDTH => 16) port map(
        SEL => mem2Reg,
        RST => RST,
        i_Data1 => aluResult,
        i_Data2 => memOut,
        o_Data => regD);

    instructionExt(15 downto 1) <= SXT(instruction(7 downto 0), 15);
    instructionExt(0) <= '0';

    AddressAdder : ALU port map(
        SEL => "00",
        RST => RST,
        i_dataA => instructionExt,
        i_dataB => pcPlus2,
        o_data => pcALUOut);

    PCAdder : ALU port map(
        SEL => "00",
        RST => RST,
        i_dataA => pcOut,
        i_dataB => X"0002",
        o_data => pcPlus2);

    PCCalcMux: Mux_2_To_1 generic map(d_WIDTH => 16) port map(
        SEL => branch,
        RST => RST,
        i_Data1 => pcPlus2,
        i_Data2 => pcALUOut,
        o_Data => calcPC);

    pcExt(15 downto 13) <= pcPlus2(15 downto 13);
    pcExt(12 downto 1) <= instruction(11 downto 0);
    pcExt(0) <= '0';

    PCMux : Mux_2_To_1 generic map(d_WIDTH => 16) port map(
        SEL => jump,
        RST => RST,
        i_Data1 => calcPC,
        i_Data2 => pcExt,
        o_Data => pcIn);


    --Mem: FullMemory port map(
    --    CLK => CLK,
    --    WE => memW,
    --    RST => RST,
    --    DataIn => regB,
    --    InstAddr => pcOut,
    --    DataAddr => aluResult,
    --    InstOut => instruction,
    --    DataOut => memOut);
end architecture;